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



struct ContentView: View {
    @StateObject private var controller = PyramidConstructionController()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PYRAMID BOOM LIFT").font(.headline.bold())
                    Text("Four independent lifts • Four stockpiles • 16-part tackle • Counterweight roof haul")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button("Reset", systemImage: "arrow.counterclockwise") { controller.reset() }
                    .buttonStyle(.bordered)
            }
            .padding()

            SceneView(scene: controller.scene, pointOfView: controller.cameraNode,
                      options: [.allowsCameraControl, .autoenablesDefaultLighting])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    statusPanel
                    runControls
                    courseCountControl
                    roofHaulHeightControl
                    speedControl
                    engineeringControl
                    stockpilePanel
                    cranePanel
                    pipelinePanel
                    equationsPanel
                }
                .padding()
            }
            .frame(maxHeight: 420)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .onAppear { controller.start() }
        .onDisappear { controller.stop() }
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



    private var courseCountControl: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Pyramid levels")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(controller.courseCount)")
                    .font(.caption.monospacedDigit())
            }
            Slider(
                value: Binding(
                    get: { Double(controller.courseCount) },
                    set: { controller.courseCount = Int($0.rounded()) }
                ),
                in: 8...25,
                step: 1
            )
            Text("Choose 8–100 courses. The model rebuilds and recalculates chamber and roof-haul height.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onChange(of: controller.courseCount) { _, _ in controller.reset() }
    }

    private var roofHaulHeightControl: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Queen’s Avenue counterweight switch")
                    .font(.subheadline.bold())
                Spacer()
                Text(String(format: "%.2f m", controller.roofHaulTriggerHeightM))
                    .font(.caption.monospacedDigit())
            }
            Text("Automatic: the roof-haul course is recalculated from the selected pyramid height. Counterweight hauling becomes eligible only after all masonry below and around the roof opening is placed and completed height reaches the trigger.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var stockpilePanel: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Corner stockpile inventory")
                .font(.headline)
            ForEach(0..<4, id: \.self) { index in
                HStack {
                    Text(["NW", "NE", "SW", "SE"][index])
                        .font(.caption.bold())
                    Text("Lift \(index + 1)")
                        .font(.caption)
                    Spacer()
                    Text("\(controller.stockpileCounts[index]) blocks")
                        .font(.caption.monospacedDigit())
                }
            }
            Text("Counts represent modeled inventory; the visible piles are scaled visual samples.")
                .font(.caption2)
                .foregroundStyle(.secondary)
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

                in: 0.25...500.0,

                step: 0.25

            )



            HStack {

                Text("0.25×")

                Spacer()

                Text("2.5×")

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

                ? "Reach, moment, support, and overlap checks are enforced at placement."

                : "Visual mode permits placements that fail reach or moment checks, but still reports the modeled geometry."

            )

            .font(.caption)

            .foregroundStyle(.secondary)

        }

    }



    private var cranePanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Four Boom Lifts")
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
            Text("Live lifting model").font(.headline)
            Text("Weight: W = m × g")
            Text("16-part tackle: T ≈ W / (16 × efficiency)")
            Text("Boom moment: M = W × horizontal reach")
            Text("Lifting energy: E = m × g × Δh + friction work")
            Text("Counterweight energy: Eᶜʷ = mᶜʷ × g × drop × efficiency")
            Text("A load is not placed unless its calculated gates pass. This is a conceptual model, not certified lifting engineering.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}


