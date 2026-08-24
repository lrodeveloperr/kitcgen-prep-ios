import SwiftUI

struct OnboardingView:View {
    let page:Int; let next:()->Void
    var body:some View {
        VStack(alignment:.leading,spacing:20) {
            if page == 0 {
                Text("Kitchen Prep Board").font(.system(size:30,weight:.semibold))
                Text("Prep without the scramble").font(.system(size:21,weight:.semibold))
                Text("See what to do now, what comes next, and what needs attention—without turning your station into restaurant software.")
                GUSection { Text("Local-first. No account. Your boards stay on this device.").foregroundStyle(.secondary) }
            } else {
                Text("A board in three moves").font(.system(size:30,weight:.semibold))
                Step(1,"Add or paste your tasks"); Step(2,"Choose Home or Station mode"); Step(3,"Choose Cook now, Serve at, or Ready by, then run the board")
            }
            Spacer(minLength:20)
            GUPrimary(page==0 ? "Continue" : "Start",action:next)
        }.padding(.vertical,24)
    }
}
private struct Step:View {
    let n:Int; let text:String
    init(_ n:Int,_ text:String){self.n=n;self.text=text}
    var body:some View { HStack(spacing:12){Text("\(n)").fontWeight(.semibold).padding(10).background(.primary.opacity(0.08)).clipShape(Circle());Text(text)} }
}

@ViewBuilder
func KitchenScreen(state:KitchenUIState,dispatch:@escaping(String,String?)->Void)->some View {
    switch state.backendState {
    case .home: HomeView(state:state,dispatch:dispatch)
    case .createBoard: CreateView(state:state,dispatch:dispatch)
    case .quickReview: ReviewView(state:state,dispatch:dispatch)
    case .selectMode: ModeView(dispatch:dispatch)
    case .modeSetup: ModeSetupView(state:state,dispatch:dispatch)
    case .prepGap: PrepGapView(dispatch:dispatch)
    case .timing: TimingView(dispatch:dispatch)
    case .build: BuildView()
    case .ready: ReadyView(state:state,dispatch:dispatch)
    case .run: RunBoardView(state:state,paused:false,dispatch:dispatch)
    case .paused: RunBoardView(state:state,paused:true,dispatch:dispatch)
    case .finish: FinishView(state:state,dispatch:dispatch)
    case .reuse: ReuseView(dispatch:dispatch)
    case .settings: SettingsView(dispatch:dispatch)
    }
}

private struct Header:View {
    let title:String; let subtitle:String?
    init(_ title:String,_ subtitle:String?=nil){self.title=title;self.subtitle=subtitle}
    var body:some View { VStack(alignment:.leading,spacing:4){Text(title).font(.system(size:21,weight:.semibold)); if let subtitle {Text(subtitle).foregroundStyle(.secondary)}}.frame(maxWidth:.infinity,alignment:.leading).padding(.vertical,16) }
}
private struct SettingsControl:View {
    let action:()->Void
    var body:some View { Button(action:action){GoodUseVectorIcon(key:"settings").frame(width:24,height:24).frame(width:44,height:44)}.buttonStyle(.plain) }
}
private struct ActionRow:View {
    let title:String; let bodyText:String; let action:()->Void
    var body:some View { Button(action:action){HStack{VStack(alignment:.leading,spacing:4){Text(title).fontWeight(.semibold);if !bodyText.isEmpty{Text(bodyText).foregroundStyle(.secondary)}};Spacer();Text("›").font(.title2).foregroundStyle(.secondary)}.padding(.vertical,10)}.buttonStyle(.plain) }
}

