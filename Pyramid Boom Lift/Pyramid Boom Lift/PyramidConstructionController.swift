
//
//  PyramidConstructionController.swift
//  Pyramid Boom Lift
//
//  Created by David Nishimoto on 10/13/26.
//

import Foundation
import SwiftUI
import SceneKit
import Combine
import simd

final class PyramidConstructionController: ObservableObject {

    // MARK: - Published UI state

    @Published var status = "Initializing"
    @Published var detail = "Preparing the foundation and four stockpiles."
    @Published var isRunning = true
    @Published var engineeringMode = false
    @Published var animationSpeed: Double = 1.0
    @Published var courseCount: Int = 21
    @Published var placedCount = 0
    @Published var totalCount = 0
    @Published var craneRows: [CraneRow] = []

    @Published var pipeline: [(String, String, String)] = [
        ("1", "Foundation and datum", "Establish the base and first course."),
        ("2", "Four corner stockpiles", "Keep stockpiles assigned to their respective lifts."),
        ("3", "Ordinary course placement", "Place blocks from the lowest incomplete course upward."),
        ("4", "Chamber construction", "Red chamber volumes are visual guides."),
        ("5", "Reserve roof footprint", "Keep the roof slab footprint clear of ordinary blocks."),
        ("6", "Counterweight hauling", "Animate the counterweight as the roof slab rises."),
        ("7", "Slide slab inward", "Transfer the slab at chamber height."),
        ("8", "Verify roof placement", "Run placement checks before committing the slab."),
        ("9", "Resume upper courses", "Continue ordinary placement above the roof."),
        ("10", "Finish and verify", "Place all modeled targets.")
    ]

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(placedCount) / Double(totalCount)
    }

    // MARK: - Scene

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

    // MARK: - Pyramid geometry

    private var courses: Int {
        max(3, min(210, courseCount))
    }

    private let courseHeight: Float = 0.42
    private let spacing: Float = 0.82

    /// The base course has 2 * (courses - 1) + 1 blocks across.
    private var baseHalfBlocks: Int {
        courses - 1
    }

    /// Approximate exterior base width in model metres.
    var baseWidthM: Double {
        Double(2 * baseHalfBlocks + 1) * Double(spacing)
    }

    var totalHeightM: Double {
        Double(courses) * Double(courseHeight)
    }

    /// Course at which the roof-slab operation is modeled.
    private var roofCourse: Int {
        max(1, min(courses - 2, Int(Double(courses - 1) * 0.54)))
    }

    private var chamberLowerCourse: Int {
        max(1, roofCourse - 3)
    }

    private var chamberUpperCourse: Int {
        max(chamberLowerCourse, roofCourse - 1)
    }

    private let roofMassKg: Float = 80_000
    private let maximumReach: Float = 12
    private let maximumMomentKNm: Float = 220

    // Illustrative hauling route. These coordinates are not scaled with
    // the pyramid yet and must be recalibrated for very large course counts.
    private let rampBase = SIMD3<Float>(-7.0, 0.55, 0)
    private let queenTransfer = SIMD3<Float>(-2.8, 2.65, 0)
    private let pulleyPosition = SIMD3<Float>(-2.8, 3.35, 0)

    private var counterweight: SCNNode?
    private var counterweightCable: SCNNode?
    private var slabCable: SCNNode?

    // MARK: - Inventory

    var stockpileCounts: [Int] {
        var counts = [0, 0, 0, 0]

        for target in targets {
            if placed.contains(target.id) || reserved.contains(target.id) {
                continue
            }

            let p = target.position

            let index: Int
            if p.x < 0 && p.z < 0 {
                index = 0
            } else if p.x >= 0 && p.z < 0 {
                index = 1
            } else if p.x < 0 && p.z >= 0 {
                index = 2
            } else {
                index = 3
            }

            counts[index] += 1
        }

        return counts
    }

    var roofHaulTriggerHeightM: Double {
        Double(roofCourse) * Double(courseHeight)
    }

    // MARK: - Initialization

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
        start()
    }

    // MARK: - Scene setup

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

        let groundWidth = CGFloat(max(28.0, baseWidthM + 18.0))

        let ground = SCNBox(
            width: groundWidth,
            height: 0.15,
            length: groundWidth,
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

        let cameraDistance = Float(max(17.0, baseWidthM * 1.25))
        let cameraHeight = Float(max(13.0, totalHeightM * 1.4))

        cameraNode.position = SCNVector3(
            cameraDistance,
            cameraHeight,
            cameraDistance
        )

        cameraNode.look(at: SCNVector3(0, Float(totalHeightM * 0.35), 0))
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
        _ parent: SCNNode,
        from a: SIMD3<Float>,
        to b: SIMD3<Float>,
        radius: CGFloat,
        color: UIColor
    ) -> SCNNode {
        let delta = b - a
        let length = max(0.01, simd_length(delta))

        let geometry = SCNCylinder(
            radius: radius,
            height: CGFloat(length)
        )

        geometry.radialSegmentCount = 8
        geometry.materials = [mat(color)]

        let node = SCNNode(geometry: geometry)
        node.position = scn((a + b) / 2)
        node.look(
            at: scn(b),
            up: SCNVector3(0, 1, 0),
            localFront: SCNVector3(0, 1, 0)
        )

        parent.addChildNode(node)
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
        let length = max(0.01, simd_length(delta))

        let geometry = SCNCylinder(
            radius: radius,
            height: CGFloat(length)
        )

        geometry.radialSegmentCount = 8
        geometry.materials = [mat(color)]

        node.geometry = geometry
        node.position = scn((a + b) / 2)
        node.look(
            at: scn(b),
            up: SCNVector3(0, 1, 0),
            localFront: SCNVector3(0, 1, 0)
        )
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

    // MARK: - Foundation

    private func buildFoundation() {
        let width = CGFloat(baseWidthM + 2.0)

        let geometry = SCNBox(
            width: width,
            height: 0.18,
            length: width,
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

    // MARK: - Target generation

    private func buildTargets() {
        targets.removeAll()
        nextID = 0

        for course in 0..<courses {
            let y = 0.22 + Float(course) * courseHeight

            // Key geometry rule:
            // Each course loses one block from each edge.
            // The last course has one centered block.
            let half = courses - 1 - course

            for xCell in (-half)...half {
                for zCell in (-half)...half {
                    let x = Float(xCell) * spacing
                    let z = Float(zCell) * spacing

                    // Reserve the roof-slab footprint.
                    if course == roofCourse &&
                        abs(x) <= 1.65 &&
                        abs(z) <= 1.65 {
                        continue
                    }

                    // Reserve an interior chamber volume.
                    if (chamberLowerCourse...chamberUpperCourse).contains(course) &&
                        abs(xCell) <= 1 &&
                        abs(zCell) <= 1 {
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
                            isRoofSlab: false
                        )
                    )

                    nextID += 1
                }
            }

            // Three separate roof slabs. Each target represents an
            // 80-tonne slab in this conceptual model.
            if course == roofCourse {
                for slabIndex in 0..<3 {
                    let z = (Float(slabIndex) - 1.0) * 0.88

                    targets.append(
                        StoneTarget(
                            id: nextID,
                            course: roofCourse,
                            position: SIMD3<Float>(0, y, z),
                            size: SIMD3<Float>(2.7, courseHeight, 0.82),
                            isRoofSlab: true
                        )
                    )

                    nextID += 1
                }
            }
        }

        // Sort bottom-up. Ordinary blocks precede roof slabs on the same course.
        targets.sort {
            if $0.course != $1.course {
                return $0.course < $1.course
            }

            if $0.isRoofSlab != $1.isRoofSlab {
                return !$0.isRoofSlab
            }

            return $0.id < $1.id
        }
    }

    // MARK: - Chambers and shafts

    private func buildChambers() {
        chamberRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let scale = Float(courses) / 21.0

        let lower = SCNBox(
            width: CGFloat(2.4 * scale),
            height: CGFloat(0.9 * scale),
            length: CGFloat(2.4 * scale),
            chamferRadius: 0
        )

        lower.firstMaterial?.diffuse.contents = UIColor.red
        lower.firstMaterial?.transparency = 0.34

        let lowerNode = SCNNode(geometry: lower)
        lowerNode.position = SCNVector3(0, 1.8 * scale, 0)
        chamberRoot.addChildNode(lowerNode)

        let queen = SCNBox(
            width: CGFloat(2.25 * scale),
            height: CGFloat(1.15 * scale),
            length: CGFloat(2.25 * scale),
            chamferRadius: 0
        )

        queen.firstMaterial?.diffuse.contents = UIColor.red
        queen.firstMaterial?.transparency = 0.38

        let queenNode = SCNNode(geometry: queen)
        queenNode.position = SCNVector3(0, 2.55 * scale, 0)
        chamberRoot.addChildNode(queenNode)

        _ = addBox(
            chamberRoot,
            SIMD3<Float>(0, 1.35 * scale, 1.85 * scale),
            SIMD3<Float>(0.5 * scale, 0.35 * scale, 2.1 * scale),
            UIColor.orange.withAlphaComponent(0.7)
        )

        _ = addBeam(
            chamberRoot,
            from: SIMD3<Float>(-0.55 * scale, 2.4 * scale, -0.55 * scale),
            to: SIMD3<Float>(-1.6 * scale, 5.0 * scale, -1.6 * scale),
            radius: CGFloat(0.055 * scale),
            color: UIColor.green.withAlphaComponent(0.8)
        )

        _ = addBeam(
            chamberRoot,
            from: SIMD3<Float>(0.55 * scale, 2.4 * scale, -0.55 * scale),
            to: SIMD3<Float>(1.6 * scale, 5.0 * scale, -1.6 * scale),
            radius: CGFloat(0.055 * scale),
            color: UIColor.green.withAlphaComponent(0.8)
        )
    }

    // MARK: - Counterweight system

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

        for z: Float in [-0.38, 0.38] {
            _ = addBeam(
                counterweightRoot,
                from: SIMD3<Float>(rampBase.x, rampBase.y, z),
                to: SIMD3<Float>(queenTransfer.x, queenTransfer.y, z),
                radius: 0.09,
                color: wood
            )
        }

        for i in 0...8 {
            let t = Float(i) / 8
            let p = mix(rampBase, queenTransfer, t)

            _ = addBeam(
                counterweightRoot,
                from: SIMD3<Float>(p.x, p.y, -0.5),
                to: SIMD3<Float>(p.x, p.y, 0.5),
                radius: 0.04,
                color: wood
            )
        }

        for z: Float in [-0.65, 0.65] {
            _ = addBeam(
                counterweightRoot,
                from: SIMD3<Float>(pulleyPosition.x, 2.35, z),
                to: SIMD3<Float>(pulleyPosition.x, 3.8, z),
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

        for z: Float in [0.48, 1.02] {
            for x: Float in [-0.55, 0.55] {
                _ = addBeam(
                    counterweightRoot,
                    from: SIMD3<Float>(x, 1.55, z),
                    to: SIMD3<Float>(x, 3.55, z),
                    radius: 0.045,
                    color: wood
                )
            }
        }

        counterweight = addBox(
            counterweightRoot,
            SIMD3<Float>(0, 2.8, 0.75),
            SIMD3<Float>(0.8, 0.9, 0.8),
            UIColor(white: 0.32, alpha: 1)
        )

        counterweightCable = addBeam(
            counterweightRoot,
            from: pulleyPosition,
            to: SIMD3<Float>(0, 2.8, 0.75),
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

    // MARK: - Stockpiles

    private func buildStockpiles() {
        stockpileRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let half = Float(baseHalfBlocks) * spacing
        let offset = half + 2.0

        let positions: [SIMD3<Float>] = [
            SIMD3<Float>(-offset, 0.2, -offset),
            SIMD3<Float>( offset, 0.2, -offset),
            SIMD3<Float>(-offset, 0.2,  offset),
            SIMD3<Float>( offset, 0.2,  offset)
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

            // Decorative samples only; target inventory is tracked separately.
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
        let half = Float(baseHalfBlocks) * spacing
        let offset = half + 2.0

        switch index {
        case 0:
            return SIMD3<Float>(-offset, 0.55, -offset)
        case 1:
            return SIMD3<Float>(offset, 0.55, -offset)
        case 2:
            return SIMD3<Float>(-offset, 0.55, offset)
        default:
            return SIMD3<Float>(offset, 0.55, offset)
        }
    }

    // MARK: - Four boom lifts

    private func buildCranes() {
        craneRoot.childNodes.forEach {
            $0.removeFromParentNode()
        }

        cranes.removeAll()

        let half = Float(baseHalfBlocks) * spacing
        let offset = max(6.0, half * 0.72)

        let bases: [SIMD3<Float>] = [
            SIMD3<Float>(-offset, 0.35, -offset),
            SIMD3<Float>( offset, 0.35, -offset),
            SIMD3<Float>(-offset, 0.35,  offset),
            SIMD3<Float>( offset, 0.35,  offset)
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

            let boomTrussMembers: [SCNNode] = [
                addBeam(
                    root,
                    from: SIMD3<Float>(0, 1.7, 0),
                    to: SIMD3<Float>(-0.9, 2.15, 0),
                    radius: 0.045,
                    color: wood
                ),
                addBeam(
                    root,
                    from: SIMD3<Float>(-0.9, 2.15, 0),
                    to: initialTip,
                    radius: 0.045,
                    color: wood
                )
            ]

            let tackleRoot = SCNNode()
            tackleRoot.position = scn(initialTip)
            root.addChildNode(tackleRoot)

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
                    cable: cable,
                    tackleRoot: tackleRoot,
                    boomTrussMembers: boomTrussMembers
                )
            )
        }
    }

    // MARK: - Run controls

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
        status = isRunning ? "Construction resumed" : "Construction paused"
    }

    func stepOnce() {
        singleStep = true

        if !isRunning {
            tick(0.2)
        }
    }

    func toggleCrane(_ id: Int) {
        guard cranes.indices.contains(id) else { return }

        cranes[id].enabled.toggle()
        refreshUI()
    }

    func reset() {
        stop()

        blockRoot.childNodes.forEach { $0.removeFromParentNode() }
        craneRoot.childNodes.forEach { $0.removeFromParentNode() }
        stockpileRoot.childNodes.forEach { $0.removeFromParentNode() }
        chamberRoot.childNodes.forEach { $0.removeFromParentNode() }
        counterweightRoot.childNodes.forEach { $0.removeFromParentNode() }

        targets.removeAll()
        placed.removeAll()
        reserved.removeAll()
        placedNodes.removeAll()
        cranes.removeAll()

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

        for i in cranes.indices where cranes[i].enabled {
            advanceCrane(i, effectiveDT)
        }

        assignTargets()
        placedCount = placed.count

        if placedCount >= totalCount {
            status = "Construction complete"
            detail = "All modeled targets are placed; this is a simulation completion check, not engineering certification."
            isRunning = false
        }

        refreshUI()
    }

    // MARK: - Target assignment

    private func assignTargets() {
        for i in cranes.indices {
            guard cranes[i].enabled,
                  cranes[i].phase == .idle,
                  cranes[i].target == nil else {
                continue
            }

            guard let target = nextTarget() else { continue }

            cranes[i].target = target
            cranes[i].phase = .pickup
            cranes[i].elapsed = 0
            cranes[i].start = stockPosition(cranes[i].stockpileIndex)

            reserved.insert(target.id)

            let color: UIColor = target.isRoofSlab
                ? UIColor(red: 0.82, green: 0.69, blue: 0.40, alpha: 1)
                : UIColor(red: 0.68, green: 0.60, blue: 0.48, alpha: 1)

            let block = addBox(
                blockRoot,
                cranes[i].start,
                target.size,
                color,
                chamfer: 0.015
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
                detail = "The special counterweight route handles this 80-tonne slab."
            } else {
                status = "Loading ordinary block"
                detail = "\(cranes[i].name) loads from its assigned corner."
            }

            cranes[i].block = block
        }
    }

    private func nextTarget() -> StoneTarget? {
        let available = targets.filter {
            !placed.contains($0.id) && !reserved.contains($0.id)
        }

        guard let lowest = available.map(\.course).min() else {
            return nil
        }

        // Barrier: no higher course is released until the lowest
        // incomplete course is fully placed.
        let currentCourseTargets = targets.filter { $0.course == lowest }

        guard currentCourseTargets.allSatisfy({
            placed.contains($0.id) || reserved.contains($0.id)
        }) == false else {
            // All targets in this course are either placed or in flight.
            // Other cranes may finish them, but don't reserve a higher course.
            return nil
        }

        return available
            .filter { $0.course == lowest }
            .min {
                simd_length($0.position) < simd_length($1.position)
            }
    }

    // MARK: - Crane animation

    private func advanceCrane(
        _ i: Int,
        _ dt: Float
    ) {
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
            let p = mix(start, start + SIMD3<Float>(0, 0.3, 0), t)

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

            let p = mix(start, raised, smooth(cranes[i].elapsed / 1.1))
            block.position = scn(p)
            poseCrane(i, p)

            if cranes[i].elapsed >= 1.1 {
                setPhase(i, .hauling)
            }

        case .hauling:
            let y = max(start.y, destination.y) + clearance
            let a = SIMD3<Float>(start.x, y, start.z)
            let b = SIMD3<Float>(destination.x, y, destination.z)
            let p = mix(a, b, smooth(cranes[i].elapsed / 2.4))

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

            let p = mix(raised, destination, smooth(cranes[i].elapsed / 1.0))
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
            destination.y + 1.6,
            destination.z
        )

        switch cranes[i].phase {
        case .idle:
            break

        case .pickup:
            let t = smooth(cranes[i].elapsed / 0.8)
            let p = mix(stock, stock + SIMD3<Float>(0, 0.25, 0), t)

            block.position = scn(p)
            poseCrane(i, p)

            if cranes[i].elapsed >= 0.8 {
                setPhase(i, .lifting)
                status = "Roof slab attached"
                detail = "Moving the slab from the corner pickup toward the exterior haul track."
            }

        case .lifting:
            let p = mix(stock, rampBase, smooth(cranes[i].elapsed / 1.3))

            block.position = scn(p)
            poseCrane(i, p)

            if cranes[i].elapsed >= 1.3 {
                setPhase(i, .hauling)
                status = "Counterweight hauling"
                detail = "The counterweight descends as the roof slab travels up the exterior route."
            }

        case .hauling:
            let t = smooth(cranes[i].elapsed / 7.0)
            let p: SIMD3<Float>

            if t < 0.62 {
                p = mix(rampBase, queenTransfer, t / 0.62)
                status = "Counterweight hauling"
                detail = "The roof slab is traveling up the exterior inclined track."
            } else {
                p = mix(
                    queenTransfer,
                    raisedDestination,
                    (t - 0.62) / 0.38
                )
                status = "Sliding roof slab inward"
                detail = "The slab has reached transfer height and is moving toward the roof position."
            }

            block.position = scn(p)
            poseCrane(i, p)

            let weightY = 3.15 - 1.7 * t
            counterweight?.position = SCNVector3(0, weightY, 0.75)

            updateCable(
                counterweightCable,
                from: pulleyPosition,
                to: SIMD3<Float>(0, weightY, 0.75)
            )

            updateCable(slabCable, from: pulleyPosition, to: p)

            if cranes[i].elapsed >= 7.0 {
                setPhase(i, .lowering)
            }

        case .lowering:
            let p = mix(
                raisedDestination,
                destination,
                smooth(cranes[i].elapsed / 1.2)
            )

            block.position = scn(p)
            poseCrane(i, p)

            if cranes[i].elapsed >= 1.2 {
                setPhase(i, .releasing)
            }

        case .releasing:
            poseCrane(i, destination)

            if cranes[i].elapsed >= 0.5 {
                commit(target, block, i)

                counterweight?.position = SCNVector3(0, 2.8, 0.75)

                updateCable(
                    counterweightCable,
                    from: pulleyPosition,
                    to: SIMD3<Float>(0, 2.8, 0.75)
                )
            }
        }
    }

    private func setPhase(_ i: Int, _ phase: CranePhase) {
        cranes[i].phase = phase
        cranes[i].elapsed = 0
    }

    // MARK: - Crane pose

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

    // MARK: - Placement validation

    private func commit(
        _ target: StoneTarget,
        _ block: SCNNode,
        _ craneIndex: Int
    ) {
        let failures = placementFailures(target, craneIndex)

        if engineeringMode && !failures.isEmpty {
            reserved.remove(target.id)
            block.removeFromParentNode()

            cranes[craneIndex].phase = .idle
            cranes[craneIndex].elapsed = 0
            cranes[craneIndex].target = nil
            cranes[craneIndex].block = nil

            status = "Placement blocked"
            detail = failures.joined(separator: ", ") + " check(s) failed."
            return
        }

        block.position = scn(target.position)

        if target.isRoofSlab {
            block.eulerAngles.z = 0.10
        }

        placed.insert(target.id)
        reserved.remove(target.id)
        placedNodes[target.id] = block

        status = target.isRoofSlab ? "Roof slab placed" : "Block placed"
        detail = target.isRoofSlab
            ? "Roof slab committed. Ordinary construction can continue above it."
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
        let cranePosition = vec(cranes[craneIndex].root.position)

        let reach = simd_length(
            SIMD3<Float>(
                target.position.x - cranePosition.x,
                0,
                target.position.z - cranePosition.z
            )
        )

        let mass: Float = target.isRoofSlab ? roofMassKg : 2500
        let weightKN = mass * 9.81 / 1000
        let moment = weightKN * reach

        let reachPass = target.isRoofSlab ||
            !engineeringMode ||
            reach <= maximumReach

        let momentPass = target.isRoofSlab ||
            !engineeringMode ||
            moment <= maximumMomentKNm

        let supportPass = target.course == 0 || hasSupport(target)
        let overlapPass = !hasOverlap(target)

        var failures: [String] = []

        if !reachPass { failures.append("Reach") }
        if !momentPass { failures.append("Moment") }
        if !supportPass { failures.append("Support") }
        if !overlapPass { failures.append("Overlap") }

        return failures
    }

    private func hasSupport(_ target: StoneTarget) -> Bool {
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

    private func hasOverlap(_ target: StoneTarget) -> Bool {
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

    // MARK: - UI refresh

    private func refreshUI() {
        placedCount = placed.count

        craneRows = cranes.map { crane in
            let phase: String

            switch crane.phase {
            case .idle:
                phase = crane.enabled ? "Available" : "Paused"
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
                    : (crane.target == nil ? "—" : "Stone"),
                physics: "Illustrative model",
                isEnabled: crane.enabled
            )
        }
    }
}

