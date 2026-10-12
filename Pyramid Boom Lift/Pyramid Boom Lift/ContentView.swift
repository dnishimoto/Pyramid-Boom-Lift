import SwiftUI
import SceneKit
import UIKit

// MARK: - Content View

struct ContentView: View {
    @State private var isRunning = true
    @State private var speed = 1.0
    @State private var resetID = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PYRAMID CONSTRUCTION")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Obelisk first → outward + chambers / passages / airways")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Circle()
                    .fill(isRunning ? Color.green : Color.orange)
                    .frame(width: 9, height: 9)
                Text(isRunning ? "RUNNING" : "PAUSED")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .padding()

            PyramidConstructionView(
                isRunning: $isRunning,
                speed: $speed,
                resetID: resetID
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Button {
                        isRunning.toggle()
                    } label: {
                        Label(
                            isRunning ? "Pause" : "Resume",
                            systemImage: isRunning ? "pause.fill" : "play.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        isRunning = false
                        resetID += 1
                        isRunning = true
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                HStack {
                    Text("Speed")
                    Slider(value: $speed, in: 0.25...3.0)
                    Text(String(format: "%.2fx", speed))
                        .monospacedDigit()
                        .frame(width: 55, alignment: .trailing)
                }
                .font(.caption)

                Text("Sequence: Subterranean already present → Obelisk → Outward courses + chambers / passages / airways")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Construction Dimensions

private enum ConstructionDimensions {
    static let obeliskHeightFeet: Double = 486
    static let baseWidthFeet: Double = 785
    static let feetPerUnit: Double = 50

    static let obeliskHeight: Float = Float(obeliskHeightFeet / feetPerUnit)
    static let baseWidth: Float = Float(baseWidthFeet / feetPerUnit)

    static let courseCount = 16
    static let coreBlockCount = 28          // taller slender shaft
    static let benbenLevels = 3

    static let blockHeight: Float = 0.20
    static let blockWidth: Float = 0.36
    static let blockDepth: Float = 0.30
}

// MARK: - CA Placement Model

private struct BlockPlacement {
    let id: Int
    let course: Int                 // -1 = core/obelisk, -2 = benben, >=0 = outer course
    let position: SCNVector3
    let dimensions: SCNVector3
    let rotationY: Float
    let assignedLiftID: Int
    let isCoreBlock: Bool
    let isBenben: Bool
    let isChamberFeature: Bool      // passage / chamber / airway marker
}

// MARK: - Construction Cellular Automaton
// Source of truth for every destination.
// Order is strictly: Obelisk (bottom→top) → Benben → Outward courses
// while chambers / passages / airways are inserted as the structure expands.

private final class ConstructionCA {
    private(set) var placements: [BlockPlacement] = []

    init() {
        generatePlan()
    }

    private func generatePlan() {
        placements.removeAll()
        var nextID = 0

        // -------------------------------------------------
        // PHASE 1 – Central obelisk (bottom to top)
        // -------------------------------------------------
        let coreHeight = ConstructionDimensions.obeliskHeight
        let segmentHeight = coreHeight / Float(ConstructionDimensions.coreBlockCount)

        for level in 0..<ConstructionDimensions.coreBlockCount {
            let y = segmentHeight * (Float(level) + 0.5)
            // Slight taper so the shaft looks more like an obelisk
            let taper = 1.0 - Float(level) / Float(ConstructionDimensions.coreBlockCount) * 0.25
            let size: Float = 0.72 * taper

            append(
                id: &nextID,
                course: -1,
                position: SCNVector3(0, y, 0),
                dimensions: SCNVector3(size, segmentHeight * 0.98, size),
                rotationY: 0,
                isCore: true,
                isBenben: false,
                isChamberFeature: false
            )
        }

        // -------------------------------------------------
        // PHASE 1b – Benben (pyramidion) on top of the obelisk
        // -------------------------------------------------
        let benbenBaseY = coreHeight + 0.05
        for level in 0..<ConstructionDimensions.benbenLevels {
            let y = benbenBaseY + Float(level) * 0.22
            let half = 0.55 - Float(level) * 0.18
            for dx in [-half, 0, half] {
                for dz in [-half, 0, half] {
                    if abs(dx) + abs(dz) > half * 1.6 { continue }
                    append(
                        id: &nextID,
                        course: -2,
                        position: SCNVector3(dx, y, dz),
                        dimensions: SCNVector3(0.32, 0.20, 0.32),
                        rotationY: 0,
                        isCore: true,
                        isBenben: true,
                        isChamberFeature: false
                    )
                }
            }
        }

        // -------------------------------------------------
        // PHASE 2 – Outward stepped masonry + internal features
        // Lower courses extend farther; upper courses are narrower.
        // Chambers / passages / airways are added as the courses rise.
        // -------------------------------------------------
        for course in 0..<ConstructionDimensions.courseCount {
            let fraction = Float(course) / Float(max(1, ConstructionDimensions.courseCount - 1))
            let halfWidth = ConstructionDimensions.baseWidth * 0.5 * (1.0 - 0.72 * fraction)
            let y = 0.25 + Float(course) * ConstructionDimensions.blockHeight
            let spacing = ConstructionDimensions.blockWidth
            let count = max(4, Int((halfWidth * 2) / spacing))

            // Perimeter rows (front / back / left / right)
            for i in 0..<count {
                let x = -halfWidth + (Float(i) + 0.5) * (2 * halfWidth / Float(count))

                // Front & back
                append(id: &nextID, course: course,
                       position: SCNVector3(x, y, -halfWidth),
                       dimensions: SCNVector3(spacing, 0.20, spacing),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: false)
                append(id: &nextID, course: course,
                       position: SCNVector3(x, y, halfWidth),
                       dimensions: SCNVector3(spacing, 0.20, spacing),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: false)
            }

            for i in 1..<max(2, count - 1) {
                let z = -halfWidth + (Float(i) + 0.5) * (2 * halfWidth / Float(count))
                append(id: &nextID, course: course,
                       position: SCNVector3(-halfWidth, y, z),
                       dimensions: SCNVector3(spacing, 0.20, spacing),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: false)
                append(id: &nextID, course: course,
                       position: SCNVector3(halfWidth, y, z),
                       dimensions: SCNVector3(spacing, 0.20, spacing),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: false)
            }

            // ---------- Internal features that appear while expanding ----------
            // These are placed only after the obelisk is finished and as the
            // surrounding masonry reaches the appropriate height.

            // Ascending passage / Grand Gallery corridor (appears mid-height)
            if course == 5 || course == 6 || course == 7 {
                append(id: &nextID, course: course,
                       position: SCNVector3(0, y + 0.05, 0.9),
                       dimensions: SCNVector3(0.55, 0.45, 1.8),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: true)
            }

            // Queen's Chamber region
            if course == 4 {
                append(id: &nextID, course: course,
                       position: SCNVector3(0, y + 0.15, -1.4),
                       dimensions: SCNVector3(1.6, 0.9, 1.4),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: true)
            }

            // King's Chamber region + short horizontal approach
            if course == 9 {
                append(id: &nextID, course: course,
                       position: SCNVector3(0, y + 0.2, -2.1),
                       dimensions: SCNVector3(2.2, 1.1, 1.3),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: true)
            }

            // Air shafts (north / south) appearing higher up
            if course == 10 || course == 11 {
                append(id: &nextID, course: course,
                       position: SCNVector3(0.15, y + 0.3, -3.0),
                       dimensions: SCNVector3(0.22, 0.22, 1.6),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: true)
                append(id: &nextID, course: course,
                       position: SCNVector3(-0.15, y + 0.3, 2.6),
                       dimensions: SCNVector3(0.22, 0.22, 1.4),
                       rotationY: 0, isCore: false, isBenben: false, isChamberFeature: true)
            }
        }
    }

    private func append(
        id: inout Int,
        course: Int,
        position: SCNVector3,
        dimensions: SCNVector3,
        rotationY: Float,
        isCore: Bool,
        isBenben: Bool,
        isChamberFeature: Bool
    ) {
        // Core / benben blocks prefer lifts 0 & 1; outer blocks use all four.
        let liftID: Int
        if isCore || isBenben {
            liftID = id % 2
        } else {
            liftID = id % 4
        }

        placements.append(
            BlockPlacement(
                id: id,
                course: course,
                position: position,
                dimensions: dimensions,
                rotationY: rotationY,
                assignedLiftID: liftID,
                isCoreBlock: isCore,
                isBenben: isBenben,
                isChamberFeature: isChamberFeature
            )
        )
        id += 1
    }

    /// Returns the next placement that is allowed under the current construction phase.
    func nextPlacement(for liftID: Int, completed: Set<Int>) -> BlockPlacement? {
        // 1. Finish every core / benben block first.
        if let core = placements.first(where: {
            ($0.isCoreBlock || $0.isBenben) &&
            $0.assignedLiftID == liftID &&
            !completed.contains($0.id)
        }) {
            return core
        }

        // 2. Only after the entire obelisk + benben are done, release outer work.
        let coreRemaining = placements.contains { ($0.isCoreBlock || $0.isBenben) && !completed.contains($0.id) }
        if coreRemaining { return nil }

        // 3. Outer courses + chamber features, lowest course first.
        return placements
            .filter { !$0.isCoreBlock && !$0.isBenben && $0.assignedLiftID == liftID && !completed.contains($0.id) }
            .sorted { $0.course < $1.course }
            .first
    }
}

// MARK: - SceneKit View

private struct PyramidConstructionView: UIViewRepresentable {
    @Binding var isRunning: Bool
    @Binding var speed: Double
    let resetID: Int

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = SCNScene()
        view.backgroundColor = UIColor(red: 0.88, green: 0.81, blue: 0.68, alpha: 1)
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        context.coordinator.attach(to: view)
        context.coordinator.rebuild()
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        let c = context.coordinator
        c.setRunning(isRunning)
        c.setSpeed(speed)
        if c.lastResetID != resetID {
            c.lastResetID = resetID
            c.rebuild()
            c.setRunning(isRunning)
            c.setSpeed(speed)
        }
    }

    final class Coordinator {
        private weak var view: SCNView?
        private var scene: SCNScene?
        private let ca = ConstructionCA()

        private var placedBlocks = 0
        private var running = true
        private var animationSpeed: Double = 1.0
        var lastResetID = 0

        private var craneNodes: [SCNNode] = []
        private var cranePivots: [SCNNode] = []
        private var statusNode: SCNNode?
        private var completedPlacementIDs = Set<Int>()

        func attach(to view: SCNView) { self.view = view }

        func setRunning(_ value: Bool) {
            running = value
            guard let scene else { return }
            scene.rootNode.enumerateChildNodes { node, _ in
                node.isPaused = !value
            }
            if value { startAvailableLifts() }
        }

        func setSpeed(_ value: Double) {
            animationSpeed = max(0.25, min(3.0, value))
        }

        func rebuild() {
            guard let view else { return }
            let scene = SCNScene()
            self.scene = scene
            view.scene = scene

            placedBlocks = 0
            completedPlacementIDs.removeAll()
            craneNodes.removeAll()
            cranePivots.removeAll()

            buildEnvironment(scene)
            buildCamera(scene)
            buildSubterraneanChamber(scene)   // already present before construction
            buildObeliskFooting(scene)
            buildCranes(scene)
            buildStatus(scene)
            startAvailableLifts()
        }

        // MARK: - Environment

        private func buildEnvironment(_ scene: SCNScene) {
            let ground = SCNFloor()
            ground.reflectivity = 0
            ground.firstMaterial?.diffuse.contents = UIColor(red: 0.72, green: 0.61, blue: 0.44, alpha: 1)
            let groundNode = SCNNode(geometry: ground)
            groundNode.position.y = -0.12
            scene.rootNode.addChildNode(groundNode)

            let ambient = SCNNode()
            let al = SCNLight(); al.type = .ambient; al.intensity = 500
            ambient.light = al
            scene.rootNode.addChildNode(ambient)

            let sun = SCNNode()
            let dl = SCNLight(); dl.type = .directional; dl.intensity = 900; dl.castsShadow = true
            sun.light = dl
            sun.eulerAngles = SCNVector3(-0.8, 0.5, 0)
            scene.rootNode.addChildNode(sun)
        }

        private func buildCamera(_ scene: SCNScene) {
            let camera = SCNCamera()
            camera.fieldOfView = 55
            camera.zFar = 300
            let node = SCNNode()
            node.camera = camera
            node.position = SCNVector3(0, 10, 24)
            node.look(at: SCNVector3(0, 4.5, 0))
            scene.rootNode.addChildNode(node)
        }

        // MARK: - Subterranean chamber (pre-existing)

        private func buildSubterraneanChamber(_ scene: SCNScene) {
            // Rough unfinished chamber already cut into the bedrock
            let chamber = SCNBox(width: 2.8, height: 1.4, length: 2.2, chamferRadius: 0.04)
            chamber.firstMaterial?.diffuse.contents = UIColor(red: 0.22, green: 0.18, blue: 0.15, alpha: 1)
            chamber.firstMaterial?.emission.contents = UIColor(white: 0.08, alpha: 1)
            let node = SCNNode(geometry: chamber)
            node.position = SCNVector3(0, -1.1, 0.3)
            scene.rootNode.addChildNode(node)

            // Short descending passage stub leading to it
            let passage = SCNBox(width: 0.55, height: 0.7, length: 2.4, chamferRadius: 0.02)
            passage.firstMaterial?.diffuse.contents = UIColor(red: 0.28, green: 0.24, blue: 0.20, alpha: 1)
            let pNode = SCNNode(geometry: passage)
            pNode.position = SCNVector3(0, -0.6, 2.0)
            pNode.eulerAngles.x = -0.25
            scene.rootNode.addChildNode(pNode)

            // Label
            let label = SCNText(string: "Subterranean Chamber (pre-existing)", extrusionDepth: 0.01)
            label.font = UIFont.systemFont(ofSize: 0.18, weight: .medium)
            label.firstMaterial?.diffuse.contents = UIColor.darkGray
            let lNode = SCNNode(geometry: label)
            lNode.position = SCNVector3(-2.6, -1.9, 0)
            lNode.scale = SCNVector3(0.7, 0.7, 0.7)
            scene.rootNode.addChildNode(lNode)
        }

        private func buildObeliskFooting(_ scene: SCNScene) {
            let footing = SCNBox(width: 1.8, height: 0.35, length: 1.8, chamferRadius: 0.04)
            footing.firstMaterial?.diffuse.contents = UIColor(red: 0.66, green: 0.59, blue: 0.47, alpha: 1)
            let node = SCNNode(geometry: footing)
            node.position = SCNVector3(0, 0.05, 0)
            scene.rootNode.addChildNode(node)
        }

        // MARK: - Wooden Boom Lifts (unchanged geometry)

        private func buildCranes(_ scene: SCNScene) {
            let positions: [SCNVector3] = [
                SCNVector3(-5.2, 0, -5.2),
                SCNVector3(5.2, 0, -5.2),
                SCNVector3(-5.2, 0, 5.2),
                SCNVector3(5.2, 0, 5.2)
            ]
            for index in 0..<4 {
                let crane = SCNNode()
                crane.position = positions[index]
                scene.rootNode.addChildNode(crane)
                buildCraneBase(on: crane)

                let pivot = SCNNode()
                pivot.position = SCNVector3(0, 1.4, 0)
                crane.addChildNode(pivot)
                buildLatticeBoom(on: pivot)
                buildPulley(on: pivot)

                let counterweight = SCNBox(width: 0.6, height: 0.45, length: 0.5, chamferRadius: 0.03)
                counterweight.firstMaterial?.diffuse.contents = UIColor.darkGray
                let cw = SCNNode(geometry: counterweight)
                cw.position = SCNVector3(-1.15, -0.15, 0)
                pivot.addChildNode(cw)

                craneNodes.append(crane)
                cranePivots.append(pivot)
            }
        }

        private func buildCraneBase(on crane: SCNNode) {
            let base = SCNBox(width: 0.95, height: 0.35, length: 0.85, chamferRadius: 0.03)
            base.firstMaterial?.diffuse.contents = UIColor(red: 0.43, green: 0.28, blue: 0.15, alpha: 1)
            let baseNode = SCNNode(geometry: base)
            baseNode.position.y = 0.18
            crane.addChildNode(baseNode)

            for x: Float in [-0.32, 0.32] {
                for z: Float in [-0.27, 0.27] {
                    let foot = SCNCylinder(radius: 0.07, height: 0.30)
                    foot.firstMaterial?.diffuse.contents = UIColor.brown
                    let node = SCNNode(geometry: foot)
                    node.position = SCNVector3(x, 0.03, z)
                    crane.addChildNode(node)
                }
            }

            let mast = SCNBox(width: 0.18, height: 2.5, length: 0.18, chamferRadius: 0)
            mast.firstMaterial?.diffuse.contents = UIColor(red: 0.48, green: 0.32, blue: 0.17, alpha: 1)
            let mastNode = SCNNode(geometry: mast)
            mastNode.position.y = 1.4
            crane.addChildNode(mastNode)
        }

        private func buildLatticeBoom(on pivot: SCNNode) {
            let wood = UIColor(red: 0.54, green: 0.36, blue: 0.20, alpha: 1)
            let length: Float = 3.4
            addBeam(from: SCNVector3(0, 0, 0), to: SCNVector3(length, 0, 0), radius: 0.085, color: wood, to: pivot)
            addBeam(from: SCNVector3(0, 0.22, 0), to: SCNVector3(length, 0.22, 0), radius: 0.06, color: wood, to: pivot)
            for i in 0..<8 {
                let x0 = length * Float(i) / 8
                let x1 = length * Float(i + 1) / 8
                addBeam(from: SCNVector3(x0, 0, 0), to: SCNVector3(x1, 0.22, 0), radius: 0.035, color: wood, to: pivot)
                addBeam(from: SCNVector3(x0, 0.22, 0), to: SCNVector3(x1, 0, 0), radius: 0.035, color: wood, to: pivot)
            }
            for z: Float in [-0.10, 0.10] {
                addBeam(from: SCNVector3(0, 0, z), to: SCNVector3(length, 0, z), radius: 0.04, color: wood, to: pivot)
            }
        }

        private func buildPulley(on pivot: SCNNode) {
            let wheel = SCNTorus(ringRadius: 0.15, pipeRadius: 0.035)
            wheel.firstMaterial?.diffuse.contents = UIColor.darkGray
            let wheelNode = SCNNode(geometry: wheel)
            wheelNode.position = SCNVector3(3.4, -0.08, 0)
            wheelNode.eulerAngles.x = .pi / 2
            pivot.addChildNode(wheelNode)

            let rope = SCNCylinder(radius: 0.018, height: 1.3)
            rope.firstMaterial?.diffuse.contents = UIColor(red: 0.30, green: 0.22, blue: 0.14, alpha: 1)
            let ropeNode = SCNNode(geometry: rope)
            ropeNode.position = SCNVector3(3.4, -0.80, 0)
            pivot.addChildNode(ropeNode)

            let hook = SCNTorus(ringRadius: 0.10, pipeRadius: 0.025)
            hook.firstMaterial?.diffuse.contents = UIColor.darkGray
            let hookNode = SCNNode(geometry: hook)
            hookNode.position = SCNVector3(3.4, -1.45, 0)
            pivot.addChildNode(hookNode)
        }

        private func addBeam(from start: SCNVector3, to end: SCNVector3, radius: CGFloat, color: UIColor, to parent: SCNNode) {
            let dx = end.x - start.x, dy = end.y - start.y, dz = end.z - start.z
            let length = sqrt(dx*dx + dy*dy + dz*dz)
            let cylinder = SCNCylinder(radius: radius, height: CGFloat(length))
            cylinder.firstMaterial?.diffuse.contents = color
            let node = SCNNode(geometry: cylinder)
            node.position = SCNVector3((start.x+end.x)/2, (start.y+end.y)/2, (start.z+end.z)/2)
            let dir = SCNVector3(dx, dy, dz)
            let len = max(0.0001, length)
            let n = SCNVector3(dir.x/len, dir.y/len, dir.z/len)
            node.rotation = SCNVector4(n.z, 0, -n.x, acos(max(-1, min(1, n.y))))
            parent.addChildNode(node)
        }

        // MARK: - Status

        private func buildStatus(_ scene: SCNScene) {
            let text = SCNText(string: "CA: Subterranean present • raising obelisk…", extrusionDepth: 0.01)
            text.font = UIFont.systemFont(ofSize: 0.20, weight: .bold)
            text.firstMaterial?.diffuse.contents = UIColor.black
            let node = SCNNode(geometry: text)
            node.position = SCNVector3(-5.5, 0.4, -8)
            node.scale = SCNVector3(0.75, 0.75, 0.75)
            scene.rootNode.addChildNode(node)
            statusNode = node
        }

        private func updateStatus(_ message: String) {
            (statusNode?.geometry as? SCNText)?.string = message
        }

        // MARK: - Lift Scheduling (strict phase order)

        private func startAvailableLifts() {
            guard running else { return }
            if placedBlocks >= ca.placements.count {
                updateStatus("Construction plan complete")
                return
            }
            for liftID in 0..<4 {
                scheduleNextBlock(for: liftID)
            }
        }

        private func scheduleNextBlock(for liftID: Int) {
            guard running else { return }

            // CA decides the next legal block under the current phase rules
            guard let placement = ca.nextPlacement(for: liftID, completed: completedPlacementIDs) else {
                return
            }

            completedPlacementIDs.insert(placement.id)

            animatePlacement(placement, liftID: liftID) { [weak self] in
                guard let self else { return }
                self.placedBlocks += 1

                let phaseMsg: String
                if placement.isCoreBlock && !placement.isBenben {
                    phaseMsg = "Raising obelisk"
                } else if placement.isBenben {
                    phaseMsg = "Placing benben"
                } else if placement.isChamberFeature {
                    phaseMsg = "Forming chamber / passage / airway"
                } else {
                    phaseMsg = "Extending outward – course \(placement.course)"
                }

                self.updateStatus("\(phaseMsg)  •  \(self.placedBlocks)/\(self.ca.placements.count)")
                self.scheduleNextBlock(for: liftID)
            }
        }

        // MARK: - Placement Animation

        private func animatePlacement(_ placement: BlockPlacement, liftID: Int, completion: @escaping () -> Void) {
            guard let scene, cranePivots.indices.contains(liftID) else {
                completion()
                return
            }

            let pivot = cranePivots[liftID]

            let material = SCNMaterial()
            if placement.isBenben {
                material.diffuse.contents = UIColor(red: 0.85, green: 0.65, blue: 0.25, alpha: 1)
            } else if placement.isCoreBlock {
                material.diffuse.contents = UIColor(red: 0.72, green: 0.68, blue: 0.59, alpha: 1)
            } else if placement.isChamberFeature {
                material.diffuse.contents = UIColor(red: 0.35, green: 0.28, blue: 0.22, alpha: 0.85)
                material.transparency = 0.7
            } else {
                material.diffuse.contents = UIColor(red: 0.63, green: 0.57, blue: 0.47, alpha: 1)
            }

            let geo = SCNBox(
                width: CGFloat(placement.dimensions.x),
                height: CGFloat(placement.dimensions.y),
                length: CGFloat(placement.dimensions.z),
                chamferRadius: 0.015
            )
            geo.materials = [material]

            let block = SCNNode(geometry: geo)
            let hookLocal = SCNVector3(3.4, -1.45, 0)
            let startWorld = pivot.convertPosition(hookLocal, to: scene.rootNode)
            block.position = startWorld
            block.opacity = 0
            scene.rootNode.addChildNode(block)

            let clearanceY = max(startWorld.y, placement.position.y + 1.3)
            let clearance = SCNVector3(placement.position.x, clearanceY, placement.position.z)
            let duration = 2.1 / animationSpeed

            let rise = SCNAction.move(to: SCNVector3(startWorld.x, startWorld.y + 1.0, startWorld.z), duration: duration * 0.22)
            let travel = SCNAction.move(to: clearance, duration: duration * 0.48)
            let lower = SCNAction.move(to: placement.position, duration: duration * 0.30)
            rise.timingMode = .easeInEaseOut
            travel.timingMode = .easeInEaseOut
            lower.timingMode = .easeInEaseOut

            let targetAngle = atan2(
                placement.position.z - startWorld.z,
                placement.position.x - startWorld.x
            )
            let rotateBoom = SCNAction.rotateTo(x: 0, y: CGFloat(targetAngle), z: 0,
                                                duration: duration * 0.45, usesShortestUnitArc: true)
            rotateBoom.timingMode = .easeInEaseOut
            pivot.runAction(rotateBoom)

            let sequence = SCNAction.sequence([
                SCNAction.fadeIn(duration: 0.05),
                rise, travel, lower,
                SCNAction.run { _ in
                    block.position = placement.position
                    block.eulerAngles.y = placement.rotationY
                }
            ])

            block.runAction(sequence) {
                DispatchQueue.main.async { completion() }
            }
        }
    }
}

#Preview {
    ContentView()
}

