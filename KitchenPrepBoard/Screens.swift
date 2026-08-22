import SwiftUI

private let supportedLanguages = ["English","Spanish","Portuguese","French","German","Italian","Dutch","Polish","Czech","Romanian","Hungarian","Swedish","Danish","Norwegian Bokmål","Finnish","Turkish","Arabic","Hebrew","Hindi","Bengali","Punjabi","Indonesian","Malay","Filipino","Vietnamese","Thai","Japanese","Korean","Simplified Chinese","Traditional Chinese","Russian"]

struct RootView: View {
    @EnvironmentObject var app: AppModel
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack {
            KPB.canvas(colorScheme).ignoresSafeArea()
            switch app.screen {
            case .language: LanguageScreen()
            case .privacy: PrivacyScreen()
            case .home: HomeScreen()
            case .create: CreateScreen()
            case .review: ReviewScreen()
            case .mode: ModeScreen()
            case .setup: SetupScreen()
            case .prepGap: PrepGapScreen()
            case .timing: TimingScreen()
            case .ready: ReadyScreen()
            case .run: RunBoardScreen()
            case .paused: PausedScreen()
            case .finish: FinishScreen()
            case .reuse: ReuseScreen()
            case .settings: SettingsScreen()
            case .settingsDetail: SettingsDetailScreen()
            }
        }.tint(KPB.sage)
    }
}

struct ScreenShell<Content: View>: View {
    let title: String; var back = true; @ViewBuilder var content: Content
    @EnvironmentObject var app: AppModel
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if back { Button(action: app.back) { Image(systemName: "chevron.left").frame(width:44,height:44) } } else { Color.clear.frame(width:44,height:44) }
                Text(title).font(.headline).lineLimit(1).frame(maxWidth:.infinity)
                Color.clear.frame(width:44,height:44)
            }.padding(.horizontal,8).frame(height:56)
            ScrollView {
                VStack(alignment:.leading,spacing:14) { content }.padding(.horizontal,16).padding(.vertical,10)
            }
        }.background(KPB.canvas(colorScheme))
    }
}

struct LanguageScreen: View {
    @EnvironmentObject var app: AppModel
    var body: some View {
        ScreenShell(title:"", back:false) {
            Text("Welcome").font(.largeTitle).fontWeight(.semibold).frame(maxWidth:.infinity)
            Text("Choose your language and region").frame(maxWidth:.infinity).multilineTextAlignment(.center)
            Picker("Language", selection:$app.language) { ForEach(supportedLanguages,id:\.self){Text($0).tag($0)} }
                .pickerStyle(.menu).frame(maxWidth:.infinity,minHeight:48).background(.background).clipShape(RoundedRectangle(cornerRadius:12))
            Picker("Region", selection:$app.region) {
                ForEach(["United States (US)","Canada (CA)","United Kingdom (GB)","Australia (AU)","Other"],id:\.self){Text($0).tag($0)}
            }.pickerStyle(.menu).frame(maxWidth:.infinity,minHeight:48).background(.background).clipShape(RoundedRectangle(cornerRadius:12))
            KPBPrimary(title:"Continue", action:app.localeNext)
            PrepBenchIllustration()
        }
    }
}

struct PrivacyScreen: View {
    @EnvironmentObject var app: AppModel
    var body: some View {
        ScreenShell(title:"Privacy & Ads",back:false) {
            Image(systemName:"shield.lefthalf.filled").font(.system(size:48)).foregroundStyle(KPB.sageDark).frame(maxWidth:.infinity)
            Text("We keep your data on this device and never sell it.").frame(maxWidth:.infinity).multilineTextAlignment(.center)
            KPBCard {
                Label("Local storage only",systemImage:"iphone")
                Label("No account required",systemImage:"person.crop.circle.badge.xmark")
                Label("Ads help keep the app free",systemImage:"megaphone")
            }
            KPBCard {
                Toggle(isOn:$app.adsEnabled){Label("Show ads",systemImage:"rectangle.bottomthird.inset.filled")}
                Divider()
                HStack { Label("Remove ads",systemImage:"nosign"); Spacer(); Text("One-time purchase").font(.caption).foregroundStyle(.secondary) }
            }
            KPBPrimary(title:"Continue",action:app.privacyNext)
        }
    }
}

