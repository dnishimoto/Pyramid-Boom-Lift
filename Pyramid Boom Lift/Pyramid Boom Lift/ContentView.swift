/*
 Initialize the site and structural envelope. Define the foundation, pyramid geometry, course layout, and subterranean chamber.



 Build the obelisk bottom to top. Verify support and placement after each block.



 Place the benben. Validate reach, load, geometry, and completion of the central structure.



 Initialize four corner stockpiles and four lift assignments. Prevent shared-pickup errors and duplicate block claims.



 Plan the next outward course. Reserve destinations, supports, chamber boundaries, passages, and air-shaft spaces.



 Select and reserve a block. Assign the block to the correct lift, stockpile, and destination.



 Position the lift and pick up the block. Check reach, clearance, and load capacity.



 Lift and transport the block. Continuously evaluate cable, pulley, joint, boom, and stability limits.



 Validate the destination in three dimensions. Check overlap, support, course boundaries, and reserved internal voids.



 Place and commit the block. Record success only after validation passes.



 Handle specialized structures. Construct chamber boundaries and passages, and place the 80-ton King's Chamber roof stones using dedicated geometry and load rules.



 Check the course, including course seven. Resolve the lintel's true footprint and verify that all required blocks are complete.



 Advance the four construction fronts. Release dependent work only after the required placements have been verified.



 Repeat through the final course. Continue until all required exterior and interior construction tasks are complete.



 Produce the final verification report. Summarize completion, geometry, structural estimates, and any unresolved failures
 */

import SwiftUI
import SceneKit
import UIKit
import simd
import Combine

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var controller = PyramidConstructionController()

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 14) {
                    scenePanel
                    controlsPanel
                    stockpilePanel
                    cranePanel
                    equationsPanel
                    pipelinePanel
                }
                .padding(14)
            }
        }
        .background(Color(red: 0.035, green: 0.055, blue: 0.09))
        .preferredColorScheme(.dark)
        .onAppear { controller.start() }
        .onDisappear { controller.stop() }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("PYRAMID BOOM-LIFT SIMULATOR")
                    .font(.headline.bold())
                Text("Center-out placement · Four corner cranes")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
            }

            Spacer()

            Circle()
                .fill(controller.isRunning ? .green : .orange)
                .frame(width: 9, height: 9)

            Text(controller.isRunning ? "RUNNING" : "PAUSED")
                .font(.caption.bold())
                .foregroundStyle(controller.isRunning ? .green : .orange)
        }
        .padding()
        .background(Color(red: 0.055, green: 0.085, blue: 0.13))
    }

    private var scenePanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("LIVE CONSTRUCTION")
                    .font(.subheadline.bold())
                Spacer()
                Text("Course \(controller.currentCourseLabel)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.cyan)
            }

            SceneView(
                scene: controller.scene,
                pointOfView: controller.cameraNode,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting
                ]
            )
            .frame(minHeight: 320)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(controller.statusMessage)
                .font(.caption)
                .foregroundStyle(controller.statusColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .panelStyle()
    }

    private var controlsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CONTROLS")
                .font(.subheadline.bold())

            Picker("Mode", selection: $controller.mode) {
                Text("Visual Demo").tag(SimulationMode.visualDemo)
                Text("Engineering Screen").tag(SimulationMode.engineeringScreen)
            }
            .pickerStyle(.segmented)
            .onChange(of: controller.mode) { _, newValue in
                controller.changeMode(newValue)
            }

            HStack(spacing: 10) {
                Button {
                    controller.toggleRun()
                } label: {
                    Label(
                        controller.isRunning ? "Pause" : "Resume",
                        systemImage: controller.isRunning
                            ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)

                Button {
                    controller.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            HStack {
                Text("Animation speed")
                    .font(.caption)

                Slider(value: $controller.speed, in: 0.25...300, step: 0.25)

                Text(String(format: "%.2f×", controller.speed))
                    .font(.caption.monospacedDigit())
                    .frame(width: 58, alignment: .trailing)
            }

            HStack(spacing: 8) {
                metric("Placed", "\(controller.placedCount)")
                metric("Required", "\(controller.requiredCount)")
                metric("Progress", String(format: "%.1f%%", controller.progress * 100))
            }
        }
        .panelStyle()
    }

    private var stockpilePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CORNER STOCKPILE INVENTORY")
                .font(.subheadline.bold())

            ForEach(controller.stockpileReadings) { pile in
                HStack {
                    Circle()
                        .fill(pile.color)
                        .frame(width: 10, height: 10)

                    Text(pile.name)
                        .font(.caption.bold())

                    Spacer()

                    Text("\(pile.remaining) blocks")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(pile.remaining > 0 ? .white : .red)

                    Text(pile.assignedCrane)
                        .font(.caption2)
                        .foregroundStyle(.cyan)
                }
            }
        }
        .panelStyle()
    }

    private var cranePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FOUR CRANE FORCE DISPLAYS")
                .font(.subheadline.bold())

            ForEach(controller.craneReadings) { reading in
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(reading.name)
                            .font(.caption.bold())
                        Spacer()
                        Text(reading.phase)
                            .font(.caption)
                            .foregroundStyle(reading.isBlocked ? .red : .cyan)
                    }

                    HStack(spacing: 6) {
                        forceCard("Load", String(format: "%.1f kN", reading.loadKN))
                        forceCard("Moment", String(format: "%.1f kN·m", reading.momentKNm))
                        forceCard("Cable", String(format: "%.1f kN", reading.cableKN))
                        forceCard("Joint*", String(format: "%.1f kN", reading.jointKN))
                    }

                    if reading.isBlocked {
                        Text(reading.detail)
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }

                if reading.id != controller.craneReadings.last?.id {
                    Divider().overlay(.white.opacity(0.1))
                }
            }

            Text("* Joint force is a simplified resultant estimate, not a structural joint analysis.")
                .font(.caption2)
                .foregroundStyle(.orange)
        }
        .panelStyle()
    }

    private var equationsPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ENGINEERING EQUATIONS")
                .font(.subheadline.bold())

            equation("Load force", "F = m × g",
                     "Weight in newtons; g = 9.81 m/s².")

            equation("Boom moment", "M = F × r⊥",
                     "Load multiplied by perpendicular distance from the pivot.")

            equation("Ideal cable tension", "T = F / (n × cos θ)",
                     "Idealized pulley with n supporting rope segments.")

            equation("Joint reaction estimate", "R ≈ √(F² + H²)",
                     "Simplified resultant; not a full frame analysis.")

            equation("Bearing pressure", "p = F / A",
                     "Force divided by effective bearing area.")

            equation("Static load screen", "M = (m × g / 1000) × r",
                     "Illustrative moment screen; excludes dynamics and structural failure modes.")

            Text(controller.mode == .visualDemo
                 ? "Visual mode permits animation despite illustrative moment-limit exceedance."
                 : "Engineering screen blocks targets that exceed configured reach or moment limits.")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        .panelStyle()
    }

    private var pipelinePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONSTRUCTION PIPELINE")
                .font(.subheadline.bold())

            pipelineRow("1", "Establish the central datum.")
            pipelineRow("2", "Find the lowest unfinished course.")
            pipelineRow("3", "Select the eligible block nearest the center.")
            pipelineRow("4", "Assign the crane's own corner stockpile.")
            pipelineRow("5", "Check reach, moment, support, and overlap.")
            pipelineRow("6", "Convert one pile inventory unit into the carried stone.")
            pipelineRow("7", "Lift, transport, and lower the stone.")
            pipelineRow("8", "Validate and commit placement.")
            pipelineRow("9", "Reserve the course-7 lintel footprint.")
            pipelineRow("10", "Report inventory depletion or blocked placement.")

            Divider().overlay(.white.opacity(0.1))

            statusRow("Active phase", controller.activePhase)
            statusRow("Completed courses",
                      "\(controller.completedCourseCount) / \(controller.courseCount)")
            statusRow("Nominal stone masses", "10 t base · 2.5 t upper")
            statusRow("King's Chamber lintel", "80 t modeled load")
        }
        .panelStyle()
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
            Text(value)
                .font(.headline.monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    private func forceCard(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(6)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private func equation(_ title: String, _ formula: String, _ note: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.caption.bold())
                Spacer()
                Text(formula)
                    .font(.caption.monospaced())
                    .foregroundStyle(.cyan)
            }
            Text(note)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.65))
        }
    }

    private func pipelineRow(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.cyan)
                .frame(width: 22, alignment: .leading)
            Text(text)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private func statusRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit())
        }
    }
}