private struct HomeView:View {
    let state:KitchenUIState; let dispatch:(String,String?)->Void
    var body:some View {
        ScrollView { VStack(alignment:.leading,spacing:16){
            HStack(alignment:.top){Header("Kitchen Prep Board","Tell the cook what to do now, what comes next, and how to get everything ready together.");SettingsControl{dispatch("SETTINGS",nil)}}
            GUSection(emphasis:true){Text("Start a board").font(.system(size:21,weight:.semibold));Text("Build from scratch or bring in task text. Nothing is uploaded.");GUPrimary("New prep board",icon:"plus"){dispatch("NEW_BOARD",nil)}}
            Text("Start from").font(.system(size:21,weight:.semibold))
            ActionRow(title:"Paste task text",bodyText:"Split non-empty lines into editable tasks"){dispatch("NEW_BOARD",nil)}
            ActionRow(title:"Use a template",bodyText:"Create a fresh board from a saved template"){dispatch("NEW_BOARD",nil)}
            ActionRow(title:"Duplicate a board",bodyText:"Reuse structure without live timers or task status"){dispatch("NEW_BOARD",nil)}
            ActionRow(title:"Reference URL",bodyText:"Stored as a reference only; never fetched or scraped"){dispatch("NEW_BOARD",nil)}
            Text("Recent").font(.system(size:21,weight:.semibold))
            GUSection{HStack{VStack(alignment:.leading){Text("Dinner prep").fontWeight(.semibold);Text("Completed • 8 tasks").foregroundStyle(.secondary)};Spacer()}}
        }.padding(.bottom,24)}
    }
}

private struct CreateView:View {
    let state:KitchenUIState; let dispatch:(String,String?)->Void
    @State private var text="Chop onions\nRoast vegetables\nMake herb dressing\nRest cooked chicken"
    var body:some View {
        ScrollView { VStack(alignment:.leading,spacing:16){
            Header("Add prep tasks","Paste a list or type one task per line.")
            if state.safetyDisclosureNeeded {
                GUSection("Before your first board"){
                    Text("This app is an organizational aid only. It does not guarantee food safety or doneness.")
                    GUPrimary("I understand"){dispatch("SAFETY_ACK",nil)}
                }
            }
            TextEditor(text:$text).frame(minHeight:220).padding(10).overlay(RoundedRectangle(cornerRadius:12).stroke(.secondary.opacity(0.4)))
            Text("Original pasted/shared text is preserved.").font(.footnote).foregroundStyle(.secondary)
            GUPrimary("Review tasks"){dispatch("INPUT_CAPTURED",text)}
        }.padding(.bottom,24)}
    }
}

private struct ReviewView:View {
    let state:KitchenUIState;let dispatch:(String,String?)->Void
    var lines:[String]{let x=state.sourceText.split(separator:"\n").map(String.init);return x.isEmpty ? ["Chop onions","Roast vegetables","Make herb dressing"] : x}
    var body:some View{ScrollView{VStack(alignment:.leading,spacing:12){
        Header("Quick review","Confirm wording, task kind and rough duration before the board is scheduled.")
        ForEach(Array(lines.enumerated()),id:\.offset){i,line in GUSection{HStack{Text("\(i+1)").foregroundStyle(.secondary);VStack(alignment:.leading){Text(line).fontWeight(.semibold);Text(i%2==0 ? "Prep • 8 min":"Cook • 18 min").foregroundStyle(.secondary)};Spacer();Button("Edit"){}.buttonStyle(.plain)}}}
        GUPrimary("Choose mode"){dispatch("REVIEW_CONFIRMED",nil)}
    }.padding(.bottom,24)}}
}

