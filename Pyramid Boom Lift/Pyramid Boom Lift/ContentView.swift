
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

                Text("Center-out placement · Four coordinated lifts")
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
                    .autoenablesDefaultLighting,
                    .rendersContinuously
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
                        systemImage: controller.isRunning ? "pause.fill" : "play.fill"
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

                Slider(
                    value: $controller.speed,
                    in: 0.25...300.0,
                    step: 0.25
                )

                Text(String(format: "%.2f×", controller.speed))
                    .font(.caption.monospacedDigit())
                    .frame(width: 60, alignment: .trailing)
            }

            HStack(spacing: 8) {
                metric("Placed", "\(controller.placedCount)")
                metric("Required", "\(controller.requiredCount)")
                metric("Progress", String(format: "%.1f%%", controller.progress * 100))
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
                        forceCard("Joint", String(format: "%.1f kN", reading.jointKN))
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
        }
        .panelStyle()
    }

    private var equationsPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ENGINEERING EQUATIONS")
                .font(.subheadline.bold())

            equation(
                "Load force",
                "F = m × g",
                "Weight force in newtons; g = 9.81 m/s²."
            )

            equation(
                "Boom moment",
                "M = F × r⊥",
                "Load force multiplied by perpendicular distance from the pivot."
            )

            equation(
                "Ideal cable tension",
                "T = F / (n × cos θ)",
                "Idealized moving pulley with n supporting rope segments."
            )

            equation(
                "Joint reaction screen",
                "R ≈ √(F² + H²)",
                "Simplified resultant; actual joints require vector load paths."
            )

            equation(
                "Bearing pressure",
                "p = F / A",
                "Force divided by effective bearing area."
            )

            Text(
                controller.mode == .visualDemo
                ? "Visual mode permits motion even when the illustrative moment screen is exceeded."
                : "Engineering mode blocks targets that exceed the configured moment or reach limits."
            )
            .font(.caption)
            .foregroundStyle(.orange)
        }
        .panelStyle()
    }

    private var pipelinePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONSTRUCTION PIPELINE")
                .font(.subheadline.bold())

            pipelineRow("1", "Establish central datum / obelisk marker")
            pipelineRow("2", "Select the lowest unfinished course")
            pipelineRow("3", "Select the nearest eligible block to the center")
            pipelineRow("4", "Check reach, moment, support and clearance")
            pipelineRow("5", "Engage the block at the stockpile")
            pipelineRow("6", "Lift vertically, then swing toward the target")
            pipelineRow("7", "Lower one block at a time and commit placement")
            pipelineRow("8", "Reserve chamber and passage cells from stone placement")

            Divider().overlay(.white.opacity(0.1))

            statusRow("Active phase", controller.activePhase)
            statusRow(
                "Completed courses",
                "\(controller.completedCourseCount) / \(controller.courseCount)"
            )
            statusRow("Block masses", "10 t base · 2.5 t upper")
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
                Text(title)
                    .font(.caption.bold())

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
                .frame(width: 18, alignment: .leading)

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

// MARK: - Shared View Styling

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

// MARK: - Simulation Types

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

private struct BlockTarget: Identifiable {
    let id: Int
    let course: Int
    let gridX: Int
    let gridZ: Int
    let position: SIMD3<Float>
    let massKg: Double
    let size: SIMD3<Float>
}

private enum LiftPhase {
    case idle
    case pickup
    case lifting
    case transporting
    case lowering
    case releasing

    var label: String {
        switch self {
        case .idle: return "Idle"
        case .pickup: return "Pickup"
        case .lifting: return "Lifting"
        case .transporting: return "Swinging"
        case .lowering: return "Lowering"
        case .releasing: return "Release"
        }
    }
}

private struct CraneRig {
    let id: Int
    let name: String
    let base: SIMD3<Float>

    let root: SCNNode
    let pivot: SCNNode
    let boomArm: SCNNode
    let cable: SCNNode
    let hook: SCNNode
    let counterweight: SCNNode

    let stockpile: SIMD3<Float>

    var target: BlockTarget?
    var blockNode: SCNNode?
    var phase: LiftPhase = .idle
    var phaseTime = 0.0
    var loadKN = 0.0
    var momentKNm = 0.0
    var cableKN = 0.0
    var jointKN = 0.0
    var blockedReason = ""
}

// MARK: - Construction Controller

@MainActor
final class PyramidConstructionController: ObservableObject {
    
    private var stockpileNodes: [Int: [SCNNode]] = [:]
    private var stockpileInventory: [Int: Int] = [:]

    private let blocksPerStockpile = 250
    
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

    let scene = SCNScene()
    let cameraNode = SCNNode()