private extension View {
    func panelStyle() -> some View {
        padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.065, green: 0.09, blue: 0.135))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.07), lineWidth: 1)
            }
    }
}

// MARK: - Types

enum SimulationMode: String, CaseIterable, Identifiable {
    case visualDemo
    case engineeringScreen
    var id: String { rawValue }
}

struct CraneReading: Identifiable {
    let id: Int
    let name: String
    var phase: String
    var loadKN: Double
    var momentKNm: Double
    var cableKN: Double
    var jointKN: Double
    var isBlocked: Bool
    var detail: String
}

struct StockpileReading: Identifiable {
    let id: Int
    let name: String
    let remaining: Int
    let assignedCrane: String
    let color: Color
}

private struct BlockTarget: Identifiable {
    let id: Int
    let course: Int
    let gridX: Int
    let gridZ: Int
    let position: SIMD3<Float>
    let massKg: Double
    let size: SIMD3<Float>

    var isLintel: Bool { massKg >= 80_000 }
}

private enum LiftPhase {
    case idle, pickup, lifting, transporting, lowering, releasing

    var label: String {
        switch self {
        case .idle: return "Idle"
        case .pickup: return "Pickup"
        case .lifting: return "Lifting"
        case .transporting: return "Transporting"
        case .lowering: return "Lowering"
        case .releasing: return "Release"
        }
    }
}

@MainActor
private final class CraneRig {
    let id: Int
    let name: String
    let base: SIMD3<Float>
    let root: SCNNode
    let pivot: SCNNode
    let boomArm: SCNNode
    let cable: SCNNode
    let hook: SCNNode
    let stockpile: SIMD3<Float>

    var target: BlockTarget?
    var blockNode: SCNNode?
    var phase: LiftPhase = .idle
    var phaseTime = 0.0
    var blockedReason = ""

    init(
        id: Int, name: String, base: SIMD3<Float>,
        root: SCNNode, pivot: SCNNode, boomArm: SCNNode,
        cable: SCNNode, hook: SCNNode, stockpile: SIMD3<Float>
    ) {
        self.id = id
        self.name = name
        self.base = base
        self.root = root
        self.pivot = pivot
        self.boomArm = boomArm
        self.cable = cable
        self.hook = hook
        self.stockpile = stockpile
    }
}

// MARK: - Controller

@MainActor
final class PyramidConstructionController: ObservableObject {
    @Published var isRunning = false
    @Published var speed = 1.0
    @Published var mode: SimulationMode = .visualDemo

    @Published private(set) var placedCount = 0
    @Published private(set) var requiredCount = 0
    @Published private(set) var progress = 0.0
    @Published private(set) var currentCourseLabel = "0"
    @Published private(set) var activePhase = "Waiting"
    @Published private(set) var statusMessage = "Preparing construction plan..."
    @Published private(set) var statusColor: Color = .cyan
    @Published private(set) var completedCourseCount = 0
    @Published private(set) var courseCount = 13
    @Published private(set) var craneReadings: [CraneReading] = []
    @Published private(set) var stockpileReadings: [StockpileReading] = []

