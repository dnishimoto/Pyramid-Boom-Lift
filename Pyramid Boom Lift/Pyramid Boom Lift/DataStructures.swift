
//
//  DataStructures.swift
//  Pyramid Boom Lift
//
//  Created by David Nishimoto on 10/13/26.
//

import Foundation
import SceneKit
import simd

// MARK: - Models

struct StoneTarget: Identifiable {
    let id: Int
    let course: Int
    var quadrant: Int = 0
    let position: SIMD3<Float>
    let size: SIMD3<Float>
    let isRoofSlab: Bool
    var rotationX: Float = 0
    var rotationZ: Float = 0
}

// MARK: - Crane State

enum CranePhase {
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
    let physics: String
    let isEnabled: Bool
}

// MARK: - Crane Model

struct Crane {
    let id: Int
    let name: String
    let stockpileIndex: Int

    let root: SCNNode
    let boom: SCNNode
    let brace: SCNNode
    let hook: SCNNode
    let cable: SCNNode
    let tackleRoot: SCNNode
    let boomTrussMembers: [SCNNode]

    var enabled: Bool = true
    var physicsText: String = "Ready"
    var phase: CranePhase = .idle
    var elapsed: Float = 0
    var target: StoneTarget?
    var block: SCNNode?
    var start: SIMD3<Float> = .zero
}

// MARK: - Heavy Haul

enum HaulStage {
    case exteriorRamp
    case inwardTransfer
}

