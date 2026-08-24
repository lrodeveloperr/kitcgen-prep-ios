import SwiftUI

public enum KitchenBackendState:String,Sendable {
    case home="HOME", createBoard="CREATE_BOARD", quickReview="QUICK_REVIEW", selectMode="SELECT_MODE",
         modeSetup="MODE_SPECIFIC_SETUP", prepGap="PREP_GAP", timing="TIMING_OBJECTIVE",
         build="BUILD_EXECUTION_GRAPH", ready="READY_OVERVIEW", run="RUN_BOARD",
         paused="PAUSED_BOARD", finish="FINISH", reuse="REUSE_OR_HOME", settings="SETTINGS"
}
public enum BoardMode:Sendable { case home, station }
public enum TimingMode:Sendable { case cookNow, serveAt, readyBy }
public enum TaskStatus:Sendable { case blocked, available, active, waiting, done, skipped }

public struct PrepTask:Identifiable,Sendable {
    public let id:String; let text:String; let status:TaskStatus; let minutes:Int?; let detail:String?
}
public struct KitchenUIState:Sendable {
    var backendState:KitchenBackendState = .home
    var onboardingPage:Int = 0
    var onboardingComplete=false
    var safetyDisclosureNeeded=true
    var boardTitle="Dinner prep"
    var sourceText=""
    var mode:BoardMode?=nil
    var timing:TimingMode?=nil
    var paused=false
    var settingsReturn:KitchenBackendState = .home
    var tasks:[PrepTask]=[
        PrepTask(id:"t1",text:"Roast vegetables",status:.active,minutes:18,detail:"Oven • started 7 min ago"),
        PrepTask(id:"t2",text:"Make herb dressing",status:.available,minutes:8,detail:"No dependency"),
        PrepTask(id:"t3",text:"Rest cooked chicken",status:.waiting,minutes:6,detail:"Timer running"),
        PrepTask(id:"t4",text:"Warm plates",status:.blocked,minutes:4,detail:"After roast vegetables"),
        PrepTask(id:"t5",text:"Wash salad leaves",status:.done,minutes:5,detail:"Completed"),
    ]
}
