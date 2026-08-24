#if DEBUG
import SwiftUI

#Preview("Kitchen Prep Board — compact") {
    KitchenPrepRoot(backend: PreviewKitchenBackend())
}

#Preview("Run board — wide") {
    PreviewWideHost()
}

@MainActor
private struct PreviewWideHost: View {
    @StateObject private var backend = PreviewKitchenBackend()
    var body: some View {
        KitchenPrepRoot(backend: backend)
            .frame(width: 1024, height: 768)
            .task {
                backend.dispatch("ONBOARD_NEXT",payload:nil)
                backend.dispatch("ONBOARD_NEXT",payload:nil)
                backend.dispatch("NEW_BOARD",payload:nil)
                backend.dispatch("INPUT_CAPTURED",payload:nil)
                backend.dispatch("REVIEW_CONFIRMED",payload:nil)
                backend.dispatch("MODE_STATION",payload:nil)
                backend.dispatch("MODE_CONFIRMED",payload:nil)
                backend.dispatch("PREP_GAP_CONFIRMED",payload:nil)
                backend.dispatch("TIMING_COOK_NOW",payload:nil)
                backend.dispatch("BOARD_STARTED",payload:nil)
            }
    }
}
#endif
