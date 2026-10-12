/*


 The Pyramid Boom Lift construction model is designed to build the pyramid from the foundation upward using four coordinated boom lifts, four independent block stockpiles, a center-outward placement strategy, and a special counterweight-assisted operation for the massive chamber roof slabs. The pipeline preserves the pyramid’s external geometry while constructing the internal chambers, passages, and shafts as part of the same structure. Its governing rule is that each block must have a valid destination, adequate support, sufficient lifting capacity, and clear placement space before the next construction step begins.

 Stage 1 — Establish the construction site and central datum. The process begins by defining the foundation footprint, pyramid centerline, base elevation, slope, overall height, and planned course geometry. The central datum provides the reference for aligning the structure as it grows. The initial site also defines the King's Chamber, Queen's Chamber, connecting passages, and shafts as reserved internal regions. These internal features must be incorporated into the block layout without changing the pyramid’s external dimensions or intended course profile.

 Stage 2 — Prepare the foundation and structural envelope. The foundation is divided into a grid of block-placement locations. The construction controller establishes the first course and calculates the location, dimensions, and support requirements of each block. Base blocks are modeled at approximately 10 tons, while upper-course blocks are modeled at approximately 2.5 tons. Each planned block receives a unique identity and a defined position so the system can check for gaps, overlaps, unsupported placements, and conflicts with chamber boundaries.

 Stage 3 — Establish four corner stockpiles. Four visible block piles are positioned outside the pyramid footprint, one near each corner. Each pile maintains its own inventory, block mass, and available supply. The four boom lifts draw blocks from their assigned piles rather than repeatedly loading from a single shared location. When a lift takes a block, the block is removed from that pile and its inventory count decreases. The stockpiles therefore represent actual material supply within the simulation, not decorative objects. Replenishment, if modeled, must be recorded as a separate operation.

 Stage 4 — Position and inspect the four boom lifts. One boom lift is assigned to each corner region. Each lift has a defined base, boom length, pivot, lifting cable or attachment, working envelope, and permitted load. Before lifting begins, the controller checks whether the machine can reach the source block and the intended destination. It also checks the load against the configured lifting limit, the boom’s reach and moment limits, base stability, and clearance from the pyramid, other lifts, and previously placed blocks. The four lifts may operate concurrently only when their movements and work zones do not conflict.

 Stage 5 — Select the next eligible block. The controller identifies the lowest unfinished course and selects a block whose prerequisites have been satisfied. Placement proceeds outward from the central reference region, filling the intended pattern while coordinating the four corners. The controller does not advance to a higher course simply because an available block can be lifted there. The necessary lower-course blocks and supporting surfaces must first be complete. Chamber roofs and other structurally sensitive areas introduce additional placement dependencies.

 Stage 6 — Reserve internal spaces and verify the target. Before a block is assigned to a destination, the controller checks whether that location belongs to a chamber, passage, or shaft that must remain open. The King's Chamber and Queen's Chamber should be visually distinguishable in red, while block edges should be framed so their boundaries and neighboring relationships remain visible. Blocks that form the chamber walls, lintels, roof supports, and surrounding masonry must be explicitly planned. No ordinary block may occupy a reserved void, overlap an existing block, or intrude into a neighboring block’s occupied volume.

 Stage 7 — Perform the pre-lift engineering checks. Before removing a block from its pile, the assigned lift verifies the block’s mass, pickup location, target coordinates, boom reach, estimated lifting moment, support conditions, and movement clearance. The system also verifies that the destination is still available and that the required support blocks have already been placed. If any check fails, the controller rejects or postpones the operation rather than moving the block anyway. This prevents the earlier simulation failure in which lifts attempted to place blocks at unreachable locations or into occupied space.

 Stage 8 — Pick up the block from the corner pile. Once the operation is approved, the lift moves its attachment into position over the selected block. The block is connected to the simulated lifting system, and the controller verifies that the pickup corresponds to an actual inventory item. The block is then removed from the pile and marked as being in transit. Its mass and destination remain associated with it throughout the operation. This makes it possible to track the block from source to final placement without duplicating or losing material.

 Stage 9 — Lift, swing, and lower the block. The boom raises the block vertically until it clears nearby obstacles. It then swings toward the designated placement point and lowers the block under controlled motion. The sequence is deliberately separated into pickup, vertical lift, swing, and lowering phases so the simulation can inspect each phase independently. If the lift cannot reach the target or a collision is detected, the operation must stop before the block is committed to the structure. Only after the block reaches its intended position and passes the final geometry and support checks is it marked as placed.

 Stage 10 — Complete each course through coordinated center-outward placement. The four lifts work through their assigned regions while the controller maintains a shared record of completed blocks and remaining dependencies. The objective is to minimize unnecessary travel and avoid interference between lifts. A lift may work on another eligible block while a different lift is operating, but neither may bypass the course-ordering rules or claim the same target. When a course is complete, the controller verifies its geometry, support continuity, and material accounting before permitting the next course to proceed.

 Stage 11 — Build the Queen's Chamber and prepare the counterweight system. When construction reaches the Queen's Chamber elevation, the process enters a special heavy-lifting phase. The proposed mechanism uses a counterweight container filled with rock or other ballast, moving along a guided track or prepared ramp. A rope or hauling line connects the descending counterweight to the heavy roof slab being raised. As the counterweight descends, it supplies a pulling force that helps draw the slab up the pyramid's inclined side. The Queen's Chamber is treated as the elevation at which this special operation becomes available, rather than as a reason to change the normal rules for every earlier course.

 The analogy is a freight elevator balanced by a heavy counterweight: instead of lifting the entire load solely through a powered boom, the system uses a descending mass to assist the upward movement of the roof slab. The counterweight does not eliminate the slab’s weight. The pulling force must still overcome the component of the slab’s weight acting down the slope, rolling or sliding resistance, rope and pulley losses, and any acceleration forces. The tracks, anchors, hauling line, and supporting masonry must be able to withstand the resulting loads. This is a plausible mechanism to investigate, not proof that the arrangement could safely lift an 80-ton stone at the Great Pyramid.

 Stage 12 — Haul the King's Chamber roof slabs up the pyramid side. Each roof slab is modeled as an approximately 80-ton load, consistent with the project’s specified modeling requirement. The slab is connected to the hauling system, and the counterweight is loaded to the planned mass. The controller evaluates the proposed pulling force, track capacity, rope tension, anchor loads, slope, and the required travel distance to the chamber elevation. The slab is then hauled upward in controlled increments, with its position and the counterweight position updated together. The simulation must prevent the slab from being placed until it reaches the correct elevation and orientation. The counterweight should be represented as an actual moving load, not simply as a visual object that automatically causes the slab to rise.

 Stage 13 — Transfer and position the roof slabs. Reaching the chamber elevation is not the same as installing a roof slab. Once the slab reaches the designated transfer point, the construction sequence must support and restrain it while its load is transferred from the hauling system to the final placement mechanism. A boom lift may assist with alignment or final positioning only if its modeled capacity, reach, and support conditions permit that operation. The slab is lowered onto its specifically defined bearing surfaces, with sufficient contact and support on the intended walls or lintels. The placement check must ensure that the slab does not overlap neighboring blocks, obstruct the chamber opening, or create unsupported geometry. Each roof slab is installed and verified individually before the next slab is moved into position.

 Stage 14 — Complete the chamber roof and surrounding masonry. Once all required roof slabs have been positioned, the controller checks their alignment, bearing relationships, and the completion of the surrounding support courses. The chamber remains an internal space, not a collection of blocks that changes the pyramid’s outer envelope. The simulation must not allow the roof slabs to overlap ordinary neighboring blocks or block locations that are already occupied. If the required roof geometry conflicts with the existing course layout, the layout or block definitions must be corrected rather than forcing the placement through the collision checks.

 Stage 15 — Resume ordinary block construction above the chamber. After the special roof-slab installation is complete and verified, the pipeline returns to normal block placement. The four boom lifts again draw from their respective corner stockpiles, select eligible blocks from the lowest unfinished course, check reach and support, and perform the pickup-lift-swing-lower sequence. The counterweight mechanism is no longer invoked for ordinary blocks unless another explicitly defined heavy-lift operation requires it. Courses continue to be completed in dependency order, while the controller preserves the chambers, passages, shafts, and external slope.

 Stage 16 — Construct the upper courses and converge toward the apex. As the pyramid rises, the available placement area narrows and the boom lifts’ reach and working envelopes become increasingly important. Upper-course blocks are modeled at approximately 2.5 tons under the project’s current assumptions. The controller recalculates eligible destinations, verifies that each block is supported by the course below, and checks that the four lifts can safely access their assigned work zones. The placement pattern converges toward the central axis until the uppermost course is completed. Any final capstone or benben element is placed only after its supporting geometry and target position have been verified.

 Stage 17 — Perform final structural and inventory validation. After the apex is complete, the controller performs a final inspection of the external pyramid envelope, course alignment, block intersections, support relationships, and internal voids. It verifies that the chamber roof slabs occupy their intended positions and that the Queen's Chamber, King's Chamber, passages, and shafts remain correctly represented. It also reconciles the total number of blocks removed from the four stockpiles with the blocks placed, remaining in transit, and any explicitly recorded losses or rejected pieces. A completed animation is not sufficient on its own: the final model must pass the same geometry and dependency checks used during construction.

 The result is a complete, dependency-driven construction pipeline: site and foundation → four corner stockpiles → four coordinated boom lifts → center-outward course placement → Queen's Chamber elevation → counterweight-assisted roof-slab hauling → controlled roof installation → ordinary construction resumed above the chamber → upper courses → apex → final validation.

 This pipeline defines the intended construction logic for the SwiftUI/SceneKit simulator. Its geometric checks and modeled lifting calculations can make the simulation internally consistent, but they do not independently establish that the complete lifting arrangement, counterweight tracks, anchors, masonry supports, or historical construction method would be physically safe or historically accurate.

 
 Pyramid Boom Lift — complete ContentView.swift

 Features:
 - Foundation and stepped pyramid courses
 - Four corner stockpiles
 - Four independently positioned boom lifts
 - Moving boom, brace, cable, hook, and block
 - Animation speed slider
 - Run / pause / step / reset
 - Red chamber visualization and framed roof slab
 - Counterweight-assisted roof-slab animation
 - Placement support and overlap checks
 - Engineering-mode reach and moment checks

 This is a conceptual construction simulator. Its animated lifting
 mechanism does not establish real-world structural or lifting safety.
*/


