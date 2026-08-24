import SwiftUI

public struct KitchenPrepRoot<Backend:KitchenBackendPort>:View {
    @StateObject private var backend:Backend
    public init(backend:@autoclosure @escaping()->Backend) { _backend=StateObject(wrappedValue:backend()) }
    public var body:some View {
        GoodUseFrame { rt in
            Group {
                if !backend.state.onboardingComplete {
                    OnboardingView(page:backend.state.onboardingPage){backend.dispatch("ONBOARD_NEXT",payload:nil)}
                } else {
                    KitchenScreen(state:backend.state,dispatch:backend.dispatch)
                }
            }
        }
    }
}