    let scene = SCNScene()
    let cameraNode = SCNNode()

    private let world = SCNNode()
    private let blocksRoot = SCNNode()
    private let rigsRoot = SCNNode()
    private let stockpileRoot = SCNNode()
    private let interiorGuideRoot = SCNNode()

    private let tick = 1.0 / 60.0
    private let blockHeight: Float = 0.42
    private let gridSpacing: Float = 0.82
    private let maximumMomentKNm = 220.0
    private let maximumReachM = 18.0
    private let cableSegmentCount = 2.0
    private let cableAngleRadians = 0.20
    private let boomPivotHeight: Float = 2.7
    private let maximumVisualBoomLength: Float = 18.0
    private let blocksPerStockpile = 250

    private var timer: Timer?
    private var targets: [BlockTarget] = []
    private var placedIDs = Set<Int>()
    private var reservedIDs = Set<Int>()
    private var blockedReasons: [Int: String] = [:]
    private var cranes: [CraneRig] = []
    private var stockpileNodes: [Int: [SCNNode]] = [:]
    private var stockpileInventory: [Int: Int] = [:]
    private var loweringCraneID: Int?
    private var nextTargetID = 0

    private let pilePositions: [SIMD3<Float>] = [
        SIMD3(-11, 0.4, -11), // NW
        SIMD3(11, 0.4, -11),  // NE
        SIMD3(-11, 0.4, 11),  // SW
        SIMD3(11, 0.4, 11)    // SE
    ]

    private let pileColors: [UIColor] = [
        .cyan, .orange, .green, .purple
    ]

    init() {
        scene.rootNode.addChildNode(world)
        world.addChildNode(blocksRoot)
        world.addChildNode(rigsRoot)
        world.addChildNode(stockpileRoot)
        world.addChildNode(interiorGuideRoot)

        buildScene()
        buildTargets()
        buildInteriorGuides()
        buildStockpile()
        buildCranes()
        updateAllDisplays()
    }

    // MARK: Scene

    private func buildScene() {
        scene.background.contents = UIColor(
            red: 0.035, green: 0.055, blue: 0.085, alpha: 1
        )

        let camera = SCNCamera()
        camera.fieldOfView = 48
        camera.zNear = 0.1
        camera.zFar = 500
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(18, 17, 23)
        cameraNode.look(at: SCNVector3(0, 3, 0))
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 550
        ambient.light = ambientLight
        scene.rootNode.addChildNode(ambient)

        let key = SCNNode()
        let keyLight = SCNLight()
        keyLight.type = .omni
        keyLight.intensity = 1100
        key.position = SCNVector3(8, 18, 12)
        key.light = keyLight
        scene.rootNode.addChildNode(key)

        let ground = SCNBox(
            width: 34, height: 0.25, length: 34, chamferRadius: 0
        )
        ground.firstMaterial = makeMaterial(
            UIColor(red: 0.38, green: 0.31, blue: 0.21, alpha: 1)
        )
        let groundNode = SCNNode(geometry: ground)
        groundNode.position = SCNVector3(0, -0.15, 0)
        world.addChildNode(groundNode)

        for coordinate in stride(from: -15, through: 15, by: 3) {
            let material = makeMaterial(UIColor.white.withAlphaComponent(0.07))

            let h = SCNBox(width: 30, height: 0.012, length: 0.012, chamferRadius: 0)
            h.firstMaterial = material
            let hn = SCNNode(geometry: h)
            hn.position = SCNVector3(0, 0.002, Float(coordinate))
            world.addChildNode(hn)

            let v = SCNBox(width: 0.012, height: 0.012, length: 30, chamferRadius: 0)
            v.firstMaterial = material
            let vn = SCNNode(geometry: v)
            vn.position = SCNVector3(Float(coordinate), 0.002, 0)
            world.addChildNode(vn)
        }

        let datum = SCNBox(width: 0.48, height: 4, length: 0.48, chamferRadius: 0.03)
        datum.firstMaterial = makeMaterial(
            UIColor(red: 0.18, green: 0.55, blue: 0.75, alpha: 0.35)
        )
        let datumNode = SCNNode(geometry: datum)
        datumNode.position = SCNVector3(0, 2, 0)
        world.addChildNode(datumNode)
    }

    // MARK: Target generation and lintel footprint

    private func buildTargets() {
        targets.removeAll()
        nextTargetID = 0

        let baseWidth = 13
        let lintelCourse = 7
        let lintelSize: Float = 2.7
        let ordinaryWidth = gridSpacing * 0.96

        for course in 0..<courseCount {
            let width = baseWidth - course
            let offset = Float(width - 1) * gridSpacing / 2
            let y = Float(course) * blockHeight + blockHeight / 2

            // Insert the special lintel exactly once.
            if course == lintelCourse {
                targets.append(
                    BlockTarget(
                        id: nextTargetID,
                        course: course,
                        gridX: width / 2,
                        gridZ: width / 2,
                        position: SIMD3<Float>(0, y, 0),
                        massKg: 80_000,
                        size: SIMD3<Float>(lintelSize, blockHeight, lintelSize)
                    )
                )
                nextTargetID += 1
            }

            for gridX in 0..<width {
                for gridZ in 0..<width {
                    let x = Float(gridX) * gridSpacing - offset
                    let z = Float(gridZ) * gridSpacing - offset

                    // Reserve the complete lintel footprint, including
                    // the central grid cell. No ordinary course-7 stone
                    // is generated if its footprint overlaps the lintel.
                    if course == lintelCourse {
                        let overlapsLintelX =
                            abs(x) < (lintelSize + ordinaryWidth) / 2
                        let overlapsLintelZ =
                            abs(z) < (lintelSize + ordinaryWidth) / 2

                        if overlapsLintelX && overlapsLintelZ {
                            continue
                        }
                    }

                    if isReservedInteriorCell(
                        course: course,
                        gridX: gridX,
                        gridZ: gridZ,
                        width: width
                    ) {
                        continue
                    }

                    targets.append(
                        BlockTarget(
                            id: nextTargetID,
                            course: course,
                            gridX: gridX,
                            gridZ: gridZ,
                            position: SIMD3<Float>(x, y, z),
                            massKg: course == 0 ? 10_000 : 2_500,
                            size: SIMD3<Float>(ordinaryWidth, blockHeight, ordinaryWidth)
                        )
                    )
                    nextTargetID += 1
                }
            }
        }

        requiredCount = targets.count
        placedCount = 0
        progress = 0
    }