    private let world = SCNNode()
    private let blocksRoot = SCNNode()
    private let rigsRoot = SCNNode()

    private let tick = 1.0 / 60.0
    private let blockHeight: Float = 0.42
    private let gridSpacing: Float = 0.82

    // Screening values only. They are not certified crane ratings.
    private let maximumMomentKNm = 220.0
    private let maximumReachM = 18.0
    private let cableSegmentCount = 2.0
    private let cableAngleRadians = 0.20

    private let boomPivotHeight: Float = 2.7
    private let maximumVisualBoomLength: Float = 18.0

    private var timer: Timer?
    private var targets: [BlockTarget] = []
    private var placedIDs = Set<Int>()
    private var reservedIDs = Set<Int>()
    private var blockedReasons: [Int: String] = [:]
    private var cranes: [CraneRig] = []
    private var nextTargetID = 0
    private var loweringCraneID: Int?

    private var obeliskNode: SCNNode?
    private var interiorGuideRoot = SCNNode()
    private var stockpileRoot = SCNNode()

    init() {
        buildScene()
        buildObeliskMarker()
        buildTargets()
        buildInteriorGuides()
        buildStockpile()
        buildCranes()
        updateAllDisplays()
        start()
    }

    // MARK: Scene Setup

    private func buildScene() {
        scene.background.contents = UIColor(
            red: 0.035,
            green: 0.055,
            blue: 0.085,
            alpha: 1
        )

        scene.rootNode.addChildNode(world)
        world.addChildNode(blocksRoot)
        world.addChildNode(rigsRoot)

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
            width: 34,
            height: 0.25,
            length: 34,
            chamferRadius: 0
        )
        ground.firstMaterial = makeMaterial(
            UIColor(red: 0.38, green: 0.31, blue: 0.21, alpha: 1)
        )

        let groundNode = SCNNode(geometry: ground)
        groundNode.position = SCNVector3(0, -0.15, 0)
        world.addChildNode(groundNode)