import SwiftUI
import SceneKit
import UIKit
import Combine
import simd

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var controller = PyramidConstructionController()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PYRAMID BOOM LIFT — 210 COURSES")
                        .font(.headline.bold())

                    Text("Four lifts • Four stockpiles • Counterweight roof haul")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Reset", systemImage: "arrow.counterclockwise") {
                    controller.reset()
                }
                .buttonStyle(.bordered)
            }
            .padding()

            SceneView(
                scene: controller.scene,
                pointOfView: controller.cameraNode,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting
                ]
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    statusPanel
                    runControls
                    speedControl
                    engineeringControl
                    cranePanel
                    pipelinePanel
                    equationsPanel
                }
                .padding()
            }
            .frame(maxHeight: 370)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .onAppear {
            controller.start()
        }
        .onDisappear {
            controller.stop()
        }
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(controller.status)
                    .font(.headline)

                Spacer()

                Text("\(controller.placedCount)/\(controller.totalCount)")
                    .font(.caption.monospacedDigit())
            }

            ProgressView(value: controller.progress)

            Text(controller.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var runControls: some View {
        HStack {
            Button {
                controller.toggleRunning()
            } label: {
                Label(
                    controller.isRunning ? "Pause" : "Resume",
                    systemImage: controller.isRunning
                        ? "pause.fill"
                        : "play.fill"
                )
            }
            .buttonStyle(.borderedProminent)

            Button {
                controller.stepOnce()
            } label: {
                Label("Step", systemImage: "forward.frame")
            }
            .buttonStyle(.bordered)

            Spacer()
        }
    }

    private var speedControl: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Animation speed")
                    .font(.subheadline.bold())

                Spacer()

                Text(String(format: "%.2f×", controller.animationSpeed))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: $controller.animationSpeed,
                in: 0.25...500,
                step: 10.0
            )

            HStack {
                Text("0.25×")
                Spacer()
                Text("500×")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    private var engineeringControl: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Validation mode")
                .font(.subheadline.bold())

            Picker(
                "Mode",
                selection: Binding(
                    get: { controller.engineeringMode },
                    set: { controller.engineeringMode = $0 }
                )
            ) {
                Text("Visual demo").tag(false)
                Text("Engineering checks").tag(true)
            }
            .pickerStyle(.segmented)

            Text(
                controller.engineeringMode
                ? "Reach, moment, support, and overlap checks are enforced where modeled. Roof hauling is not mechanically validated."
                : "Visual mode demonstrates placement and hauling paths without enforcing every engineering check."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var cranePanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Four boom lifts")
                .font(.headline)

            ForEach(controller.craneRows) { row in
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.to.line")
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.name)
                            .font(.subheadline.bold())

                        Text(row.phase)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(row.load)
                        .font(.caption.monospacedDigit())
                }
            }
        }
    }

    private var pipelinePanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()

            Text("Construction pipeline")
                .font(.headline)

            ForEach(controller.pipeline, id: \.0) { item in
                HStack(alignment: .top, spacing: 10) {
                    Text(item.0)
                        .font(.caption.bold().monospacedDigit())
                        .frame(width: 28, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.1)
                            .font(.subheadline.bold())

                        Text(item.2)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var equationsPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Divider()

            Text("Conceptual hauling equations")
                .font(.headline)

            Text("Weight: W = m × g")
            Text("Ideal incline force: F = m × g × sin(θ)")
            Text("Gravitational work: E = m × g × Δh")
            Text("Turning moment: M = F × r")

            Text(
                "Cable tension, pulley losses, braking, counterweight mass, anchor strength, and bearing loads require a separate force-coupled engineering model."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Models

private struct StoneTarget: Identifiable {
    let id: Int
    let course: Int
    let position: SIMD3<Float>
    let size: SIMD3<Float>
    let isRoofSlab: Bool
    let roofSlabIndex: Int?
    let rotationZ: Float
}

private enum CranePhase {
    case idle
    case pickup
    case lifting
    case hauling
    case lowering
    case releasing
}

struct CraneRow: Identifiable {
    let id: Int
    let name: String
    let phase: String
    let load: String
}

private struct Crane {
    let id: Int
    let name: String
    let stockpileIndex: Int

    let root: SCNNode
    let boom: SCNNode
    let brace: SCNNode
    let hook: SCNNode
    let cable: SCNNode

    var phase: CranePhase = .idle
    var elapsed: Float = 0
    var target: StoneTarget?
    var block: SCNNode?
    var start: SIMD3<Float> = .zero
}

private enum HaulStage {
    case exteriorRamp
    case inwardTransfer
}

// MARK: - Construction controller

final class PyramidConstructionController: ObservableObject {

    // MARK: 210-course geometry

    private let courses = 210
    private let courseHeight: Float = 0.15
    private let spacing: Float = 0.82
    private let baseHalfCells = 30

    private let roofSlabCount = 5
    private let roofMassKg: Float = 80_000

    private let maximumReach: Float = 12
    private let maximumMomentKNm: Float = 220

    private var queenChamberStartCourse: Int { 58 }
    private var queenChamberEndCourse: Int { 65 }

    private var passageStartCourse: Int { 66 }
    private var passageEndCourse: Int { 84 }

    private var kingChamberStartCourse: Int { 85 }
    private var roofSlabCourse: Int { 105 }

    private func courseY(_ course: Int) -> Float {
        0.22 + Float(course) * courseHeight
    }

    private var roofSlabElevation: Float {
        courseY(roofSlabCourse)
    }

    // Exterior ramp endpoints and transfer position.
    private let rampBase = SIMD3<Float>(-7.0, 0.55, 0)

    private var queenTransfer: SIMD3<Float> {
        SIMD3<Float>(-2.8, roofSlabElevation, 0)
    }

    private var pulleyPosition: SIMD3<Float> {
        SIMD3<Float>(
            -2.8,
            roofSlabElevation + 0.7,
            0
        )
    }

    // MARK: Published UI state

    @Published var status = "Initializing 210-course model"
    @Published var detail = "Preparing the foundation and four stockpiles."

    @Published var isRunning = true
    @Published var engineeringMode = false
    @Published var animationSpeed: Double = 1.0

    @Published var placedCount = 0
    @Published var totalCount = 0
    @Published var craneRows: [CraneRow] = []

    @Published var pipeline: [(String, String, String)] = [
        ("1", "Foundation and datum",
         "Establish the base and first course."),
        ("2", "Four corner stockpiles",
         "Assign one stockpile to each lift."),
        ("3", "Courses 1–58",
         "Build the lower exterior courses while preserving the chamber geometry."),
        ("4", "Queen's Chamber",
         "Preserve the chamber void and its modeled course range."),
        ("5", "Passage and King's Chamber",
         "Keep the modeled passage and King's Chamber voids open."),
        ("6", "Course 106 roof stage",
         "Reserve the roof footprint and place five separate roof slabs at course 106."),
        ("7", "Counterweight haul",
         "Animate a slab traveling up the exterior ramp."),
        ("8", "Inward roof transfer",
         "Transfer the slab toward its roof target."),
        ("9", "Upper courses",
         "Resume ordinary placement after the roof targets are placed."),
        ("10", "Completion",
         "Verify that every generated target has been placed.")
    ]

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(placedCount) / Double(totalCount)
    }

    // MARK: Scene nodes

    let scene = SCNScene()
    let cameraNode = SCNNode()

    private let world = SCNNode()
    private let blockRoot = SCNNode()
    private let craneRoot = SCNNode()
    private let stockpileRoot = SCNNode()
    private let chamberRoot = SCNNode()
    private let counterweightRoot = SCNNode()

    private var cranes: [Crane] = []
    private var targets: [StoneTarget] = []
    private var placed = Set<Int>()
    private var reserved = Set<Int>()
    private var placedNodes: [Int: SCNNode] = [:]

    private var timer: AnyCancellable?
    private var nextID = 0
    private var singleStep = false

    private var counterweight: SCNNode?
    private var counterweightCable: SCNNode?
    private var slabCable: SCNNode?

    init() {
        scene.rootNode.addChildNode(world)

        world.addChildNode(blockRoot)
        world.addChildNode(craneRoot)
        world.addChildNode(stockpileRoot)
        world.addChildNode(chamberRoot)
        world.addChildNode(counterweightRoot)

        configureScene()
        configureCamera()
        buildFoundation()
        buildTargets()
        buildChambers()
        buildCounterweightSystem()
        buildStockpiles()
        buildCranes()

        totalCount = targets.count
        refreshUI()
    }

    // MARK: Scene setup

    private func configureScene() {
        scene.background.contents = UIColor(
            red: 0.05,
            green: 0.07,
            blue: 0.11,
            alpha: 1
        )

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 500

        let ambientNode = SCNNode()
        ambientNode.light = ambient
        world.addChildNode(ambientNode)

        let sun = SCNLight()
        sun.type = .directional
        sun.intensity = 1000

        let sunNode = SCNNode()
        sunNode.light = sun
        sunNode.eulerAngles = SCNVector3(-0.8, 0.6, 0)
        world.addChildNode(sunNode)

        let ground = SCNBox(
            width: 64,
            height: 0.15,
            length: 64,
            chamferRadius: 0
        )

        ground.materials = [
            mat(UIColor(white: 0.32, alpha: 1))
        ]

        let groundNode = SCNNode(geometry: ground)
        groundNode.position = SCNVector3(0, -0.13, 0)
        world.addChildNode(groundNode)
    }

    private func configureCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 48
        cameraNode.position = SCNVector3(34, 26, 42)
        cameraNode.look(at: SCNVector3(0, 12, 0))
        scene.rootNode.addChildNode(cameraNode)
    }

    private func mat(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.85
        return material
    }

    private func addBox(
        _ parent: SCNNode,
        _ position: SIMD3<Float>,
        _ size: SIMD3<Float>,
        _ color: UIColor,
        chamfer: CGFloat = 0
    ) -> SCNNode {
        let geometry = SCNBox(
            width: CGFloat(size.x),
            height: CGFloat(size.y),
            length: CGFloat(size.z),
            chamferRadius: chamfer
        )

        geometry.materials = [mat(color)]

        let node = SCNNode(geometry: geometry)
        node.position = scn(position)
        parent.addChildNode(node)
        return node
    }

    private func addBeam(
        _ rootNode: SCNNode,
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        radius: CGFloat,
        color: UIColor
    ) -> SCNNode {
        let vector = end - start
        let beamLength = max(0.01, simd_length(vector))

        let cylinder = SCNCylinder(
            radius: radius,
            height: CGFloat(beamLength)
        )
        cylinder.materials = [mat(color)]

        let node = SCNNode(geometry: cylinder)
        node.position = scn((start + end) / 2)

        let up = SIMD3<Float>(0, 1, 0)
        let direction = simd_normalize(vector)
        let dotValue = max(-1, min(1, simd_dot(up, direction)))
        let axis = simd_cross(up, direction)
        let axisLength = simd_length(axis)

        if axisLength > 0.001 {
            let normalizedAxis = simd_normalize(axis)
            let angle = acos(dotValue)
            node.rotation = SCNVector4(
                normalizedAxis.x,
                normalizedAxis.y,
                normalizedAxis.z,
                angle
            )
        } else if dotValue < 0 {
            node.rotation = SCNVector4(1, 0, 0, Double.pi)
        }

        rootNode.addChildNode(node)
        return node
    }

    private func updateBeam(
        _ node: SCNNode,
        from a: SIMD3<Float>,
        to b: SIMD3<Float>,
        radius: CGFloat,
        color: UIColor
    ) {
        let delta = b - a
        let beamLength = max(0.01, simd_length(delta))

        let geometry = SCNCylinder(
            radius: radius,
            height: CGFloat(beamLength)
        )
        geometry.radialSegmentCount = 8
        geometry.materials = [mat(color)]

        node.geometry = geometry
        node.position = scn((a + b) / 2)

        let up = SIMD3<Float>(0, 1, 0)
        let direction = simd_normalize(delta)
        let dotValue = max(-1, min(1, simd_dot(up, direction)))
        let axis = simd_cross(up, direction)
        let axisLength = simd_length(axis)

        if axisLength > 0.001 {
            let normalizedAxis = simd_normalize(axis)
            node.rotation = SCNVector4(
                normalizedAxis.x,
                normalizedAxis.y,
                normalizedAxis.z,
                acos(dotValue)
            )
        } else if dotValue < 0 {
            node.rotation = SCNVector4(1, 0, 0, Double.pi)
        } else {
            node.rotation = SCNVector4(0, 0, 0, 0)
        }
    }

    private func scn(_ position: SIMD3<Float>) -> SCNVector3 {
        SCNVector3(position.x, position.y, position.z)
    }

    private func vec(_ position: SCNVector3) -> SIMD3<Float> {
        SIMD3<Float>(position.x, position.y, position.z)
    }

    private func mix(
        _ a: SIMD3<Float>,
        _ b: SIMD3<Float>,
        _ t: Float
    ) -> SIMD3<Float> {
        a + (b - a) * t
    }

    private func smooth(_ value: Float) -> Float {
        let t = min(1, max(0, value))
        return t * t * (3 - 2 * t)
    }

    // MARK: Foundation and target generation

    private func buildFoundation() {
        let geometry = SCNBox(
            width: CGFloat(Float(baseHalfCells * 2 + 1) * spacing),
            height: 0.18,
            length: CGFloat(Float(baseHalfCells * 2 + 1) * spacing),
            chamferRadius: 0
        )

        geometry.materials = [
            mat(
                UIColor(
                    red: 0.52,
                    green: 0.46,
                    blue: 0.36,
                    alpha: 1
                )
            )
        ]

        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(0, 0.03, 0)
        blockRoot.addChildNode(node)
    }

    private func buildTargets() {
        targets.removeAll()
        nextID = 0

        for course in 0..<courses {
            let y = courseY(course)
            let taper = 1.0 - Float(course) / Float(courses - 1)

            let half = max(
                1,
                Int(round(Float(baseHalfCells) * taper))
            )

            for xCell in (-half)...half {
                for zCell in (-half)...half {
                    let x = Float(xCell) * spacing
                    let z = Float(zCell) * spacing

                    // Reserve the roof footprint for dedicated slabs.
                    if course == roofSlabCourse,
                       abs(x) <= 1.65,
                       abs(z) <= 1.65 {
                        continue
                    }

                    // Queen's Chamber void.
                    if (queenChamberStartCourse...queenChamberEndCourse)
                        .contains(course),
                       abs(x) <= 1.23,
                       abs(z) <= 1.23 {
                        continue
                    }

                    // Connecting passage void.
                    if (passageStartCourse...passageEndCourse)
                        .contains(course),
                       abs(x) <= 0.41,
                       abs(z - 1.85) <= 0.41 {
                        continue
                    }

                    // King's Chamber void beneath the roof.
                    if (kingChamberStartCourse..<roofSlabCourse)
                        .contains(course),
                       abs(x) <= 1.23,
                       abs(z) <= 1.23 {
                        continue
                    }

                    targets.append(
                        StoneTarget(
                            id: nextID,
                            course: course,
                            position: SIMD3<Float>(x, y, z),
                            size: SIMD3<Float>(
                                spacing * 0.96,
                                courseHeight * 0.96,
                                spacing * 0.96
                            ),
                            isRoofSlab: false,
                            roofSlabIndex: nil,
                            rotationZ: 0
                        )
                    )

                    nextID += 1
                }
            }

            // Five individual roof slabs at course 105.
            if course == roofSlabCourse {
                for slabIndex in 0..<roofSlabCount {
                    let offset = Float(slabIndex) -
                        Float(roofSlabCount - 1) / 2

                    let x = offset * 0.55
                    let heightOffset =
                        (1.0 - abs(offset) / 2.0) * 0.12

                    let angle: Float
                    if offset < 0 {
                        angle = 0.22
                    } else if offset > 0 {
                        angle = -0.22
                    } else {
                        angle = 0
                    }

                    targets.append(
                        StoneTarget(
                            id: nextID,
                            course: course,
                            position: SIMD3<Float>(
                                x,
                                y + heightOffset,
                                0
                            ),
                            size: SIMD3<Float>(
                                0.58,
                                0.45,
                                2.8
                            ),
                            isRoofSlab: true,
                            roofSlabIndex: slabIndex,
                            rotationZ: angle
                        )
                    )

                    nextID += 1
                }
            }
        }

        targets.sort { a, b in
            if a.course != b.course {
                return a.course < b.course
            }

            if a.isRoofSlab != b.isRoofSlab {
                return !a.isRoofSlab
            }

            return a.id < b.id
        }
    }

    // MARK: Chambers and shafts

    private func buildChambers() {
        chamberRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        // Queen's Chamber guide.
        let queenBottom =
            courseY(queenChamberStartCourse) - courseHeight / 2

        let queenTop =
            courseY(queenChamberEndCourse) + courseHeight / 2

        let queenGeometry = SCNBox(
            width: 2.4,
            height: CGFloat(max(courseHeight, queenTop - queenBottom)),
            length: 2.4,
            chamferRadius: 0
        )

        queenGeometry.firstMaterial?.diffuse.contents = UIColor.red
        queenGeometry.firstMaterial?.transparency = 0.34
        queenGeometry.firstMaterial?.isDoubleSided = true

        let queenNode = SCNNode(geometry: queenGeometry)
        queenNode.position = SCNVector3(
            0,
            (queenBottom + queenTop) / 2,
            0
        )
        chamberRoot.addChildNode(queenNode)

        // King's Chamber guide, ending beneath the roof.
        let kingBottom =
            courseY(kingChamberStartCourse) - courseHeight / 2

        let kingTop =
            roofSlabElevation - courseHeight / 2

        let kingGeometry = SCNBox(
            width: 2.4,
            height: CGFloat(max(courseHeight, kingTop - kingBottom)),
            length: 2.4,
            chamferRadius: 0
        )

        kingGeometry.firstMaterial?.diffuse.contents = UIColor.red
        kingGeometry.firstMaterial?.transparency = 0.34
        kingGeometry.firstMaterial?.isDoubleSided = true

        let kingNode = SCNNode(geometry: kingGeometry)
        kingNode.position = SCNVector3(
            0,
            (kingBottom + kingTop) / 2,
            0
        )
        chamberRoot.addChildNode(kingNode)

        // Connecting passage guide.
        let passageBottom =
            courseY(passageStartCourse) - courseHeight / 2

        let passageTop =
            courseY(passageEndCourse) + courseHeight / 2

        _ = addBox(
            chamberRoot,
            SIMD3<Float>(
                0,
                (passageBottom + passageTop) / 2,
                1.85
            ),
            SIMD3<Float>(
                0.5,
                max(courseHeight, passageTop - passageBottom),
                0.5
            ),
            UIColor.orange.withAlphaComponent(0.7)
        )

        // Shaft guides.
        _ = addBeam(
            chamberRoot,
            from: SIMD3<Float>(
                -0.55,
                kingBottom + 0.1,
                -0.55
            ),
            to: SIMD3<Float>(
                -1.6,
                5.0,
                -1.6
            ),
            radius: 0.055,
            color: UIColor.green.withAlphaComponent(0.8)
        )

        _ = addBeam(
            chamberRoot,
            from: SIMD3<Float>(
                0.55,
                kingBottom + 0.1,
                -0.55
            ),
            to: SIMD3<Float>(
                1.6,
                5.0,
                -1.6
            ),
            radius: 0.055,
            color: UIColor.green.withAlphaComponent(0.8)
        )
    }

    // MARK: Counterweight mechanism

    private func buildCounterweightSystem() {
        counterweightRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let wood = UIColor(
            red: 0.39,
            green: 0.24,
            blue: 0.13,
            alpha: 1
        )

        // Exterior ramp rails.
        for z: Float in [-0.38, 0.38] {
            _ = addBeam(
                counterweightRoot,
                from: SIMD3<Float>(rampBase.x, rampBase.y, z),
                to: SIMD3<Float>(queenTransfer.x, queenTransfer.y, z),
                radius: 0.09,
                color: wood
            )
        }

        // Ramp cross-ties.
        for index in 0...8 {
            let t = Float(index) / 8
            let point = mix(rampBase, queenTransfer, t)

            _ = addBeam(
                counterweightRoot,
                from: SIMD3<Float>(point.x, point.y, -0.5),
                to: SIMD3<Float>(point.x, point.y, 0.5),
                radius: 0.04,
                color: wood
            )
        }

        // Pulley frame.
        for z: Float in [-0.65, 0.65] {
            _ = addBeam(
                counterweightRoot,
                from: SIMD3<Float>(
                    pulleyPosition.x,
                    pulleyPosition.y - 1.0,
                    z
                ),
                to: SIMD3<Float>(
                    pulleyPosition.x,
                    pulleyPosition.y + 0.45,
                    z
                ),
                radius: 0.11,
                color: wood
            )
        }

        let pulleyGeometry = SCNTorus(
            ringRadius: 0.25,
            pipeRadius: 0.055
        )
        pulleyGeometry.materials = [mat(.darkGray)]

        let pulley = SCNNode(geometry: pulleyGeometry)
        pulley.position = scn(pulleyPosition)
        pulley.eulerAngles.x = .pi / 2
        counterweightRoot.addChildNode(pulley)

        // Counterweight guide rails.
        for z: Float in [0.48, 1.02] {
            for x: Float in [-0.55, 0.55] {
                _ = addBeam(
                    counterweightRoot,
                    from: SIMD3<Float>(
                        x,
                        queenTransfer.y - 1.1,
                        z
                    ),
                    to: SIMD3<Float>(
                        x,
                        pulleyPosition.y + 0.2,
                        z
                    ),
                    radius: 0.045,
                    color: wood
                )
            }
        }

        let initialWeightPosition = SIMD3<Float>(
            0,
            pulleyPosition.y - 0.35,
            0.75
        )

        counterweight = addBox(
            counterweightRoot,
            initialWeightPosition,
            SIMD3<Float>(0.8, 0.9, 0.8),
            UIColor(white: 0.32, alpha: 1)
        )

        counterweightCable = addBeam(
            counterweightRoot,
            from: pulleyPosition,
            to: initialWeightPosition,
            radius: 0.025,
            color: .darkGray
        )

        slabCable = addBeam(
            counterweightRoot,
            from: pulleyPosition,
            to: queenTransfer,
            radius: 0.025,
            color: .darkGray
        )
    }

    private func updateCable(
        _ cable: SCNNode?,
        from a: SIMD3<Float>,
        to b: SIMD3<Float>
    ) {
        guard let cable else { return }

        updateBeam(
            cable,
            from: a,
            to: b,
            radius: 0.025,
            color: .darkGray
        )
    }

    // MARK: Four independent stockpiles

    private func buildStockpiles() {
        stockpileRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let positions: [SIMD3<Float>] = [
            SIMD3<Float>(-19, 0.2, -19),
            SIMD3<Float>(19, 0.2, -19),
            SIMD3<Float>(-19, 0.2, 19),
            SIMD3<Float>(19, 0.2, 19)
        ]

        let colors: [UIColor] = [
            UIColor(red: 0.69, green: 0.59, blue: 0.44, alpha: 1),
            UIColor(red: 0.61, green: 0.53, blue: 0.41, alpha: 1),
            UIColor(red: 0.73, green: 0.63, blue: 0.48, alpha: 1),
            UIColor(red: 0.64, green: 0.55, blue: 0.43, alpha: 1)
        ]

        for i in 0..<4 {
            let p = positions[i]

            _ = addBox(
                stockpileRoot,
                SIMD3<Float>(p.x, 0.1, p.z),
                SIMD3<Float>(2.4, 0.2, 2.4),
                .darkGray
            )

            for row in 0..<4 {
                for col in 0..<4 {
                    let x = p.x + (Float(col) - 1.5) * 0.48
                    let z = p.z + (Float(row) - 1.5) * 0.48
                    let y = 0.35 + Float((row + col) % 2) * 0.27

                    _ = addBox(
                        stockpileRoot,
                        SIMD3<Float>(x, y, z),
                        SIMD3<Float>(0.43, 0.28, 0.43),
                        colors[i],
                        chamfer: 0.015
                    )
                }
            }
        }
    }

    private func stockPosition(_ index: Int) -> SIMD3<Float> {
        switch index {
        case 0:
            return SIMD3<Float>(-19, 0.55, -19)
        case 1:
            return SIMD3<Float>(19, 0.55, -19)
        case 2:
            return SIMD3<Float>(-19, 0.55, 19)
        default:
            return SIMD3<Float>(19, 0.55, 19)
        }
    }

    // MARK: Four boom lifts

    private func buildCranes() {
        craneRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        cranes.removeAll()

        let bases: [SIMD3<Float>] = [
            SIMD3<Float>(-16, 0.35, -16),
            SIMD3<Float>(16, 0.35, -16),
            SIMD3<Float>(-16, 0.35, 16),
            SIMD3<Float>(16, 0.35, 16)
        ]

        let names = [
            "Northwest lift",
            "Northeast lift",
            "Southwest lift",
            "Southeast lift"
        ]

        let wood = UIColor(
            red: 0.43,
            green: 0.27,
            blue: 0.14,
            alpha: 1
        )

        for i in 0..<4 {
            let root = SCNNode()
            root.position = scn(bases[i])
            craneRoot.addChildNode(root)

            _ = addBox(
                root,
                .zero,
                SIMD3<Float>(0.9, 0.5, 0.9),
                wood
            )

            _ = addBeam(
                root,
                from: SIMD3<Float>(0, 0.2, 0),
                to: SIMD3<Float>(0, 2.5, 0),
                radius: 0.12,
                color: wood
            )

            let pivot = SIMD3<Float>(0, 2.3, 0)
            let initialTip = SIMD3<Float>(-1.8, 2.0, 0)

            let boom = addBeam(
                root,
                from: pivot,
                to: initialTip,
                radius: 0.1,
                color: wood
            )

            let brace = addBeam(
                root,
                from: SIMD3<Float>(0, 0.5, 0),
                to: initialTip,
                radius: 0.065,
                color: wood
            )

            let hook = addBox(
                root,
                initialTip + SIMD3<Float>(0, -0.25, 0),
                SIMD3<Float>(0.12, 0.22, 0.12),
                .darkGray
            )

            let cable = addBeam(
                root,
                from: initialTip,
                to: initialTip + SIMD3<Float>(0, -0.25, 0),
                radius: 0.025,
                color: .darkGray
            )

            cranes.append(
                Crane(
                    id: i,
                    name: names[i],
                    stockpileIndex: i,
                    root: root,
                    boom: boom,
                    brace: brace,
                    hook: hook,
                    cable: cable
                )
            )
        }
    }

    // MARK: Run controls

    func start() {
        guard timer == nil else { return }

        timer = Timer.publish(
            every: 0.05,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            self?.tick(0.05)
        }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func toggleRunning() {
        isRunning.toggle()
        status = isRunning
            ? "Construction resumed"
            : "Construction paused"
    }

    func stepOnce() {
        singleStep = true

        if !isRunning {
            tick(0.2)
        }
    }

    func reset() {
        stop()

        blockRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        craneRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        stockpileRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        chamberRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        counterweightRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        targets.removeAll()
        placed.removeAll()
        reserved.removeAll()
        placedNodes.removeAll()
        cranes.removeAll()

        counterweight = nil
        counterweightCable = nil
        slabCable = nil

        buildFoundation()
        buildTargets()
        buildChambers()
        buildCounterweightSystem()
        buildStockpiles()
        buildCranes()

        placedCount = 0
        totalCount = targets.count
        status = "Construction reset"
        detail = "Starting again from the foundation."
        isRunning = true
        singleStep = false

        refreshUI()
        start()
    }

    private func tick(_ dt: Float) {
        guard isRunning || singleStep else { return }

        let effectiveDT: Float = singleStep
            ? 0.2
            : dt * Float(animationSpeed)

        singleStep = false

        for i in cranes.indices {
            advanceCrane(i, effectiveDT)
        }

        assignTargets()
        placedCount = placed.count

        if placedCount >= totalCount {
            status = "Construction complete"
            detail = "All modeled targets have been placed."
            isRunning = false
        }

        refreshUI()
    }

    // MARK: Assign targets

    private func assignTargets() {
        for i in cranes.indices {
            guard cranes[i].phase == .idle,
                  cranes[i].target == nil else {
                continue
            }

            guard let target = nextTarget() else {
                continue
            }

            cranes[i].target = target
            cranes[i].phase = .pickup
            cranes[i].elapsed = 0
            cranes[i].start = stockPosition(
                cranes[i].stockpileIndex
            )

            reserved.insert(target.id)

            let color: UIColor = target.isRoofSlab
                ? UIColor(
                    red: 0.82,
                    green: 0.69,
                    blue: 0.40,
                    alpha: 1
                )
                : UIColor(
                    red: 0.68,
                    green: 0.60,
                    blue: 0.48,
                    alpha: 1
                )

            let block = addBox(
                blockRoot,
                cranes[i].start,
                target.size,
                color,
                chamfer: 0.015
            )

            block.eulerAngles = SCNVector3(
                0,
                0,
                target.rotationZ
            )

            if target.isRoofSlab {
                let frame = SCNBox(
                    width: CGFloat(target.size.x + 0.07),
                    height: CGFloat(target.size.y + 0.07),
                    length: CGFloat(target.size.z + 0.07),
                    chamferRadius: 0
                )

                frame.firstMaterial?.diffuse.contents = UIColor.white
                frame.firstMaterial?.fillMode = .lines

                block.addChildNode(SCNNode(geometry: frame))

                status = "Preparing roof slab haul"
                detail = "Preparing an individual 80-ton roof slab."
            } else {
                status = "Loading ordinary block"
                detail = "\(cranes[i].name) loads from its assigned corner."
            }

            cranes[i].block = block
        }
    }

    // MARK: Course-by-course scheduler

    private func nextTarget() -> StoneTarget? {
        // Determine the lowest course that still has unplaced targets,
        // including targets currently reserved by another lift.
        let unfinished = targets.filter {
            !placed.contains($0.id)
        }

        guard let lowestCourse = unfinished.map(\.course).min() else {
            return nil
        }

        // Only assign targets from this course. If all remaining targets
        // are reserved, wait rather than advancing to a higher course.
        let available = unfinished.filter {
            $0.course == lowestCourse &&
            !reserved.contains($0.id)
        }

        return available.min {
            simd_length($0.position) < simd_length($1.position)
        }
    }

    // MARK: Crane animation

    private func advanceCrane(_ i: Int, _ dt: Float) {
        guard let target = cranes[i].target,
              let block = cranes[i].block else {
            return
        }

        if target.isRoofSlab {
            advanceRoofSlab(i, target, block, dt)
        } else {
            advanceOrdinaryBlock(i, target, block, dt)
        }
    }

    private func advanceOrdinaryBlock(
        _ i: Int,
        _ target: StoneTarget,
        _ block: SCNNode,
        _ dt: Float
    ) {
        cranes[i].elapsed += dt

        let start = cranes[i].start
        let destination = target.position
        let clearance: Float = 2.0

        switch cranes[i].phase {
        case .idle:
            break

        case .pickup:
            let t = smooth(cranes[i].elapsed / 0.7)
            let p = mix(
                start,
                start + SIMD3<Float>(0, 0.3, 0),
                t
            )

            block.position = scn(p)
            poseCrane(i, p)

            if cranes[i].elapsed >= 0.7 {
                setPhase(i, .lifting)
            }

        case .lifting:
            let raised = SIMD3<Float>(
                start.x,
                max(start.y, destination.y) + clearance,
                start.z
            )

            let t = smooth(cranes[i].elapsed / 1.1)
            let p = mix(start, raised, t)

            block.position = scn(p)
            poseCrane(i, p)

            if cranes[i].elapsed >= 1.1 {
                setPhase(i, .hauling)
            }

        case .hauling:
            let y = max(start.y, destination.y) + clearance

            let a = SIMD3<Float>(start.x, y, start.z)
            let b = SIMD3<Float>(destination.x, y, destination.z)

            let t = smooth(cranes[i].elapsed / 2.4)
            let p = mix(a, b, t)

            block.position = scn(p)
            poseCrane(i, p)

            if cranes[i].elapsed >= 2.4 {
                setPhase(i, .lowering)
            }

        case .lowering:
            let raised = SIMD3<Float>(
                destination.x,
                max(start.y, destination.y) + clearance,
                destination.z
            )

            let t = smooth(cranes[i].elapsed / 1.0)
            let p = mix(raised, destination, t)

            block.position = scn(p)
            poseCrane(i, p)

            if cranes[i].elapsed >= 1.0 {
                setPhase(i, .releasing)
            }

        case .releasing:
            poseCrane(i, destination)

            if cranes[i].elapsed >= 0.35 {
                commit(target, block, i)
            }
        }
    }

    // MARK: Roof slab hauling

    private func advanceRoofSlab(
        _ i: Int,
        _ target: StoneTarget,
        _ block: SCNNode,
        _ dt: Float
    ) {
        cranes[i].elapsed += dt

        let stock = cranes[i].start
        let destination = target.position

        let raisedDestination = SIMD3<Float>(
            destination.x,
            destination.y + 0.35,
            destination.z
        )

        switch cranes[i].phase {
        case .idle:
            break

        case .pickup:
            let t = smooth(cranes[i].elapsed / 0.8)

            let pickupPosition = mix(
                stock,
                stock + SIMD3<Float>(0, 0.25, 0),
                t
            )

            block.position = scn(pickupPosition)
            poseCrane(i, pickupPosition)

            if cranes[i].elapsed >= 0.8 {
                setPhase(i, .lifting)
                status = "Roof slab attached"
                detail = "Moving the 80-ton slab toward the exterior hauling track."
            }

        case .lifting:
            let t = smooth(cranes[i].elapsed / 1.3)

            let liftingPosition = mix(
                stock,
                rampBase,
                t
            )

            block.position = scn(liftingPosition)
            poseCrane(i, liftingPosition)

            if cranes[i].elapsed >= 1.3 {
                setPhase(i, .hauling)
                status = "Counterweight hauling"
                detail = "Animating the counterweight and slab along the exterior ramp."
            }

        case .hauling:
            let t = smooth(cranes[i].elapsed / 7.0)
            let slabPosition: SIMD3<Float>

            if t < 0.62 {
                let rampProgress = t / 0.62
                slabPosition = mix(
                    rampBase,
                    queenTransfer,
                    rampProgress
                )

                status = "Counterweight hauling"
                detail = "The slab is traveling up the exterior inclined track."
            } else {
                let transferProgress = (t - 0.62) / 0.38
                slabPosition = mix(
                    queenTransfer,
                    raisedDestination,
                    transferProgress
                )

                status = "Sliding roof slab inward"
                detail = "The slab is moving from transfer height toward its roof position."
            }

            block.position = scn(slabPosition)
            poseCrane(i, slabPosition)

            let weightY = pulleyPosition.y - 0.2 - 1.7 * t
            let weightPosition = SIMD3<Float>(
                0,
                weightY,
                0.75
            )

            counterweight?.position = scn(weightPosition)

            updateCable(
                counterweightCable,
                from: pulleyPosition,
                to: weightPosition
            )

            updateCable(
                slabCable,
                from: pulleyPosition,
                to: slabPosition
            )

            if cranes[i].elapsed >= 7.0 {
                setPhase(i, .lowering)
            }

        case .lowering:
            let t = smooth(cranes[i].elapsed / 1.2)

            let loweringPosition = mix(
                raisedDestination,
                destination,
                t
            )

            block.position = scn(loweringPosition)
            poseCrane(i, loweringPosition)

            if cranes[i].elapsed >= 1.2 {
                setPhase(i, .releasing)
            }

        case .releasing:
            poseCrane(i, destination)

            if cranes[i].elapsed >= 0.5 {
                commit(target, block, i)

                let resetWeightPosition = SIMD3<Float>(
                    0,
                    pulleyPosition.y - 0.35,
                    0.75
                )

                counterweight?.position = scn(resetWeightPosition)

                updateCable(
                    counterweightCable,
                    from: pulleyPosition,
                    to: resetWeightPosition
                )

                updateCable(
                    slabCable,
                    from: pulleyPosition,
                    to: queenTransfer
                )
            }
        }
    }

    private func setPhase(
        _ i: Int,
        _ phase: CranePhase
    ) {
        cranes[i].phase = phase
        cranes[i].elapsed = 0
    }

    // MARK: Boom, brace, hook, and cable animation

    private func poseCrane(
        _ i: Int,
        _ worldLoadPosition: SIMD3<Float>
    ) {
        let craneBase = vec(cranes[i].root.position)
        let localLoad = worldLoadPosition - craneBase

        let pivot = SIMD3<Float>(0, 2.3, 0)
        let lowerBraceAnchor = SIMD3<Float>(0, 0.5, 0)

        let boomVector = localLoad - pivot
        let distance = simd_length(boomVector)

        guard distance > 0.01 else { return }

        let direction = simd_normalize(boomVector)
        let visualLength = min(distance, 12)
        let tip = pivot + direction * visualLength

        let wood = UIColor(
            red: 0.43,
            green: 0.27,
            blue: 0.14,
            alpha: 1
        )

        updateBeam(
            cranes[i].boom,
            from: pivot,
            to: tip,
            radius: 0.1,
            color: wood
        )

        updateBeam(
            cranes[i].brace,
            from: lowerBraceAnchor,
            to: tip,
            radius: 0.065,
            color: wood
        )

        let hookPosition = localLoad + SIMD3<Float>(0, -0.25, 0)
        cranes[i].hook.position = scn(hookPosition)

        updateBeam(
            cranes[i].cable,
            from: tip,
            to: hookPosition,
            radius: 0.025,
            color: .darkGray
        )
    }

    // MARK: Placement validation

    private func commit(
        _ target: StoneTarget,
        _ block: SCNNode,
        _ craneIndex: Int
    ) {
        let failures = placementFailures(
            target,
            craneIndex
        )

        if engineeringMode && !failures.isEmpty {
            reserved.remove(target.id)
            block.removeFromParentNode()

            cranes[craneIndex].phase = .idle
            cranes[craneIndex].elapsed = 0
            cranes[craneIndex].target = nil
            cranes[craneIndex].block = nil

            status = "Placement blocked"
            detail = failures.joined(separator: ", ") +
                " check(s) failed."

            return
        }

        block.position = scn(target.position)
        block.eulerAngles = SCNVector3(
            0,
            0,
            target.rotationZ
        )

        placed.insert(target.id)
        reserved.remove(target.id)
        placedNodes[target.id] = block

        status = target.isRoofSlab
            ? "Roof slab placed"
            : "Block placed"

        detail = target.isRoofSlab
            ? "Roof slab committed at its modeled position."
            : "Course \(target.course + 1) block placed."

        cranes[craneIndex].phase = .idle
        cranes[craneIndex].elapsed = 0
        cranes[craneIndex].target = nil
        cranes[craneIndex].block = nil
    }

    private func placementFailures(
        _ target: StoneTarget,
        _ craneIndex: Int
    ) -> [String] {
        let cranePosition = vec(
            cranes[craneIndex].root.position
        )

        let reach = simd_length(
            SIMD3<Float>(
                target.position.x - cranePosition.x,
                0,
                target.position.z - cranePosition.z
            )
        )

        let mass: Float = target.isRoofSlab
            ? roofMassKg
            : 2500

        let weightKN = mass * 9.81 / 1000
        let moment = weightKN * reach

        let reachPass = target.isRoofSlab ||
            !engineeringMode ||
            reach <= maximumReach

        let momentPass = target.isRoofSlab ||
            !engineeringMode ||
            moment <= maximumMomentKNm

        // The roof slab uses a simplified bearing test against the
        // chamber side walls, rather than requiring support at its center.
        let supportPass: Bool
        if target.course == 0 {
            supportPass = true
        } else if target.isRoofSlab {
            supportPass = hasRoofBearingSupport(target)
        } else {
            supportPass = hasSupport(target)
        }

        let overlapPass = !hasOverlap(target)

        var failures: [String] = []

        if !reachPass {
            failures.append("Reach")
        }

        if !momentPass {
            failures.append("Moment")
        }

        if !supportPass {
            failures.append("Support")
        }

        if !overlapPass {
            failures.append("Overlap")
        }

        return failures
    }

    private func hasSupport(
        _ target: StoneTarget
    ) -> Bool {
        let expectedY = target.position.y - courseHeight
        let tolerance = courseHeight * 0.65

        return targets.contains { other in
            guard placed.contains(other.id),
                  other.id != target.id else {
                return false
            }

            guard abs(other.position.y - expectedY) <= tolerance else {
                return false
            }

            return footprintsOverlap(target, other)
        }
    }

    private func hasRoofBearingSupport(
        _ target: StoneTarget
    ) -> Bool {
        // Simplified geometric check: require placed targets close to
        // both sides of the chamber footprint at the supporting course.
        let expectedY = courseY(roofSlabCourse - 1)
        let tolerance = courseHeight * 1.5

        let bearingTargets = targets.filter { other in
            guard placed.contains(other.id),
                  !other.isRoofSlab,
                  abs(other.position.y - expectedY) <= tolerance else {
                return false
            }

            return abs(other.position.x) >= 1.23 &&
                abs(other.position.x) <= 2.5 &&
                abs(other.position.z) <= 1.8
        }

        return !bearingTargets.isEmpty
    }

    private func hasOverlap(
        _ target: StoneTarget
    ) -> Bool {
        targets.contains { other in
            guard placed.contains(other.id),
                  other.id != target.id else {
                return false
            }

            let overlapsX =
                abs(target.position.x - other.position.x) <
                (target.size.x + other.size.x) / 2

            let overlapsY =
                abs(target.position.y - other.position.y) <
                (target.size.y + other.size.y) / 2

            let overlapsZ =
                abs(target.position.z - other.position.z) <
                (target.size.z + other.size.z) / 2

            return overlapsX && overlapsY && overlapsZ
        }
    }

    private func footprintsOverlap(
        _ a: StoneTarget,
        _ b: StoneTarget
    ) -> Bool {
        abs(a.position.x - b.position.x) <
            (a.size.x + b.size.x) / 2 &&
        abs(a.position.z - b.position.z) <
            (a.size.z + b.size.z) / 2
    }

    // MARK: UI state

    private func refreshUI() {
        placedCount = placed.count

        craneRows = cranes.map { crane in
            let phase: String

            switch crane.phase {
            case .idle:
                phase = "Available"

            case .pickup:
                phase = "Attaching load"

            case .lifting:
                phase = "Lifting"

            case .hauling:
                phase = crane.target?.isRoofSlab == true
                    ? "Counterweight / inward transfer"
                    : "Transporting"

            case .lowering:
                phase = "Lowering"

            case .releasing:
                phase = "Validating placement"
            }

            return CraneRow(
                id: crane.id,
                name: crane.name,
                phase: phase,
                load: crane.target?.isRoofSlab == true
                    ? "80 t"
                    : (
                        crane.target == nil
                        ? "—"
                        : "Stone"
                    )
            )
        }
    }
}
