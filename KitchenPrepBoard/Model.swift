import Foundation
import SwiftUI

enum AppScreen: String, Codable {
    case language, privacy, home, create, review, mode, setup, prepGap, timing, ready, run, paused, finish, reuse, settings, settingsDetail
}
enum BoardMode: String, Codable, CaseIterable { case home, station }
enum BoardStatus: String, Codable { case draft, ready, active, paused, completed, archivedIncomplete }
enum TaskStatus: String, Codable { case blocked, available, active, waiting, done, skipped }
enum TimingMode: String, Codable, CaseIterable { case cookNow, serveAt, readyBy }
enum ThemeMode: String, Codable, CaseIterable { case system, light, dark }
enum GapType: String, Codable { case ingredient, tool }

struct PrepTask: Identifiable, Codable, Hashable {
    var id = UUID()
    var text: String
    var status: TaskStatus = .available
    var durationMin: Int = 5
    var deadline: Date?
}
struct Gap: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var type: GapType
}
struct PrepBoard: Identifiable, Codable {
    var id = UUID()
    var title: String
    var note = ""
    var mode: BoardMode?
    var status: BoardStatus = .draft
    var timing: TimingMode?
    var tasks: [PrepTask] = []
    var gaps: [Gap] = []
}

@MainActor
final class AppModel: ObservableObject {
    @Published var screen: AppScreen
    @Published var language: String
    @Published var region: String
    @Published var theme: ThemeMode
    @Published var adsEnabled = true
    @Published var board: PrepBoard?
    @Published var draftName = ""
    @Published var draftNote = ""
    @Published var draftText = ""
    @Published var selectedMode: BoardMode = .home
    @Published var timing: TimingMode = .cookNow
    @Published var servings = 4
    @Published var serviceType = "Dinner"
    private var settingsReturn: AppScreen = .home

    init() {
        let d = UserDefaults.standard
        language = d.string(forKey: "language") ?? "English"
        region = d.string(forKey: "region") ?? "United States (US)"
        theme = ThemeMode(rawValue: d.string(forKey: "theme") ?? "system") ?? .system
        screen = d.bool(forKey: "onboarded") ? .home : .language
        loadBoard()
    }

    var preferredColorScheme: ColorScheme? {
        switch theme { case .system: nil; case .light: .light; case .dark: .dark }
    }

    func localeNext() { screen = .privacy }
    func privacyNext() {
        let d = UserDefaults.standard
        d.set(language, forKey: "language"); d.set(region, forKey: "region"); d.set(true, forKey: "onboarded")
        screen = .home
    }
    func beginCreate(prefill: String = "") { draftText = prefill; screen = .create }
    func captureBoard() {
        let tasks = draftText.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }.map { PrepTask(text: $0) }
        board = PrepBoard(title: draftName.trimmingCharacters(in: .whitespaces).isEmpty ? "Prep Board" : draftName, note: draftNote, tasks: tasks)
        persistBoard(); screen = .review
    }
    func addTask(_ value: String) {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines); guard !v.isEmpty else { return }
        board?.tasks.append(PrepTask(text: v)); persistBoard()
    }
    func modeNext() { board?.mode = selectedMode; persistBoard(); screen = .setup }
    func setupNext() { screen = selectedMode == .station ? .prepGap : .timing }
    func addGap(_ value: String, type: GapType) {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines); guard !v.isEmpty else { return }
        board?.gaps.append(Gap(name: v, type: type)); persistBoard()
    }
    func timingNext() { board?.timing = timing; board?.status = .ready; persistBoard(); screen = .ready }
    func startBoard() { board?.status = .active; persistBoard(); screen = .run }
    func mutateTask(_ id: UUID, _ change: (inout PrepTask) -> Void) {
        guard let index = board?.tasks.firstIndex(where: {$0.id == id}) else { return }
        change(&board!.tasks[index]); persistBoard()
    }
    func startTask(_ id: UUID) { mutateTask(id) { $0.status = .active; $0.deadline = Date().addingTimeInterval(TimeInterval($0.durationMin * 60)) } }
    func doneTask(_ id: UUID) { mutateTask(id) { $0.status = .done; $0.deadline = nil } }
    func skipTask(_ id: UUID) { mutateTask(id) { $0.status = .skipped; $0.deadline = nil } }
    func addMinutes(_ id: UUID, _ min: Int) { mutateTask(id) { $0.deadline = ($0.deadline ?? Date()).addingTimeInterval(TimeInterval(min*60)) } }
    func pause() { board?.status = .paused; persistBoard(); screen = .paused }
    func resume() { board?.status = .active; persistBoard(); screen = .run }
    func finishAnyway() {
        let incomplete = board?.tasks.contains(where: { ![TaskStatus.done,.skipped].contains($0.status) }) ?? false
        board?.status = incomplete ? .archivedIncomplete : .completed; persistBoard(); screen = .reuse
    }
    func home() { screen = .home }
    func openSettings(detail: Bool = false) { settingsReturn = screen; screen = detail ? .settingsDetail : .settings }
    func closeSettings() { screen = settingsReturn }
    func setTheme(_ value: ThemeMode) { theme = value; UserDefaults.standard.set(value.rawValue, forKey: "theme") }

    func back() {
        switch screen {
        case .privacy: screen = .language
        case .create: screen = .home
        case .review: screen = .create
        case .mode: screen = .review
        case .setup: screen = .mode
        case .prepGap: screen = .setup
        case .timing: screen = selectedMode == .station ? .prepGap : .setup
        case .ready: screen = .timing
        case .settingsDetail: screen = .settings
        case .settings: screen = settingsReturn
        case .finish: screen = board?.status == .paused ? .paused : .run
        default: screen = .home
        }
    }

    private var boardURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appendingPathComponent("kitchen-prep-board.json")
    }
    private func persistBoard() {
        guard let board, let data = try? JSONEncoder().encode(board) else { return }
        try? data.write(to: boardURL, options: .atomic)
    }
    private func loadBoard() {
        guard let data = try? Data(contentsOf: boardURL), let value = try? JSONDecoder().decode(PrepBoard.self, from: data) else { return }
        board = value
    }
}