struct HomeScreen: View {
    @EnvironmentObject var app: AppModel
    var body: some View {
        ScreenShell(title:"Kitchen Prep Board",back:false) {
            Text("Good morning, Chef.").font(.title2).fontWeight(.semibold)
            Text("Let’s get everything ready.").foregroundStyle(.secondary)
            KPBCard {
                if let b=app.board, [.active,.paused,.ready].contains(b.status) {
                    Text("Continue").font(.caption).foregroundStyle(.secondary)
                    Text(b.title).fontWeight(.semibold); Text("\(b.tasks.count) items").font(.caption)
                    KPBPrimary(title:"Resume Board",systemImage:"play.fill") { b.status == .ready ? app.startBoard() : app.resume() }
                } else {
                    Text("Start a prep board").fontWeight(.semibold)
                    Text("Keep what is now, next and waiting visible.")
                    KPBPrimary(title:"Create Board",systemImage:"plus",action:app.beginCreate)
                }
            }
            laneMetrics
            Text("Shortcuts").fontWeight(.semibold)
            HStack { KPBSecondary(title:"Quick Review",systemImage:"checklist"){app.beginCreate()}; KPBSecondary(title:"New Board",systemImage:"plus.square"){app.beginCreate()} }
            bottomNav
        }
    }
    var laneMetrics: some View {
        let tasks=app.board?.tasks ?? []
        let v=[("Now",tasks.filter{$0.status == .active}.count),("Next",tasks.filter{[.available,.blocked].contains($0.status)}.count),("Waiting",tasks.filter{$0.status == .waiting}.count),("Done",tasks.filter{[.done,.skipped].contains($0.status)}.count)]
        return HStack(spacing:8){ForEach(Array(v.enumerated()),id:\.offset){_,item in VStack{Text("\(item.1)").fontWeight(.bold);Text(item.0).font(.caption2)}.frame(maxWidth:.infinity).padding(10).background(.background).clipShape(RoundedRectangle(cornerRadius:12))}}
    }
    var bottomNav: some View { HStack { Spacer(); Button("Home"){app.home()}; Spacer(); Button("Boards"){app.home()}; Spacer(); Button("Templates"){app.home()}; Spacer(); Button("Settings"){app.openSettings()}; Spacer() }.frame(height:52).background(.background).clipShape(RoundedRectangle(cornerRadius:14)) }
}

struct CreateScreen: View {
    @EnvironmentObject var app:AppModel
    var body: some View { ScreenShell(title:"Create Board") {
        TextField("Board Name",text:$app.draftName).textFieldStyle(.roundedBorder)
        TextField("Notes (optional)",text:$app.draftNote,axis:.vertical).lineLimit(3...5).textFieldStyle(.roundedBorder)
        TextField("Prep items — one per line",text:$app.draftText,axis:.vertical).lineLimit(6...12).textFieldStyle(.roundedBorder)
        KPBCard { Text("Add from").fontWeight(.semibold); Text("Manual entry, pasted text, Share Sheet text, an existing board or a template. Source text stays local.").font(.callout) }
        KPBPrimary(title:"Create Board",enabled:!app.draftName.isEmpty || !app.draftText.isEmpty,action:app.captureBoard)
    }}
}

struct ReviewScreen: View {
    @EnvironmentObject var app:AppModel; @State private var newTask=""
    var body: some View { ScreenShell(title:"Quick Review") {
        Text("Review parsed items before you continue.")
        if app.board?.tasks.isEmpty != false { KPBNotice(text:"No prep items yet. Add at least one task.",error:true) }
        ForEach(app.board?.tasks ?? []) { t in KPBCard { HStack { Image(systemName:"exclamationmark.triangle").foregroundStyle(KPB.amber); VStack(alignment:.leading){Text(t.text).fontWeight(.medium);Text("\(t.durationMin) min suggested").font(.caption)}} } }
        HStack { TextField("Add item",text:$newTask).textFieldStyle(.roundedBorder); Button(action:{ app.addTask(newTask); newTask = "" }) { Image(systemName:"plus.circle.fill").font(.title2) }}
        KPBCard { Text("Parsed Summary").fontWeight(.semibold);Text("Items: \(app.board?.tasks.count ?? 0)") }
        KPBPrimary(title:"Looks Good",enabled:app.board?.tasks.isEmpty == false){app.screen = .mode}
    }}
}