        addGroundGrid()
    }

    private func takeBlockFromStockpile(
        pileID: Int
    ) -> SCNNode? {
        guard var blocks = stockpileNodes[pileID],
              !blocks.isEmpty else {
            return nil
        }

        let block = blocks.removeLast()
        stockpileNodes[pileID] = blocks
        stockpileInventory[pileID] = blocks.count

        // The crane now owns this exact block node.
        block.removeFromParentNode()
        return block
    }

    private func addGroundGrid() {
        let gridMaterial = makeMaterial(UIColor.white.withAlphaComponent(0.07))

        for coordinate in stride(from: -15, through: 15, by: 3) {
            let horizontal = SCNBox(
                width: 30,
                height: 0.012,
                length: 0.012,
                chamferRadius: 0
            )
            horizontal.firstMaterial = gridMaterial

            let horizontalNode = SCNNode(geometry: horizontal)
            horizontalNode.position = SCNVector3(0, 0.002, Float(coordinate))
            world.addChildNode(horizontalNode)

            let vertical = SCNBox(
                width: 0.012,
                height: 0.012,
                length: 30,
                chamferRadius: 0
            )
            vertical.firstMaterial = gridMaterial

            let verticalNode = SCNNode(geometry: vertical)
            verticalNode.position = SCNVector3(Float(coordinate), 0.002, 0)
            world.addChildNode(verticalNode)
        }
    }

    // MARK: Central Obelisk / Datum

    private func buildObeliskMarker() {
        obeliskNode?.removeFromParentNode()

        let root = SCNNode()
        root.name = "Central construction datum"

        let shaft = SCNBox(
            width: 0.48,
            height: 4.0,
            length: 0.48,
            chamferRadius: 0.03
        )
        shaft.firstMaterial = makeMaterial(
            UIColor(red: 0.18, green: 0.55, blue: 0.75, alpha: 0.35)
        )
        shaft.firstMaterial?.transparency = 0.45

        let shaftNode = SCNNode(geometry: shaft)
        shaftNode.position = SCNVector3(0, 2.0, 0)
        root.addChildNode(shaftNode)

        let cap = SCNPyramid(width: 0.65, height: 0.55, length: 0.65)
        cap.firstMaterial = makeMaterial(
            UIColor(red: 0.25, green: 0.75, blue: 0.95, alpha: 0.55)
        )
        cap.firstMaterial?.transparency = 0.55

        let capNode = SCNNode(geometry: cap)
        capNode.position = SCNVector3(0, 4.25, 0)
        root.addChildNode(capNode)

        world.addChildNode(root)
        obeliskNode = root
    }

    // MARK: Target Generation

   
    private func buildTargets() {
        targets.removeAll()
        nextTargetID = 0

        let baseWidth = 13

        for course in 0..<courseCount {
            let width = baseWidth - course
            let offset = Float(width - 1) * gridSpacing / 2
            let y = Float(course) * blockHeight + blockHeight / 2

            for gridX in 0..<width {
                for gridZ in 0..<width {
                    // The chamber roof is one special lintel, not several
                    // ordinary blocks placed over unsupported empty space.
                    if course == 7 && gridX == width / 2 && gridZ == width / 2 {
                        let roofSize = Float(2.7)

                        let roof = BlockTarget(
                            id: nextTargetID,
                            course: course,
                            gridX: gridX,
                            gridZ: gridZ,
                            position: SIMD3<Float>(0, y, 0),
                            massKg: 80_000,
                            size: SIMD3<Float>(
                                roofSize,
                                blockHeight,
                                roofSize
                            )
                        )

                        targets.append(roof)
                        nextTargetID += 1
                        continue
                    }

                    if isReservedInteriorCell(
                        course: course,
                        gridX: gridX,
                        gridZ: gridZ,
                        width: width
                    ) {
                        continue
                    }

                    let blockWidth = gridSpacing * 0.96
                    let massKg = course == 0 ? 10_000.0 : 2_500.0

                    let target = BlockTarget(
                        id: nextTargetID,
                        course: course,
                        gridX: gridX,
                        gridZ: gridZ,
                        position: SIMD3<Float>(
                            Float(gridX) * gridSpacing - offset,
                            y,
                            Float(gridZ) * gridSpacing - offset
                        ),
                        massKg: massKg,
                        size: SIMD3<Float>(
                            blockWidth,
                            blockHeight,
                            blockWidth
                        )
                    )

                    targets.append(target)
                    nextTargetID += 1
                }
            }
        }

        requiredCount = targets.count
        placedCount = 0
        progress = 0
    }

    private func isReservedInteriorCell(
        course: Int,
        gridX: Int,
        gridZ: Int,
        width: Int
    ) -> Bool {
        // Illustrative void only. Real chamber dimensions must be configured.
        guard (4...6).contains(course), width >= 7 else {
            return false
        }

        let center = (width - 1) / 2
        return abs(gridX - center) <= 1 && abs(gridZ - center) <= 1
    }

    // MARK: Interior Guide Geometry

    // MARK: - Interior Chambers, Passages and Airways

 
    private func buildInteriorGuides() {
        interiorGuideRoot.removeFromParentNode()
        interiorGuideRoot = SCNNode()
        interiorGuideRoot.name = "Colored Interior Structures"
        world.addChildNode(interiorGuideRoot)

        func brightMaterial(_ color: UIColor) -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.emission.contents = color
            material.lightingModel = .constant
            material.isDoubleSided = true
            material.transparency = 1.0
            return material
        }

        let red = brightMaterial(
            UIColor(red: 1.0, green: 0.0, blue: 0.015, alpha: 1)
        )
        let orange = brightMaterial(
            UIColor(red: 1.0, green: 0.38, blue: 0.0, alpha: 1)
        )
        let green = brightMaterial(
            UIColor(red: 0.0, green: 1.0, blue: 0.12, alpha: 1)
        )

        func addColoredBlock(
            _ name: String,
            size: SIMD3<Float>,
            center: SIMD3<Float>,
            material: SCNMaterial
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

        // RED: chamber volumes
        addColoredBlock(
            "RED - Lower Chamber",
            size: SIMD3(2.25, 1.15, 2.25),
            center: SIMD3(0, 2.55, 0),
            material: red
        )

        addColoredBlock(
            "RED - Upper Chamber",
            size: SIMD3(1.75, 0.85, 1.75),
            center: SIMD3(0, 4.1, 0),
            material: red
        )

        // ORANGE: passage sections
        addColoredBlock(
            "ORANGE - Horizontal Passage",
            size: SIMD3(4.8, 0.42, 0.48),
            center: SIMD3(-2.7, 2.65, 0),
            material: orange
        )

        addColoredBlock(
            "ORANGE - Connecting Passage",
            size: SIMD3(0.48, 1.7, 0.48),
            center: SIMD3(-4.75, 3.35, 0),
            material: orange
        )

        // GREEN: airway channels
        addColoredBlock(
            "GREEN - North Airway",
            size: SIMD3(0.22, 0.22, 3.4),
            center: SIMD3(0, 4.1, -2.55),
            material: green
        )

        addColoredBlock(
            "GREEN - South Airway",
            size: SIMD3(0.22, 0.22, 3.4),
            center: SIMD3(0, 4.1, 2.55),
            material: green
        )
    }


    // MARK: Stockpile

  


    private func buildStockpile() {
        stockpileRoot.removeFromParentNode()
        stockpileRoot = SCNNode()
        stockpileRoot.name = "Four Corner Stockpiles"
        world.addChildNode(stockpileRoot)

        stockpileNodes.removeAll()
        stockpileInventory.removeAll()

        let positions: [SIMD3<Float>] = [
            SIMD3(-11, 0, -11),
            SIMD3(11, 0, -11),
            SIMD3(-11, 0, 11),
            SIMD3(11, 0, 11)
        ]

        let colors: [UIColor] = [
            .cyan, .orange, .green, .purple
        ]

        for pileID in 0..<4 {
            var nodes: [SCNNode] = []

            for index in 0..<blocksPerStockpile {
                let column = index % 5
                let row = (index / 5) % 5
                let layer = index / 25

                let geometry = SCNBox(
                    width: 0.32,
                    height: 0.22,
                    length: 0.32,
                    chamferRadius: 0.015
                )

                let material = SCNMaterial()
                material.diffuse.contents = colors[pileID]
                material.roughness.contents = 0.95
                geometry.firstMaterial = material

                let node = SCNNode(geometry: geometry)

                node.position = SCNVector3(
                    positions[pileID].x + (Float(column) - 2) * 0.34,
                    0.11 + Float(layer) * 0.23,
                    positions[pileID].z + (Float(row) - 2) * 0.34
                )

                node.name = "Pile\(pileID)_Block\(index)"
                stockpileRoot.addChildNode(node)
                nodes.append(node)
            }

            stockpileNodes[pileID] = nodes
            stockpileInventory[pileID] = nodes.count
        }
    }


    // MARK: Timber Boom Lifts

    private func buildCranes() {
        cranes.removeAll()
        rigsRoot.childNodes.forEach { $0.removeFromParentNode() }

        let configurations: [(String, SIMD3<Float>)] = [
            ("Crane A · NW", SIMD3<Float>(-8, 0, -8)),
            ("Crane B · NE", SIMD3<Float>(8, 0, -8)),
            ("Crane C · SW", SIMD3<Float>(-8, 0, 8)),
            ("Crane D · SE", SIMD3<Float>(8, 0, 8))
        ]

        let timber = makeMaterial(
            UIColor(red: 0.42, green: 0.25, blue: 0.12, alpha: 1)
        )
        let ropeMaterial = makeMaterial(
            UIColor(red: 0.20, green: 0.16, blue: 0.12, alpha: 1)
        )

        for (index, configuration) in configurations.enumerated() {
            let root = SCNNode()
            root.name = configuration.0
            root.position = SCNVector3(
                configuration.1.x,
                configuration.1.y,
                configuration.1.z
            )
            rigsRoot.addChildNode(root)

            let baseGeometry = SCNBox(
                width: 1.2,
                height: 0.6,
                length: 1.2,
                chamferRadius: 0.04
            )
            baseGeometry.firstMaterial = timber

            let baseNode = SCNNode(geometry: baseGeometry)
            baseNode.position = SCNVector3(0, 0.3, 0)
            root.addChildNode(baseNode)

            // Crossed timber legs.
            addTimber(
                to: root,
                from: SCNVector3(-0.48, 0.6, -0.48),
                to: SCNVector3(0.48, 3.1, 0.48),
                radius: 0.13,
                material: timber
            )

            addTimber(
                to: root,
                from: SCNVector3(0.48, 0.6, -0.48),
                to: SCNVector3(-0.48, 3.1, 0.48),
                radius: 0.13,
                material: timber
            )

            let pivot = SCNNode()
            pivot.name = "Rotating boom pivot"
            pivot.position = SCNVector3(0, boomPivotHeight, 0)
            root.addChildNode(pivot)

            // Main arm is a unit-length box scaled along its local Z axis.
            let armGeometry = SCNBox(
                width: 0.30,
                height: 0.30,
                length: 1.0,
                chamferRadius: 0.04
            )
            armGeometry.firstMaterial = timber

            let boomArm = SCNNode(geometry: armGeometry)
            boomArm.name = "Telescoping timber boom"
            boomArm.position = SCNVector3(0, 0, -2.9)
            boomArm.scale = SCNVector3(1, 1, 5.8)
            pivot.addChildNode(boomArm)

            // Bracing stays attached to the pivot; the main arm changes reach.
            addTimber(
                to: pivot,
                from: SCNVector3(0, -1.8, 0.6),
                to: SCNVector3(0, 0, -5.8),
                radius: 0.10,
                material: timber
            )

            let counterweightGeometry = SCNBox(
                width: 0.85,
                height: 0.6,
                length: 0.85,
                chamferRadius: 0.03
            )
            counterweightGeometry.firstMaterial = makeMaterial(.darkGray)

            let counterweight = SCNNode(geometry: counterweightGeometry)
            counterweight.name = "Illustrative counterweight"
            counterweight.position = SCNVector3(0, -0.15, 1.05)
            pivot.addChildNode(counterweight)

            let cable = SCNNode(
                geometry: SCNCylinder(radius: 0.025, height: 1)
            )
            cable.name = "Suspension cable"
            cable.geometry?.firstMaterial = ropeMaterial
            root.addChildNode(cable)

            let hookGeometry = SCNTorus(
                ringRadius: 0.14,
                pipeRadius: 0.035
            )
            hookGeometry.firstMaterial = makeMaterial(.orange)

            let hook = SCNNode(geometry: hookGeometry)
            hook.name = "Moving hook"
            root.addChildNode(hook)

            let stockpile = SIMD3<Float>(
                11.0,
                0.4,
                Float(index - 2) * 0.9
            )

            cranes.append(
                CraneRig(
                    id: index,
                    name: configuration.0,
                    base: configuration.1,
                    root: root,
                    pivot: pivot,
                    boomArm: boomArm,
                    cable: cable,
                    hook: hook,
                    counterweight: counterweight,
                    stockpile: stockpile
                )
            )
        }
    }

    // MARK: Timer

    func start() {
        guard timer == nil else {
            isRunning = true
            return
        }

        isRunning = true

        let newTimer = Timer(timeInterval: tick, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.step()
            }
        }

        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)

        statusMessage = mode == .visualDemo
            ? "Visual demo running. Crane capacity is not certified."
            : "Engineering screen active. Moment and reach limits are enforced."

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
            ? "Visual demo: moment screening may be bypassed for animation."
            : "Engineering screen: moment and reach limits are enforced."

        statusColor = newMode == .visualDemo ? .orange : .cyan
    }

    // MARK: Simulation Step

    private func step() {
        guard isRunning else { return }

        let deltaTime = tick * speed

        for index in cranes.indices {
            advanceCrane(at: index, deltaTime: deltaTime)
        }

        assignAvailableCrane()
        refreshCourseStatus()
        updateAllDisplays()

        if placedCount >= requiredCount {
            stop()
            statusMessage = "All generated target blocks have been placed."
            statusColor = .green
        }
    }

    // MARK: Construction Scheduler

    private func lowestUnfinishedCourse() -> Int? {
        targets
            .filter { !placedIDs.contains($0.id) }
            .map(\.course)
            .min()
    }

    private func assignAvailableCrane() {
        guard let course = lowestUnfinishedCourse() else {
            return
        }

        currentCourseLabel = "\(course)"

        for index in cranes.indices where cranes[index].phase == .idle {
            if let target = chooseNextTarget(
                forCraneAt: index,
                course: course
            ) {
                assign(target, toCraneAt: index)
            }
        }

        let remaining = targets.filter {
            $0.course == course && !placedIDs.contains($0.id)
        }

        if !remaining.isEmpty,
           !cranes.contains(where: { $0.phase != .idle }) {
            let details = remaining.prefix(4).compactMap {
                blockedReasons[$0.id]
            }

            if !details.isEmpty {
                statusMessage = "Course \(course) blocked: \(details.joined(separator: " | "))"
                statusColor = .red
            } else {
                statusMessage = "Course \(course): waiting for an eligible crane."
                statusColor = .orange
            }
        }
    }

    private func chooseNextTarget(
        forCraneAt index: Int,
        course: Int
    ) -> BlockTarget? {
        let crane = cranes[index]

        // Within the lowest unfinished course, prefer targets closest to the
        // center first, then select the target the crane can reach.
        let candidates = targets
            .filter {
                $0.course == course
                    && !placedIDs.contains($0.id)
                    && !reservedIDs.contains($0.id)
            }
            .sorted { a, b in
                let radiusA = a.position.x * a.position.x + a.position.z * a.position.z
                let radiusB = b.position.x * b.position.x + b.position.z * b.position.z

                if abs(radiusA - radiusB) > 0.001 {
                    return radiusA < radiusB
                }

                return horizontalDistance(crane.base, a.position)
                    < horizontalDistance(crane.base, b.position)
            }

        for target in candidates {
            let checks = placementChecks(target, crane: crane)

            if checks.allSatisfy(\.passed) {
                return target
            }

            blockedReasons[target.id] = checks
                .filter { !$0.passed }
                .map { "\($0.name): \($0.detail)" }
                .joined(separator: "; ")
        }

        return nil
    }

    private func assign(_ target: BlockTarget, toCraneAt index: Int) {
        guard !reservedIDs.contains(target.id),
              !placedIDs.contains(target.id) else {
            return
        }

        reservedIDs.insert(target.id)
        blockedReasons.removeValue(forKey: target.id)

        cranes[index].target = target
        cranes[index].phase = .pickup
        cranes[index].phaseTime = 0

        let block = makeBlockNode(for: target)
        block.position = SCNVector3(
            cranes[index].stockpile.x,
            cranes[index].stockpile.y,
            cranes[index].stockpile.z
        )

        blocksRoot.addChildNode(block)
        cranes[index].blockNode = block

        poseCrane(
            at: index,
            hookWorldPosition: SIMD3<Float>(
                cranes[index].stockpile.x,
                cranes[index].stockpile.y + 0.25,
                cranes[index].stockpile.z
            )
        )

        statusMessage = "\(cranes[index].name) assigned block \(target.id), course \(target.course)."
        statusColor = .cyan
    }

    // MARK: Lift Sequence

    private func advanceCrane(at index: Int, deltaTime: Double) {
        guard let target = cranes[index].target,
              let block = cranes[index].blockNode else {
            return
        }

        cranes[index].phaseTime += deltaTime

        let duration = phaseDuration(for: cranes[index].phase)
        let t = min(1.0, cranes[index].phaseTime / duration)
        let eased = smooth(t)

        let stock = cranes[index].stockpile
        let destination = target.position
        let clearance: Float = 2.0

        let stockLifted = SIMD3<Float>(
            stock.x,
            stock.y + clearance,
            stock.z
        )

        let targetLifted = SIMD3<Float>(
            destination.x,
            destination.y + clearance,
            destination.z
        )

        switch cranes[index].phase {
        case .idle:
            return

        case .pickup:
            // Keep the stone at the stockpile while the hook engages.
            block.position = SCNVector3(stock.x, stock.y, stock.z)

            poseCrane(
                at: index,
                hookWorldPosition: SIMD3<Float>(
                    stock.x,
                    stock.y + 0.25,
                    stock.z
                )
            )

            if t >= 1 {
                cranes[index].phase = .lifting
                cranes[index].phaseTime = 0
            }

        case .lifting:
            let position = mix(stock, stockLifted, eased)
            block.position = SCNVector3(position.x, position.y, position.z)

            poseCrane(
                at: index,
                hookWorldPosition: SIMD3<Float>(
                    position.x,
                    position.y + 0.20,
                    position.z
                )
            )

            if t >= 1 {
                cranes[index].phase = .transporting
                cranes[index].phaseTime = 0
            }

        case .transporting:
            let position = mix(stockLifted, targetLifted, eased)
            block.position = SCNVector3(position.x, position.y, position.z)

            poseCrane(
                at: index,
                hookWorldPosition: SIMD3<Float>(
                    position.x,
                    position.y + 0.20,
                    position.z
                )
            )

            if t >= 1 {
                // Reserve the final lowering operation for one crane.
                if loweringCraneID == nil || loweringCraneID == cranes[index].id {
                    loweringCraneID = cranes[index].id
                    cranes[index].phase = .lowering
                    cranes[index].phaseTime = 0
                } else {
                    // Hold above the target while another crane finishes.
                    cranes[index].phaseTime = duration
                }
            }

        case .lowering:
            guard loweringCraneID == cranes[index].id else {
                return
            }

            let position = mix(targetLifted, destination, eased)
            block.position = SCNVector3(position.x, position.y, position.z)

            poseCrane(
                at: index,
                hookWorldPosition: SIMD3<Float>(
                    position.x,
                    position.y + 0.20,
                    position.z
                )
            )

            if t >= 1 {
                cranes[index].phase = .releasing
                cranes[index].phaseTime = 0
            }

        case .releasing:
            guard loweringCraneID == cranes[index].id else {
                return
            }

            block.position = SCNVector3(
                destination.x,
                destination.y,
                destination.z
            )

            if t >= 1 {
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

    // MARK: Boom, Cable and Hook Motion

    private func poseCrane(
        at index: Int,
        hookWorldPosition: SIMD3<Float>
    ) {
        let base = cranes[index].base

        // Convert world coordinates into this crane's local coordinates.
        let localX = hookWorldPosition.x - base.x
        let localY = hookWorldPosition.y - base.y
        let localZ = hookWorldPosition.z - base.z

        let horizontal = max(0.1, sqrt(localX * localX + localZ * localZ))
        let verticalFromPivot = localY - boomPivotHeight

        let requiredLength = sqrt(
            horizontal * horizontal
                + verticalFromPivot * verticalFromPivot
        )

        let boomLength = min(
            maximumVisualBoomLength,
            max(1.5, requiredLength)
        )

        // The boom points along its local -Z axis.
        let yaw = atan2(-localX, -localZ)
        let pitch = atan2(verticalFromPivot, horizontal)

        cranes[index].pivot.eulerAngles = SCNVector3(pitch, yaw, 0)
        cranes[index].boomArm.position = SCNVector3(
            0,
            0,
            -boomLength / 2
        )
        cranes[index].boomArm.scale = SCNVector3(1, 1, boomLength)

        // The cable and hook are children of the crane root, so their positions
        // can be set directly in crane-local coordinates.
        let hookLocal = SIMD3<Float>(localX, localY, localZ)
        cranes[index].hook.position = SCNVector3(
            hookLocal.x,
            hookLocal.y,
            hookLocal.z
        )

        // Cable begins at the actual boom tip, not at a fixed arbitrary point.
        let boomTip = SIMD3<Float>(
            -boomLength * sin(yaw) * cos(pitch),
            boomPivotHeight + boomLength * sin(pitch),
            -boomLength * cos(yaw) * cos(pitch)
        )

        let cableVector = hookLocal - boomTip
        let cableLength = max(0.12, simd_length(cableVector))

        cranes[index].cable.geometry = SCNCylinder(
            radius: 0.025,
            height: CGFloat(cableLength)
        )

        cranes[index].cable.position = SCNVector3(
            (boomTip.x + hookLocal.x) / 2,
            (boomTip.y + hookLocal.y) / 2,
            (boomTip.z + hookLocal.z) / 2
        )

        cranes[index].cable.rotation = rotationFromYAxis(cableVector)
    }

    // MARK: Placement Checks

    private struct Check {
        let name: String
        let passed: Bool
        let detail: String
    }

    private func placementChecks(
        _ target: BlockTarget,
        crane: CraneRig
    ) -> [Check] {
        let loadKN = target.massKg * 9.81 / 1000
        let reach = Double(horizontalDistance(crane.base, target.position))
        let moment = loadKN * reach

        let reachPass = reach <= maximumReachM

        let momentPass: Bool
        switch mode {
        case .visualDemo:
            momentPass = true
        case .engineeringScreen:
            momentPass = moment <= maximumMomentKNm
        }

        return [
            Check(
                name: "Reach",
                passed: reachPass,
                detail: String(format: "%.2f m; limit %.2f m", reach, maximumReachM)
            ),
            Check(
                name: "Moment",
                passed: momentPass,
                detail: String(
                    format: "%.1f kN·m required; limit %.1f kN·m",
                    moment,
                    maximumMomentKNm
                )
            ),
            Check(
                name: "Support",
                passed: hasPlacedSupport(for: target),
                detail: "Requires an overlapping placed block below"
            ),
            Check(
                name: "Clearance",
                passed: !intersectsReservedInterior(target),
                detail: "Reserved interior cells cannot receive stone"
            ),
            Check(
                name: "Overlap",
                passed: !overlapsPlacedBlock(target),
                detail: "Placed block geometry must not overlap"
            )
        ]
    }

    private func hasPlacedSupport(for target: BlockTarget) -> Bool {
        if target.course == 0 {
            return true
        }

        return targets.contains { below in
            below.course == target.course - 1
                && placedIDs.contains(below.id)
                && horizontalFootprintsOverlap(below, target)
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
        for placedID in placedIDs {
            guard let other = targets.first(where: { $0.id == placedID }) else {
                continue
            }

            if boxesOverlap(other, target) {
                return true
            }
        }

        return false
    }

    private func boxesOverlap(_ a: BlockTarget, _ b: BlockTarget) -> Bool {
        let dx = abs(a.position.x - b.position.x)
        let dy = abs(a.position.y - b.position.y)
        let dz = abs(a.position.z - b.position.z)

        return dx < (a.size.x + b.size.x) / 2 - 0.001
            && dy < (a.size.y + b.size.y) / 2 - 0.001
            && dz < (a.size.z + b.size.z) / 2 - 0.001
    }

    private func horizontalFootprintsOverlap(
        _ a: BlockTarget,
        _ b: BlockTarget
    ) -> Bool {
        abs(a.position.x - b.position.x) < (a.size.x + b.size.x) / 2
            && abs(a.position.z - b.position.z) < (a.size.z + b.size.z) / 2
    }

    // MARK: Block Geometry

    private func makeBlockNode(for target: BlockTarget) -> SCNNode {
        let w = CGFloat(target.size.x)
        let h = CGFloat(target.size.y)
        let d = CGFloat(target.size.z)

        let stoneMaterial = makeMaterial(
            UIColor(red: 0.72, green: 0.65, blue: 0.51, alpha: 1)
        )

        let geometry = SCNBox(
            width: w,
            height: h,
            length: d,
            chamferRadius: 0
        )
        geometry.firstMaterial = stoneMaterial

        let block = SCNNode(geometry: geometry)
        block.name = "stone-\(target.id)"

        let edgeMaterial = SCNMaterial()
        edgeMaterial.diffuse.contents = UIColor.white
        edgeMaterial.emission.contents = UIColor.white
        edgeMaterial.lightingModel = .constant

        let edgeRadius: CGFloat = 0.018

        func addEdge(_ a: SIMD3<Float>, _ b: SIMD3<Float>) {
            let start = SCNVector3(a.x, a.y, a.z)
            let end = SCNVector3(b.x, b.y, b.z)

            addTimber(
                to: block,
                from: start,
                to: end,
                radius: edgeRadius,
                material: edgeMaterial
            )
        }

        let x = Float(w / 2)
        let y = Float(h / 2)
        let z = Float(d / 2)

        let corners: [SIMD3<Float>] = [
            SIMD3(-x, -y, -z), SIMD3(x, -y, -z),
            SIMD3(x, -y, z), SIMD3(-x, -y, z),
            SIMD3(-x, y, -z), SIMD3(x, y, -z),
            SIMD3(x, y, z), SIMD3(-x, y, z)
        ]

        let edges: [(Int, Int)] = [
            (0, 1), (1, 2), (2, 3), (3, 0),
            (4, 5), (5, 6), (6, 7), (7, 4),
            (0, 4), (1, 5), (2, 6), (3, 7)
        ]

        for (a, b) in edges {
            addEdge(corners[a], corners[b])
        }

        return block
    }

    // MARK: Displays and Course State

    private func refreshCourseStatus() {
        guard let course = lowestUnfinishedCourse() else {
            completedCourseCount = courseCount
            currentCourseLabel = "Complete"
            return
        }

        currentCourseLabel = "\(course)"

        completedCourseCount = Set(
            targets
                .filter { placedIDs.contains($0.id) }
                .map(\.course)
        ).count
    }

    private func updateAllDisplays() {
        placedCount = placedIDs.count
        progress = requiredCount > 0
            ? Double(placedCount) / Double(requiredCount)
            : 0

        craneReadings = cranes.map { crane in
            let massKg = crane.target?.massKg ?? 0
            let loadKN = massKg * 9.81 / 1000

            let reach = crane.target.map {
                Double(horizontalDistance(crane.base, $0.position))
            } ?? 0

            let moment = loadKN * reach

            // Idealized pulley tension; does not include friction or dynamics.
            let cableTension = loadKN / max(
                0.1,
                cableSegmentCount * cos(cableAngleRadians)
            )

            // Simple displayed resultant estimate, not a joint stress analysis.
            let horizontalReaction = moment / max(1.0, reach)
            let jointReaction = hypot(loadKN, horizontalReaction)

            let blocked = crane.phase != .idle
                && crane.target != nil
                && mode == .engineeringScreen
                && moment > maximumMomentKNm

            return CraneReading(
                id: crane.id,
                name: crane.name,
                phase: crane.phase.label,
                loadKN: loadKN,
                momentKNm: moment,
                cableKN: cableTension,
                jointKN: jointReaction,
                isBlocked: blocked,
                detail: blocked
                    ? "Illustrative moment limit exceeded. Motion is already in progress only if mode was changed mid-cycle."
                    : ""
            )
        }

        if let active = cranes.first(where: { $0.phase != .idle }) {
            activePhase = "\(active.name): \(active.phase.label)"
        } else {
            activePhase = "Waiting for eligible target"
        }
    }

    // MARK: Reset

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

    // MARK: Geometry Helpers

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

        let geometry = SCNCylinder(
            radius: radius,
            height: CGFloat(length)
        )
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

        if dot > 0.9999 {
            return SCNVector4(0, 0, 1, 0)
        }

        if dot < -0.9999 {
            return SCNVector4(1, 0, 0, Double.pi)
        }

        let axis = simd_normalize(simd_cross(yAxis, direction))
        return SCNVector4(axis.x, axis.y, axis.z, acos(dot))
    }

    private func makeMaterial(_ color: UIColor) -> SCNMaterial {
        let result = SCNMaterial()
        result.diffuse.contents = color
        result.lightingModel = .physicallyBased
        result.roughness.contents = 0.85
        return result
    }

    private func horizontalDistance(
        _ a: SIMD3<Float>,
        _ b: SIMD3<Float>
    ) -> Float {
        let dx = a.x - b.x
        let dz = a.z - b.z
        return sqrt(dx * dx + dz * dz)
    }

    private func mix(
        _ a: SIMD3<Float>,
        _ b: SIMD3<Float>,
        _ t: Double
    ) -> SIMD3<Float> {
        let fraction = Float(t)
        return a + (b - a) * fraction
    }

    private func smooth(_ t: Double) -> Double {
        let value = min(1, max(0, t))
        return value * value * (3 - 2 * value)
    }
}