    private func isReservedInteriorCell(
        course: Int, gridX: Int, gridZ: Int, width: Int
    ) -> Bool {
        guard (4...6).contains(course), width >= 7 else {
            return false
        }

        let center = (width - 1) / 2
        return abs(gridX - center) <= 1 && abs(gridZ - center) <= 1
    }

    // MARK: Interior guides

    private func buildInteriorGuides() {
        interiorGuideRoot.childNodes.forEach { $0.removeFromParentNode() }

        func bright(_ color: UIColor) -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.emission.contents = color
            material.lightingModel = .constant
            material.isDoubleSided = true
            return material
        }

        func addGuide(
            _ name: String, _ size: SIMD3<Float>,
            _ center: SIMD3<Float>, _ material: SCNMaterial
        ) {
            let geometry = SCNBox(
                width: CGFloat(size.x),
                height: CGFloat(size.y),
                length: CGFloat(size.z),
                chamferRadius: 0
            )
            geometry.firstMaterial = material
            let node = SCNNode(geometry: geometry)
            node.name = name
            node.position = SCNVector3(center.x, center.y, center.z)
            interiorGuideRoot.addChildNode(node)
        }

        let red = bright(UIColor(red: 1, green: 0, blue: 0.015, alpha: 1))
        let orange = bright(UIColor(red: 1, green: 0.38, blue: 0, alpha: 1))
        let green = bright(UIColor(red: 0, green: 1, blue: 0.12, alpha: 1))