struct ModeScreen: View {
    @EnvironmentObject var app:AppModel
    var body: some View { ScreenShell(title:"Select Mode") {
        Text("Choose how you want to work.")
        KPBChoice(title:"Home Mode",subtitle:"Guide for a household cook and family.",systemImage:"house.fill",selected:app.selectedMode == .home){app.selectedMode = .home}
        KPBChoice(title:"Station Mode",subtitle:"Step-by-step per station or task area.",systemImage:"cabinet.fill",selected:app.selectedMode == .station){app.selectedMode = .station}
        KPBNotice(text:"You can change modes anytime in Settings.")
        KPBPrimary(title:"Continue",action:app.modeNext)
    }}
}

struct SetupScreen: View {
    @EnvironmentObject var app:AppModel
    var body: some View { ScreenShell(title:app.selectedMode == .home ? "Home Mode Setup" : "Station Mode Setup") {
        Text("Tell us about your plan.")
        Stepper("Servings: \(app.servings)",value:$app.servings,in:1...1000)
        TextField(app.selectedMode == .home ? "Service Type" : "Station",text:$app.serviceType).textFieldStyle(.roundedBorder)
        KPBCard { Text("Date").font(.caption);Text("Today");Divider();Text("Target finish").font(.caption);Text("Set on the next step") }
        KPBPrimary(title:"Continue",action:app.setupNext)
    }}
}

struct PrepGapScreen: View {
    @EnvironmentObject var app:AppModel; @State private var ingredient=""; @State private var tool=""
    var body: some View { ScreenShell(title:"Prep Gap") {
        KPBNotice(text:"Items to get ready before you cook.")
        Text("Missing Ingredients").fontWeight(.semibold)
        ForEach((app.board?.gaps ?? []).filter{$0.type == .ingredient}){g in KPBCard{Label(g.name,systemImage:"shippingbox.fill")}}
        HStack{TextField("Ingredient",text:$ingredient).textFieldStyle(.roundedBorder);Button(action:{ app.addGap(ingredient,type:.ingredient); ingredient = "" }) { Image(systemName:"plus.circle.fill") }}
        Text("Missing Tools").fontWeight(.semibold)
        ForEach((app.board?.gaps ?? []).filter{$0.type == .tool}){g in KPBCard{Label(g.name,systemImage:"fork.knife")}}
        HStack{TextField("Kitchen tool",text:$tool).textFieldStyle(.roundedBorder);Button(action:{ app.addGap(tool,type:.tool); tool = "" }) { Image(systemName:"plus.circle.fill") }}
        KPBPrimary(title:"All Set, Continue"){app.screen = .timing}
    }}
}

struct TimingScreen: View {
    @EnvironmentObject var app:AppModel
    var body: some View { ScreenShell(title:"Timing Objective") {
        Text("When do you want everything ready?")
        KPBChoice(title:"Cook Now",subtitle:"Start as soon as I’m ready.",systemImage:"flame.fill",selected:app.timing == .cookNow){app.timing = .cookNow}
        KPBChoice(title:"Serve At",subtitle:"Plan to serve at a set time.",systemImage:"fork.knife.circle.fill",selected:app.timing == .serveAt){app.timing = .serveAt}
        KPBChoice(title:"Ready By",subtitle:"Everything ready by a deadline.",systemImage:"calendar.badge.checkmark",selected:app.timing == .readyBy){app.timing = .readyBy}
        KPBNotice(text:"You can adjust times later while working.")
        KPBPrimary(title:"Continue",action:app.timingNext)
    }}
}