private struct ModeView:View {
    let dispatch:(String,String?)->Void
    var body:some View{VStack(alignment:.leading,spacing:16){
        Header("Where are you cooking?","This changes the setup flow, not your task text.")
        GUSection{Text("Home").font(.system(size:21,weight:.semibold));Text("A focused cooking board without station prep-gap tracking.");GUSecondary("Use Home mode"){dispatch("MODE_HOME",nil)}}
        GUSection(emphasis:true){Text("Station").font(.system(size:21,weight:.semibold));Text("Track target, on-hand and make quantities before running the station.");GUPrimary("Use Station mode"){dispatch("MODE_STATION",nil)}}
    }}
}
private struct ModeSetupView:View {
    let state:KitchenUIState;let dispatch:(String,String?)->Void
    var body:some View{VStack(alignment:.leading,spacing:16){Header(state.mode == .station ? "Station board":"Home board","Your task text stays unchanged. You can override suggestions later.");GUSection{Text(state.mode == .station ? "Prep-gap tracking is available for this board.":"No station inventory or procurement layer is added.")};GUPrimary("Continue"){dispatch("MODE_CONFIRMED",nil)}}}
}
private struct PrepGapView:View {
    let dispatch:(String,String?)->Void
    var body:some View{ScrollView{VStack(alignment:.leading,spacing:12){Header("Prep gap","Set what you need, what you have on hand, and what must be made.");GUSection{Text("Herb dressing").fontWeight(.semibold);Text("Target 800 ml • On hand 250 ml • Make 550 ml");GUStatus("On-hand not verified",tone:"warning")};GUSection{Text("Roast vegetables").fontWeight(.semibold);Text("Target 12 portions • On hand 4 • Make 8");GUStatus("On-hand not verified",tone:"warning")};Text("On-hand resets per shift. This is not an inventory ledger.").foregroundStyle(.secondary);GUPrimary("Set timing"){dispatch("PREP_GAP_CONFIRMED",nil)}}.padding(.bottom,24)}}
}
private struct TimingView:View {
    let dispatch:(String,String?)->Void
    var body:some View{VStack(alignment:.leading,spacing:16){Header("Timing objective","The schedule is a suggestion. Your overrides always win.");Choice("Cook now","Start from the current time"){dispatch("TIMING_COOK_NOW",nil)};Choice("Serve at","Work backward from a serving time"){dispatch("TIMING_SERVE_AT",nil)};Choice("Ready by","Work backward from a ready deadline"){dispatch("TIMING_READY_BY",nil)}}}
}
private struct Choice:View {let title:String;let bodyText:String;let action:()->Void;init(_ t:String,_ b:String,action:@escaping()->Void){title=t;bodyText=b;self.action=action};var body:some View{Button(action:action){VStack(alignment:.leading,spacing:6){Text(title).fontWeight(.semibold);Text(bodyText).foregroundStyle(.secondary)}.padding(16).frame(maxWidth:.infinity,alignment:.leading).overlay(RoundedRectangle(cornerRadius:16).stroke(.secondary.opacity(0.35)))}.buttonStyle(.plain)}}
private struct BuildView:View {var body:some View{VStack(alignment:.leading,spacing:16){Header("Building suggested schedule");ProgressView();Text("Checking dependencies, durations and available resources.")}}}

private struct ReadyView:View {
    let state:KitchenUIState;let dispatch:(String,String?)->Void
    var body:some View{ScrollView{VStack(alignment:.leading,spacing:12){HStack(alignment:.top){Header("Ready to run","Suggested schedule");SettingsControl{dispatch("SETTINGS",nil)}};ForEach(state.tasks.filter{$0.status != .done}){t in TaskCard(task:t)};Text("Suggestions are not guarantees. Reorder or override when reality changes.").foregroundStyle(.secondary);GUPrimary("Start board",icon:"play"){dispatch("BOARD_STARTED",nil)}}.padding(.bottom,24)}}
}
private struct TaskCard:View {let task:PrepTask;var body:some View{GUSection{HStack{VStack(alignment:.leading){Text(task.text).fontWeight(.semibold);if let d=task.detail{Text(d).foregroundStyle(.secondary)}};Spacer();if let m=task.minutes{Text("\(m) min").fontWeight(.medium)}}}}}

