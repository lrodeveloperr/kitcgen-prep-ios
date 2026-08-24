import SwiftUI

@MainActor
public protocol KitchenBackendPort:ObservableObject {
    var state:KitchenUIState { get }
    func dispatch(_ action:String,payload:String?)
}

/**
 Presentation adapter only. It does not claim to implement the supplied Android backend.
 The source contract defines Room, Android alarm behavior, AdMob/UMP and Google Play billing;
 none of those are silently translated into iOS services here.
 */
@MainActor
public final class PreviewKitchenBackend:KitchenBackendPort {
    @Published public private(set) var state=KitchenUIState()
    public init() {}
    public func dispatch(_ action:String,payload:String?=nil) {
        switch action {
        case "ONBOARD_NEXT":
            if state.onboardingPage < 1 { state.onboardingPage += 1 } else { state.onboardingComplete=true }
        case "NEW_BOARD": state.backendState = .createBoard
        case "INPUT_CAPTURED": state.sourceText=payload ?? state.sourceText; state.backendState = .quickReview
        case "REVIEW_CONFIRMED": state.backendState = .selectMode
        case "MODE_HOME": state.mode = .home; state.backendState = .modeSetup
        case "MODE_STATION": state.mode = .station; state.backendState = .modeSetup
        case "MODE_CONFIRMED": state.backendState = state.mode == .station ? .prepGap : .timing
        case "PREP_GAP_CONFIRMED": state.backendState = .timing
        case "TIMING_COOK_NOW": state.timing = .cookNow; state.backendState = .ready
        case "TIMING_SERVE_AT": state.timing = .serveAt; state.backendState = .ready
        case "TIMING_READY_BY": state.timing = .readyBy; state.backendState = .ready
        case "BOARD_STARTED": state.backendState = .run; state.paused=false
        case "PAUSE": state.backendState = .paused; state.paused=true
        case "RESUME": state.backendState = .run; state.paused=false
        case "OPEN_FINISH": state.backendState = .finish
        case "FINISH_ANYWAY": state.backendState = .reuse
        case "RETURN_HOME": state.backendState = .home
        case "SETTINGS": state.settingsReturn=state.backendState; state.backendState = .settings
        case "CLOSE_SETTINGS": state.backendState=state.settingsReturn
        case "SAFETY_ACK": state.safetyDisclosureNeeded=false
        default: break
        }
    }
}