struct ReadyScreen: View {
    @EnvironmentObject var app:AppModel
    var body: some View { ScreenShell(title:"Ready Overview") {
        KPBCard { HStack { VStack(alignment:.leading){Text("Everything will finish together.").fontWeight(.semibold);Text("Suggested schedule — not a guarantee.").font(.caption)};Spacer();Image(systemName:"checkmark.circle.fill").foregroundStyle(KPB.green).font(.title2)} }
        Text("Estimated Finish Time").fontWeight(.semibold)
        ForEach(Array((app.board?.tasks ?? []).enumerated()),id:\.element.id){n,t in HStack{Image(systemName:"fork.knife");Text(t.text);Spacer();Text("+\((n+1)*t.durationMin)m").font(.caption)}.padding(.vertical,4)}
        KPBPrimary(title:"Start Board",systemImage:"play.fill",action:app.startBoard)
    }}
}

struct RunBoardScreen: View {
    @EnvironmentObject var app:AppModel
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        GeometryReader { geo in
            VStack(spacing:0) {
                HStack { Text(app.board?.title ?? "Prep Board").font(.headline); Spacer(); Button(action:app.pause){Image(systemName:"pause.fill")} }.padding(.horizontal,16).frame(height:56)
                if geo.size.width >= 900 { expanded } else { compact }
            }.background(KPB.canvas(colorScheme))
        }
    }
    var grouped:[(String,[PrepTask])] {
        let t=app.board?.tasks ?? []
        return [("NOW",t.filter{$0.status == .active}),("NEXT",t.filter{[.available,.blocked].contains($0.status)}),("WAITING",t.filter{$0.status == .waiting}),("DONE",t.filter{[.done,.skipped].contains($0.status)})]
    }
    var expanded: some View {
        HStack(alignment:.top,spacing:10){ForEach(grouped,id:\.0){lane in VStack(alignment:.leading){Text("\(lane.0)  \(lane.1.count)").font(.caption).fontWeight(.bold);ScrollView{LazyVStack(spacing:8){ForEach(lane.1){TaskCard(task:$0)}}}}.frame(maxWidth:.infinity)}}.padding(12)
    }
    var compact: some View {
        ScrollView { VStack(spacing:12){ForEach(grouped,id:\.0){lane in VStack(alignment:.leading,spacing:8){Text("\(lane.0)  \(lane.1.count)").font(.caption).fontWeight(.bold);ForEach(lane.1){TaskCard(task:$0)}}};KPBSecondary(title:"Pause Board",systemImage:"pause.fill",action:app.pause);KPBSecondary(title:"Finish Board",systemImage:"flag.fill"){app.screen = .finish}}.padding(16) }
    }
}

struct TaskCard: View {
    @EnvironmentObject var app:AppModel; let task:PrepTask
    var body: some View {
        KPBCard {
            Text(task.text).fontWeight(.semibold);Text("\(task.durationMin) min").font(.caption).foregroundStyle(.secondary)
            switch task.status {
            case .available,.blocked: KPBPrimary(title:"Start",systemImage:"play.fill"){app.startTask(task.id)}
            case .active,.waiting:
                HStack{Button("+1 min"){app.addMinutes(task.id,1)};Button("+5 min"){app.addMinutes(task.id,5)}}
                KPBPrimary(title:"Done",systemImage:"checkmark"){app.doneTask(task.id)}
                Button("Skip"){app.skipTask(task.id)}
            default: Label(task.status.rawValue.capitalized,systemImage:"checkmark").foregroundStyle(KPB.green)
            }
        }
    }
}

struct PausedScreen: View {
    @EnvironmentObject var app:AppModel
    var body: some View { ScreenShell(title:app.board?.title ?? "Paused Board",back:false) {
        KPBNotice(text:"Paused. Timers are not frozen; resume when ready.")
        KPBPrimary(title:"Resume Board",systemImage:"play.fill",action:app.resume)
        KPBSecondary(title:"Finish Board",systemImage:"flag.fill"){app.screen = .finish}
        KPBSecondary(title:"Go Home",systemImage:"house.fill",action:app.home)
    }}
}