private struct RunBoardView:View {
    @Environment(\.guRuntime) private var rt
    let state:KitchenUIState;let paused:Bool;let dispatch:(String,String?)->Void
    var body:some View{ScrollView{VStack(alignment:.leading,spacing:16){
        HStack(alignment:.top){Header(state.boardTitle,paused ? "Paused • timers continue":"Board running");SettingsControl{dispatch("SETTINGS",nil)}}
        if paused { GUSection(emphasis:true){GUStatus("Paused",tone:"warning");Text("Pausing the board does not pause or extend existing timer deadlines.");GUPrimary("Resume board",icon:"resume"){dispatch("RESUME",nil)}} }
        if rt?.wideBoard == true {
            HStack(alignment:.top,spacing:16){Lane("Now",tasks:state.tasks.filter{$0.status == .active},active:true);Lane("Next",tasks:state.tasks.filter{$0.status == .available || $0.status == .blocked});Lane("Waiting",tasks:state.tasks.filter{$0.status == .waiting},waiting:true)}
        } else {
            Lane("Now",tasks:state.tasks.filter{$0.status == .active},active:true)
            Lane("Waiting",tasks:state.tasks.filter{$0.status == .waiting},waiting:true)
            Lane("Next",tasks:state.tasks.filter{$0.status == .available || $0.status == .blocked})
        }
        Lane("Done",tasks:state.tasks.filter{$0.status == .done || $0.status == .skipped})
        HStack(spacing:8){if !paused{GUSecondary("Pause",icon:"pause"){dispatch("PAUSE",nil)}};GUSecondary("Finish"){dispatch("OPEN_FINISH",nil)}}
    }.padding(.bottom,24)}}
}
private struct Lane:View {
    let title:String;let tasks:[PrepTask];var active=false;var waiting=false
    var body:some View{GUSection(title,emphasis:active){if tasks.isEmpty{Text("Nothing here").foregroundStyle(.secondary)};ForEach(tasks){t in VStack(alignment:.leading,spacing:8){HStack{VStack(alignment:.leading){Text(t.text).fontWeight(.semibold);if let d=t.detail{Text(d).foregroundStyle(.secondary)}};Spacer();if let m=t.minutes{Text("\(m)m").fontWeight(.semibold)}};if active{GUPrimary("Complete",icon:"complete"){};HStack{Button("+1"){};Button("+2"){};Button("+5"){};Button("Still cooking"){}}.buttonStyle(.borderless)}else if waiting{GUStatus("Timer running");GUSecondary("Complete",icon:"complete"){} }else if t.status == .available{GUSecondary("Do next instead"){} }else if t.status == .blocked{GUStatus("Blocked")};Divider()}}}}
}
private struct FinishView:View {
    let state:KitchenUIState;let dispatch:(String,String?)->Void
    var unfinished:Int{state.tasks.filter{$0.status != .done && $0.status != .skipped}.count}
    var body:some View{VStack(alignment:.leading,spacing:16){Header("Finish board","\(unfinished) tasks are unfinished.");GUSection{Text("Finish anyway archives the board as incomplete. It does not mark remaining tasks done.")};GUPrimary("Continue board"){dispatch("BOARD_STARTED",nil)};GUSecondary("Finish anyway"){dispatch("FINISH_ANYWAY",nil)}}}
}
private struct ReuseView:View {
    let dispatch:(String,String?)->Void
    var body:some View{VStack(alignment:.leading,spacing:16){Header("Board saved","Reuse the structure without carrying live task state or timers.");GUSecondary("Save as template",icon:"save"){};GUSecondary("Add note"){};GUPrimary("Return home"){dispatch("RETURN_HOME",nil)}}}
}
private struct SettingsView:View {
    let dispatch:(String,String?)->Void
    let groups:[(String,[String])] = [
        ("Preferences",["Language","Locale","Units","Temperature"]),
        ("Privacy & data",["Privacy choices","Export local data","Import local data","Delete local data"]),
        ("Help",["Help","Privacy policy","Terms","Support"]),
    ]
    var body:some View{ScrollView{VStack(alignment:.leading,spacing:16){Header("Settings","Local-first controls and support.");ForEach(Array(groups.enumerated()),id:\.offset){_,group in
            Text(group.0).font(.system(size:21,weight:.semibold))
            GUSection {
                ForEach(Array(group.1.enumerated()),id:\.offset){index,r in
                    ActionRow(title:r,bodyText:""){}
                    if index < group.1.count - 1 { Divider() }
                }
            }
        };GUSection("Remove ads"){Text("The supplied backend defines Google Play billing only. This SwiftUI skin does not invent a StoreKit product.");Text("Add iOS monetization only when an authoritative iOS backend contract exists.").foregroundStyle(.secondary)};GUPrimary("Done"){dispatch("CLOSE_SETTINGS",nil)}}.padding(.bottom,24)}}
}