        addGuide("RED - Lower Chamber",
                 SIMD3(2.25, 1.15, 2.25), SIMD3(0, 2.55, 0), red)
        addGuide("RED - Upper Chamber",
                 SIMD3(1.75, 0.85, 1.75), SIMD3(0, 4.1, 0), red)
        addGuide("ORANGE - Horizontal Passage",
                 SIMD3(4.8, 0.42, 0.48), SIMD3(-2.7, 2.65, 0), orange)
        addGuide("ORANGE - Connecting Passage",
                 SIMD3(0.48, 1.7, 0.48), SIMD3(-4.75, 3.35, 0), orange)
        addGuide("GREEN - North Airway",
                 SIMD3(0.22, 0.22, 3.4), SIMD3(0, 4.1, -2.55), green)
        addGuide("GREEN - South Airway",
                 SIMD3(0.22, 0.22, 3.4), SIMD3(0, 4.1, 2.55), green)
    }

    // MARK: Stockpiles

    private func buildStockpile() {
        stockpileRoot.childNodes.forEach { $0.removeFromParentNode() }
        stockpileNodes.removeAll()
        stockpileInventory.removeAll()

        for pileID in 0..<4 {
            var nodes: [SCNNode] = []

            for index in 0..<blocksPerStockpile {
                let column = index % 5
                let row = (index / 5) % 5
                let layer = index / 25

                let geometry = SCNBox(
                    width: 0.32, height: 0.22, length: 0.32,
                    chamferRadius: 0.015
                )
                geometry.firstMaterial = makeMaterial(pileColors[pileID])

                let node = SCNNode(geometry: geometry)
                node.position = SCNVector3(
                    pilePositions[pileID].x + (Float(column) - 2) * 0.34,
                    0.11 + Float(layer) * 0.23,
                    pilePositions[pileID].z + (Float(row) - 2) * 0.34
                )
                node.name = "Pile\(pileID)_Block\(index)"
                stockpileRoot.addChildNode(node)
                nodes.append(node)
            }

            stockpileNodes[pileID] = nodes
            stockpileInventory[pileID] = nodes.count
        }

        updateStockpileReadings()
    }

    private func takeBlockFromStockpile(pileID: Int) -> SCNNode? {
        guard var pile = stockpileNodes[pileID], !pile.isEmpty else {
            return nil
        }

        let node = pile.removeLast()
        stockpileNodes[pileID] = pile
        stockpileInventory[pileID] = pile.count
        updateStockpileReadings()
        return node
    }

    private func updateStockpileReadings() {
        let names = ["NW", "NE", "SW", "SE"]
        let craneNames = [
            "Crane A", "Crane B", "Crane C", "Crane D"
        ]

        stockpileReadings = (0..<4).map { id in
            StockpileReading(
                id: id,
                name: "Pile \(names[id])",
                remaining: stockpileInventory[id] ?? 0,
                assignedCrane: craneNames[id],
                color: Color(uiColor: pileColors[id])
            )
        }
    }

    // MARK: Cranes

    private func buildCranes() {
        cranes.removeAll()
        rigsRoot.childNodes.forEach { $0.removeFromParentNode() }

        let configurations: [(String, SIMD3<Float>, SIMD3<Float>)] = [
            ("Crane A · NW", SIMD3(-8, 0, -8), pilePositions[0]),
            ("Crane B · NE", SIMD3(8, 0, -8), pilePositions[1]),
            ("Crane C · SW", SIMD3(-8, 0, 8), pilePositions[2]),
            ("Crane D · SE", SIMD3(8, 0, 8), pilePositions[3])
        ]

        let timber = makeMaterial(
            UIColor(red: 0.42, green: 0.25, blue: 0.12, alpha: 1)
        )
        let rope = makeMaterial(UIColor(red: 0.2, green: 0.16, blue: 0.12, alpha: 1))

        for (index, config) in configurations.enumerated() {
            let root = SCNNode()
            root.name = config.0
            root.position = SCNVector3(config.1.x, config.1.y, config.1.z)
            rigsRoot.addChildNode(root)

            let base = SCNBox(width: 1.2, height: 0.6, length: 1.2, chamferRadius: 0.04)
            base.firstMaterial = timber
            let baseNode = SCNNode(geometry: base)
            baseNode.position = SCNVector3(0, 0.3, 0)
            root.addChildNode(baseNode)

            addTimber(to: root,
                      from: SCNVector3(-0.48, 0.6, -0.48),
                      to: SCNVector3(0.48, 3.1, 0.48),
                      radius: 0.13, material: timber)
            addTimber(to: root,
                      from: SCNVector3(0.48, 0.6, -0.48),
                      to: SCNVector3(-0.48, 3.1, 0.48),
                      radius: 0.13, material: timber)

            let pivot = SCNNode()
            pivot.position = SCNVector3(0, boomPivotHeight, 0)
            root.addChildNode(pivot)

            let armGeometry = SCNBox(
                width: 0.30, height: 0.30, length: 1,
                chamferRadius: 0.04
            )
            armGeometry.firstMaterial = timber
            let arm = SCNNode(geometry: armGeometry)
            arm.position = SCNVector3(0, 0, -2.9)
            arm.scale = SCNVector3(1, 1, 5.8)
            pivot.addChildNode(arm)

            addTimber(to: pivot,
                      from: SCNVector3(0, -1.8, 0.6),
                      to: SCNVector3(0, 0, -5.8),
                      radius: 0.10, material: timber)

            let counterweightGeometry = SCNBox(
                width: 0.85, height: 0.6, length: 0.85,
                chamferRadius: 0.03
            )
            counterweightGeometry.firstMaterial = makeMaterial(.darkGray)
            let counterweight = SCNNode(geometry: counterweightGeometry)
            counterweight.position = SCNVector3(0, -0.15, 1.05)
            pivot.addChildNode(counterweight)

            let cable = SCNNode(geometry: SCNCylinder(radius: 0.025, height: 1))
            cable.geometry?.firstMaterial = rope
            root.addChildNode(cable)

            let hookGeometry = SCNTorus(ringRadius: 0.14, pipeRadius: 0.035)
            hookGeometry.firstMaterial = makeMaterial(.orange)
            let hook = SCNNode(geometry: hookGeometry)
            root.addChildNode(hook)

            cranes.append(
                CraneRig(
                    id: index,
                    name: config.0,
                    base: config.1,
                    root: root,
                    pivot: pivot,
                    boomArm: arm,
                    cable: cable,
                    hook: hook,
                    stockpile: config.2
                )
            )
        }
    }

    // MARK: Timer and scheduler

    func start() {
        guard timer == nil else {
            isRunning = true
            return
        }

        isRunning = true
        let newTimer = Timer(timeInterval: tick, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.step() }
        }
        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)

        statusMessage = mode == .visualDemo
            ? "Visual demo running. Crane capacity is not certified."
            : "Engineering screen active. Illustrative reach and moment limits apply."
        statusColor = mode == .visualDemo ? .orange : .cyan
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func toggleRun() {
        if isRunning {
            stop()
            statusMessage = "Paused. Press Resume to continue."
            statusColor = .orange
        } else {
            start()
        }
    }

    func changeMode(_ newMode: SimulationMode) {
        mode = newMode
        blockedReasons.removeAll()
        statusMessage = newMode == .visualDemo
            ? "Visual demo: moment limit may be bypassed."
            : "Engineering screen: reach and moment limits enforced."
        statusColor = newMode == .visualDemo ? .orange : .cyan
    }

    private func step() {
        guard isRunning else { return }

        let delta = tick * speed
        for index in cranes.indices {
            advanceCrane(at: index, deltaTime: delta)
        }

        assignAvailableCranes()
        refreshCourseStatus()
        updateAllDisplays()

        if placedCount >= requiredCount {
            stop()
            statusMessage = "All generated target blocks have been placed."
            statusColor = .green
        }
    }

    private func lowestUnfinishedCourse() -> Int? {
        targets.filter { !placedIDs.contains($0.id) }
            .map(\.course)
            .min()
    }

    private func assignAvailableCranes() {
        guard let course = lowestUnfinishedCourse() else { return }
        currentCourseLabel = "\(course)"

        for index in cranes.indices where cranes[index].phase == .idle {
            if let target = chooseNextTarget(forCraneAt: index, course: course) {
                assign(target, toCraneAt: index)
            }
        }

        let remaining = targets.filter {
            $0.course == course && !placedIDs.contains($0.id)
        }

        if !remaining.isEmpty && !cranes.contains(where: { $0.phase != .idle }) {
            let reasons = remaining.prefix(4).compactMap { blockedReasons[$0.id] }
            if !reasons.isEmpty {
                statusMessage = "Course \(course) blocked: \(reasons.joined(separator: " | "))"
                statusColor = .red
            } else {
                statusMessage = "Course \(course): waiting for eligible crane or inventory."
                statusColor = .orange
            }
        }
    }

    private func chooseNextTarget(forCraneAt index: Int, course: Int) -> BlockTarget? {
        let crane = cranes[index]
        let candidates = targets
            .filter {
                $0.course == course &&
                !placedIDs.contains($0.id) &&
                !reservedIDs.contains($0.id)
            }
            .sorted { a, b in
                let ra = a.position.x * a.position.x + a.position.z * a.position.z
                let rb = b.position.x * b.position.x + b.position.z * b.position.z
                if abs(ra - rb) > 0.001 { return ra < rb }
                return horizontalDistance(crane.base, a.position)
                    < horizontalDistance(crane.base, b.position)
            }

        for target in candidates {
            let failed = placementChecks(target, crane: crane).filter { !$0.passed }
            if failed.isEmpty { return target }

            blockedReasons[target.id] = failed
                .map { "\($0.name): \($0.detail)" }
                .joined(separator: "; ")
        }
        return nil
    }

    private func assign(_ target: BlockTarget, toCraneAt index: Int) {
        guard !reservedIDs.contains(target.id),
              !placedIDs.contains(target.id) else { return }

        let pileID = cranes[index].id
        guard let inventoryNode = takeBlockFromStockpile(pileID: pileID) else {
            blockedReasons[target.id] =
                "\(cranes[index].name): corner stockpile \(pileID) is empty."
            return
        }

        reservedIDs.insert(target.id)
        blockedReasons.removeValue(forKey: target.id)
        cranes[index].target = target
        cranes[index].phase = .pickup
        cranes[index].phaseTime = 0

        // Reuse the inventory node as the carried stone. Its geometry is
        // changed to the target block instead of discarding the source node.
        inventoryNode.removeFromParentNode()
        inventoryNode.geometry = makeStoneGeometry(for: target)
        inventoryNode.name = "stone-\(target.id)"
        inventoryNode.position = SCNVector3(
            cranes[index].stockpile.x,
            cranes[index].stockpile.y,
            cranes[index].stockpile.z
        )
        addBlockFrame(to: inventoryNode, target: target)
        blocksRoot.addChildNode(inventoryNode)
        cranes[index].blockNode = inventoryNode

        poseCrane(
            at: index,
            hookWorldPosition: SIMD3(
                cranes[index].stockpile.x,
                cranes[index].stockpile.y + 0.25,
                cranes[index].stockpile.z
            )
        )

        statusMessage =
            "\(cranes[index].name) loading block \(target.id) from pile \(pileID)."
        statusColor = .cyan
    }

    // MARK: Lift motion

    private func advanceCrane(at index: Int, deltaTime: Double) {
        guard let target = cranes[index].target,
              let block = cranes[index].blockNode else { return }

        cranes[index].phaseTime += deltaTime
        let duration = phaseDuration(for: cranes[index].phase)
        let t = min(1, cranes[index].phaseTime / duration)
        let eased = smooth(t)

        let stock = cranes[index].stockpile
        let destination = target.position
        let clearance: Float = 2.0
        let stockLifted = SIMD3(stock.x, stock.y + clearance, stock.z)
        let targetLifted = SIMD3(
            destination.x, destination.y + clearance, destination.z
        )

        switch cranes[index].phase {
        case .idle:
            return

        case .pickup:
            block.position = SCNVector3(stock.x, stock.y, stock.z)
            poseCrane(at: index,
                      hookWorldPosition: SIMD3(stock.x, stock.y + 0.25, stock.z))
            if t >= 1 {
                cranes[index].phase = .lifting
                cranes[index].phaseTime = 0
            }

        case .lifting:
            let p = mix(stock, stockLifted, eased)
            block.position = SCNVector3(p.x, p.y, p.z)
            poseCrane(at: index,
                      hookWorldPosition: SIMD3(p.x, p.y + 0.20, p.z))
            if t >= 1 {
                cranes[index].phase = .transporting
                cranes[index].phaseTime = 0
            }

        case .transporting:
            let p = mix(stockLifted, targetLifted, eased)
            block.position = SCNVector3(p.x, p.y, p.z)
            poseCrane(at: index,
                      hookWorldPosition: SIMD3(p.x, p.y + 0.20, p.z))
            if t >= 1 {
                if loweringCraneID == nil || loweringCraneID == cranes[index].id {
                    loweringCraneID = cranes[index].id
                    cranes[index].phase = .lowering
                    cranes[index].phaseTime = 0
                } else {
                    cranes[index].phaseTime = duration
                }
            }

        case .lowering:
            guard loweringCraneID == cranes[index].id else { return }
            let p = mix(targetLifted, destination, eased)
            block.position = SCNVector3(p.x, p.y, p.z)
            poseCrane(at: index,
                      hookWorldPosition: SIMD3(p.x, p.y + 0.20, p.z))
            if t >= 1 {
                cranes[index].phase = .releasing
                cranes[index].phaseTime = 0
            }

        case .releasing:
            guard loweringCraneID == cranes[index].id else { return }
            block.position = SCNVector3(destination.x, destination.y, destination.z)

            if t >= 1 {
                // Recheck immediately before committing the placement.
                let failed = placementChecks(target, crane: cranes[index])
                    .filter { !$0.passed }

                if failed.isEmpty || mode == .visualDemo {
                    placedIDs.insert(target.id)
                    reservedIDs.remove(target.id)
                    blockedReasons.removeValue(forKey: target.id)
                    cranes[index].blockNode = nil
                    cranes[index].target = nil
                    cranes[index].phase = .idle
                    cranes[index].phaseTime = 0
                    loweringCraneID = nil
                    statusMessage = "Placed block \(target.id) on course \(target.course)."
                    statusColor = .green
                } else {
                    reservedIDs.remove(target.id)
                    block.removeFromParentNode()
                    cranes[index].blockNode = nil
                    cranes[index].target = nil
                    cranes[index].phase = .idle
                    cranes[index].phaseTime = 0
                    loweringCraneID = nil
                    blockedReasons[target.id] = failed
                        .map { "\($0.name): \($0.detail)" }
                        .joined(separator: "; ")
                    statusMessage = "Placement blocked: \(blockedReasons[target.id] ?? "validation failed")"
                    statusColor = .red
                }
            }
        }
    }

    private func phaseDuration(for phase: LiftPhase) -> Double {
        switch phase {
        case .idle: return 1
        case .pickup: return 0.7
        case .lifting: return 1.2
        case .transporting: return 2.0
        case .lowering: return 1.2
        case .releasing: return 0.5
        }
    }

    // MARK: Crane posing

    private func poseCrane(at index: Int, hookWorldPosition: SIMD3<Float>) {
        let base = cranes[index].base
        let localX = hookWorldPosition.x - base.x
        let localY = hookWorldPosition.y - base.y
        let localZ = hookWorldPosition.z - base.z

        let horizontal = max(0.1, sqrt(localX * localX + localZ * localZ))
        let vertical = localY - boomPivotHeight
        let length = min(
            maximumVisualBoomLength,
            max(1.5, sqrt(horizontal * horizontal + vertical * vertical))
        )

        let yaw = atan2(-localX, -localZ)
        let pitch = atan2(vertical, horizontal)

        cranes[index].pivot.eulerAngles = SCNVector3(pitch, yaw, 0)
        cranes[index].boomArm.position = SCNVector3(0, 0, -length / 2)
        cranes[index].boomArm.scale = SCNVector3(1, 1, length)

        let hookLocal = SIMD3(localX, localY, localZ)
        cranes[index].hook.position = SCNVector3(
            hookLocal.x, hookLocal.y, hookLocal.z
        )

        let tip = SIMD3<Float>(
            -length * sin(yaw) * cos(pitch),
            boomPivotHeight + length * sin(pitch),
            -length * cos(yaw) * cos(pitch)
        )
        let vector = hookLocal - tip
        let cableLength = max(0.12, simd_length(vector))

        cranes[index].cable.geometry = SCNCylinder(
            radius: 0.025, height: CGFloat(cableLength)
        )
        cranes[index].cable.position = SCNVector3(
            (tip.x + hookLocal.x) / 2,
            (tip.y + hookLocal.y) / 2,
            (tip.z + hookLocal.z) / 2
        )
        cranes[index].cable.rotation = rotationFromYAxis(vector)
    }

    // MARK: Placement validation

    private struct Check {
        let name: String
        let passed: Bool
        let detail: String
    }

    private func placementChecks(
        _ target: BlockTarget, crane: CraneRig
    ) -> [Check] {
        let loadKN = target.massKg * 9.81 / 1000
        let reach = Double(horizontalDistance(crane.base, target.position))
        let moment = loadKN * reach

        let momentPass = mode == .visualDemo || moment <= maximumMomentKNm

        return [
            Check(name: "Reach",
                  passed: reach <= maximumReachM,
                  detail: String(format: "%.2f m; limit %.2f m", reach, maximumReachM)),
            Check(name: "Moment",
                  passed: momentPass,
                  detail: String(format: "%.1f kN·m; limit %.1f kN·m", moment, maximumMomentKNm)),
            Check(name: "Support",
                  passed: hasPlacedSupport(for: target),
                  detail: "No qualifying placed support beneath target footprint"),
            Check(name: "Interior",
                  passed: !intersectsReservedInterior(target),
                  detail: "Target intersects a reserved interior cell"),
            Check(name: "Overlap",
                  passed: !overlapsPlacedBlock(target),
                  detail: "Target overlaps a placed stone")
        ]
    }

    private func hasPlacedSupport(for target: BlockTarget) -> Bool {
        if target.course == 0 { return true }

        // The lintel uses the same footprint test against the course below.
        // This checks geometric support only, not the 80-ton load capacity.
        return targets.contains { below in
            below.course == target.course - 1 &&
            placedIDs.contains(below.id) &&
            horizontalFootprintsOverlap(below, target)
        }
    }

    private func intersectsReservedInterior(_ target: BlockTarget) -> Bool {
        isReservedInteriorCell(
            course: target.course,
            gridX: target.gridX,
            gridZ: target.gridZ,
            width: 13 - target.course
        )
    }

    private func overlapsPlacedBlock(_ target: BlockTarget) -> Bool {
        for id in placedIDs {
            guard let other = targets.first(where: { $0.id == id }) else { continue }
            if boxesOverlap(other, target) { return true }
        }
        return false
    }

    private func boxesOverlap(_ a: BlockTarget, _ b: BlockTarget) -> Bool {
        abs(a.position.x - b.position.x) <
            (a.size.x + b.size.x) / 2 - 0.001 &&
        abs(a.position.y - b.position.y) <
            (a.size.y + b.size.y) / 2 - 0.001 &&
        abs(a.position.z - b.position.z) <
            (a.size.z + b.size.z) / 2 - 0.001
    }

    private func horizontalFootprintsOverlap(
        _ a: BlockTarget, _ b: BlockTarget
    ) -> Bool {
        abs(a.position.x - b.position.x) <
            (a.size.x + b.size.x) / 2 &&
        abs(a.position.z - b.position.z) <
            (a.size.z + b.size.z) / 2
    }

    // MARK: Stone geometry and framed blocks

    private func makeStoneGeometry(for target: BlockTarget) -> SCNGeometry {
        let geometry = SCNBox(
            width: CGFloat(target.size.x),
            height: CGFloat(target.size.y),
            length: CGFloat(target.size.z),
            chamferRadius: 0
        )
        geometry.firstMaterial = makeMaterial(
            UIColor(red: 0.72, green: 0.65, blue: 0.51, alpha: 1)
        )
        return geometry
    }

    private func addBlockFrame(to block: SCNNode, target: BlockTarget) {
        let edgeMaterial = SCNMaterial()
        edgeMaterial.diffuse.contents = UIColor.white
        edgeMaterial.emission.contents = UIColor.white
        edgeMaterial.lightingModel = .constant

        let x = target.size.x / 2
        let y = target.size.y / 2
        let z = target.size.z / 2

        let corners: [SIMD3<Float>] = [
            SIMD3(-x, -y, -z), SIMD3(x, -y, -z),
            SIMD3(x, -y, z), SIMD3(-x, -y, z),
            SIMD3(-x, y, -z), SIMD3(x, y, -z),
            SIMD3(x, y, z), SIMD3(-x, y, z)
        ]

        let edges: [(Int, Int)] = [
            (0,1), (1,2), (2,3), (3,0),
            (4,5), (5,6), (6,7), (7,4),
            (0,4), (1,5), (2,6), (3,7)
        ]

        for (a, b) in edges {
            addTimber(
                to: block,
                from: SCNVector3(corners[a].x, corners[a].y, corners[a].z),
                to: SCNVector3(corners[b].x, corners[b].y, corners[b].z),
                radius: 0.018,
                material: edgeMaterial
            )
        }
    }

    // MARK: Displays and reset

    private func refreshCourseStatus() {
        guard let course = lowestUnfinishedCourse() else {
            completedCourseCount = courseCount
            currentCourseLabel = "Complete"
            return
        }

        currentCourseLabel = "\(course)"
        completedCourseCount = Set(
            targets.filter { placedIDs.contains($0.id) }.map(\.course)
        ).count
    }

    private func updateAllDisplays() {
        placedCount = placedIDs.count
        progress = requiredCount > 0
            ? Double(placedCount) / Double(requiredCount) : 0

        craneReadings = cranes.map { crane in
            let mass = crane.target?.massKg ?? 0
            let load = mass * 9.81 / 1000
            let reach = crane.target.map {
                Double(horizontalDistance(crane.base, $0.position))
            } ?? 0
            let moment = load * reach
            let cable = load / max(0.1, cableSegmentCount * cos(cableAngleRadians))
            let horizontalReaction = moment / max(1, reach)
            let joint = hypot(load, horizontalReaction)
            let blocked = crane.target != nil &&
                mode == .engineeringScreen && moment > maximumMomentKNm

            return CraneReading(
                id: crane.id,
                name: crane.name,
                phase: crane.phase.label,
                loadKN: load,
                momentKNm: moment,
                cableKN: cable,
                jointKN: joint,
                isBlocked: blocked,
                detail: blocked
                    ? "Illustrative moment limit exceeded. This is not a certified capacity."
                    : ""
            )
        }

        if let active = cranes.first(where: { $0.phase != .idle }) {
            activePhase = "\(active.name): \(active.phase.label)"
        } else {
            activePhase = "Waiting for eligible target"
        }

        updateStockpileReadings()
    }

    func reset() {
        stop()
        placedIDs.removeAll()
        reservedIDs.removeAll()
        blockedReasons.removeAll()
        loweringCraneID = nil

        blocksRoot.childNodes.forEach { $0.removeFromParentNode() }
        buildTargets()
        buildInteriorGuides()
        buildStockpile()
        buildCranes()

        currentCourseLabel = "0"
        completedCourseCount = 0
        activePhase = "Waiting"
        statusMessage = "Reset complete. Construction plan regenerated."
        statusColor = .cyan

        updateAllDisplays()
        start()
    }

    // MARK: Geometry helpers

    private func addTimber(
        to parent: SCNNode,
        from start: SCNVector3,
        to end: SCNVector3,
        radius: CGFloat,
        material: SCNMaterial
    ) {
        let a = SIMD3<Float>(start.x, start.y, start.z)
        let b = SIMD3<Float>(end.x, end.y, end.z)
        let vector = b - a
        let length = simd_length(vector)
        guard length > 0.001 else { return }

        let geometry = SCNCylinder(radius: radius, height: CGFloat(length))
        geometry.firstMaterial = material

        let beam = SCNNode(geometry: geometry)
        beam.position = SCNVector3(
            (start.x + end.x) / 2,
            (start.y + end.y) / 2,
            (start.z + end.z) / 2
        )
        beam.rotation = rotationFromYAxis(vector)
        parent.addChildNode(beam)
    }

    private func rotationFromYAxis(_ vector: SIMD3<Float>) -> SCNVector4 {
        let yAxis = SIMD3<Float>(0, 1, 0)
        let direction = simd_normalize(vector)
        let dot = max(-1.0, min(1.0, simd_dot(yAxis, direction)))

        if dot > 0.9999 { return SCNVector4(0, 0, 1, 0) }
        if dot < -0.9999 { return SCNVector4(1, 0, 0, Float.pi) }

        let axis = simd_normalize(simd_cross(yAxis, direction))
        return SCNVector4(axis.x, axis.y, axis.z, acos(dot))
    }

    private func makeMaterial(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.85
        return material
    }

    private func horizontalDistance(
        _ a: SIMD3<Float>, _ b: SIMD3<Float>
    ) -> Float {
        let dx = a.x - b.x
        let dz = a.z - b.z
        return sqrt(dx * dx + dz * dz)
    }

    private func mix(
        _ a: SIMD3<Float>, _ b: SIMD3<Float>, _ t: Double
    ) -> SIMD3<Float> {
        let f = Float(t)
        return a + (b - a) * f
    }

    private func smooth(_ t: Double) -> Double {
        let value = min(1, max(0, t))
        return value * value * (3 - 2 * value)
    }
}