struct FinishScreen: View {
    @EnvironmentObject var app:AppModel
    var unfinished:Int{app.board?.tasks.filter{![.done,.skipped].contains($0.status)}.count ?? 0}
    var body: some View { ScreenShell(title:"Finish Board") {
        Image(systemName:unfinished == 0 ? "checkmark.circle.fill":"exclamationmark.triangle.fill").font(.system(size:64)).foregroundStyle(unfinished == 0 ? KPB.green : KPB.amber).frame(maxWidth:.infinity)
        Text(unfinished == 0 ? "You’re all set!" : "\(unfinished) item(s) are unfinished.").font(.title2).fontWeight(.semibold).frame(maxWidth:.infinity)
        if unfinished > 0 { KPBSecondary(title:"Continue Board",action:app.back) }
        KPBPrimary(title:unfinished > 0 ? "Finish Anyway":"Finish Board",action:app.finishAnyway)
    }}
}

struct ReuseScreen: View {
    @EnvironmentObject var app:AppModel
    var body: some View { ScreenShell(title:"Board Complete",back:false) {
        Image(systemName:"checklist.checked").font(.system(size:56)).foregroundStyle(KPB.sageDark).frame(maxWidth:.infinity)
        Text("What would you like to do?").font(.headline).frame(maxWidth:.infinity)
        KPBCard{Text("Save as Template").fontWeight(.semibold);Text("Reuse this board next time.").font(.caption)}
        KPBCard{Text("Add Note").fontWeight(.semibold);Text("Save notes for next time.").font(.caption)}
        KPBPrimary(title:"Go to Home",systemImage:"house.fill",action:app.home)
    }}
}

struct SettingsScreen: View {
    @EnvironmentObject var app:AppModel
    var body: some View { ScreenShell(title:"Settings") {
        Text("Preferences").font(.caption).foregroundStyle(.secondary)
        KPBCard {
            SettingsRow(icon:"globe",title:"Language",value:app.language)
            Divider();SettingsRow(icon:"location",title:"Locale",value:app.region)
            Divider();SettingsRow(icon:"ruler",title:"Units",value:"System")
            Divider();SettingsRow(icon:"thermometer.medium",title:"Temperature",value:"°F")
        }
        Text("Appearance").font(.caption).foregroundStyle(.secondary)
        KPBCard {
            Picker("Theme",selection:Binding(get:{app.theme},set:app.setTheme)){ForEach(ThemeMode.allCases,id:\.self){Text($0.rawValue.capitalized).tag($0)}}.pickerStyle(.segmented)
        }
        KPBSecondary(title:"Data, Privacy & Support"){app.openSettings(detail:true)}
    }}
}
struct SettingsRow: View {
    let icon:String,title:String,value:String
    var body: some View { HStack{Image(systemName:icon).frame(width:24).foregroundStyle(KPB.sageDark);Text(title);Spacer();Text(value).font(.caption).foregroundStyle(.secondary);Image(systemName:"chevron.right").font(.caption).foregroundStyle(.secondary)}.frame(minHeight:50) }
}
struct SettingsDetailScreen: View {
    var body: some View { ScreenShell(title:"Settings") {
        Text("Data & Privacy").font(.caption).foregroundStyle(.secondary)
        KPBCard { SettingsRow(icon:"hand.raised",title:"Privacy Choices",value:"");Divider();SettingsRow(icon:"square.and.arrow.up",title:"Export Local Data",value:"");Divider();SettingsRow(icon:"square.and.arrow.down",title:"Import Local Data",value:"");Divider();SettingsRow(icon:"trash",title:"Delete Local Data",value:"") }
        Text("Help & Support").font(.caption).foregroundStyle(.secondary)
        KPBCard { SettingsRow(icon:"questionmark.circle",title:"Help Center",value:"");Divider();SettingsRow(icon:"lock.shield",title:"Privacy Policy",value:"");Divider();SettingsRow(icon:"doc.text",title:"Terms of Service",value:"");Divider();SettingsRow(icon:"person.wave.2",title:"Support",value:"") }
        KPBPrimary(title:"Remove Ads",systemImage:"nosign"){}
        Text("Organizational aid only. It does not prove food safety or doneness.").font(.caption).foregroundStyle(.secondary)
    }}
}
