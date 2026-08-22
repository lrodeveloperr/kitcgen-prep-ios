import SwiftUI

enum KPB {
    static let cream = Color(red: 250/255, green: 245/255, blue: 239/255)
    static let darkCanvas = Color(red: 17/255, green: 21/255, blue: 17/255)
    static func canvas(_ scheme: ColorScheme) -> Color { scheme == .dark ? darkCanvas : cream }
    static let surface = Color(red: 1.0, green: 253/255, blue: 252/255)
    static let sage = Color(red: 79/255, green: 111/255, blue: 88/255)
    static let sageDark = Color(red: 54/255, green: 81/255, blue: 62/255)
    static let sageSoft = Color(red: 228/255, green: 235/255, blue: 227/255)
    static let ink = Color(red: 36/255, green: 52/255, blue: 40/255)
    static let muted = Color(red: 111/255, green: 117/255, blue: 110/255)
    static let line = Color(red: 221/255, green: 212/255, blue: 201/255)
    static let amber = Color(red: 183/255, green: 106/255, blue: 36/255)
    static let amberSoft = Color(red: 1, green: 240/255, blue: 222/255)
    static let red = Color(red: 186/255, green: 77/255, blue: 66/255)
    static let green = Color(red: 61/255, green: 116/255, blue: 82/255)
}

struct KPBCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(KPB.line.opacity(0.8), lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 9, y: 4)
    }
}

struct KPBPrimary: View {
    var title: String; var systemImage: String? = nil; var enabled = true; var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).fontWeight(.semibold)
            }.frame(maxWidth: .infinity, minHeight: 50)
        }.buttonStyle(.plain).foregroundStyle(.white).background(enabled ? KPB.sage : KPB.sage.opacity(0.4))
         .clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(enabled ? 0.12 : 0), radius: 5, y: 3)
         .disabled(!enabled)
    }
}

struct KPBSecondary: View {
    var title: String; var systemImage: String? = nil; var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }.frame(maxWidth: .infinity, minHeight: 48)
        }.buttonStyle(.plain).foregroundStyle(KPB.sageDark)
         .background(.background).clipShape(RoundedRectangle(cornerRadius: 12))
         .overlay(RoundedRectangle(cornerRadius: 12).stroke(KPB.line))
    }
}

struct KPBChoice: View {
    let title: String, subtitle: String, systemImage: String, selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage).font(.title3).frame(width: 46,height:46).background(KPB.sageSoft).clipShape(RoundedRectangle(cornerRadius: 12)).foregroundStyle(KPB.sageDark)
                VStack(alignment: .leading, spacing: 3) { Text(title).fontWeight(.semibold); Text(subtitle).font(.caption).foregroundStyle(.secondary) }
                Spacer()
                if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(KPB.sage) }
            }.padding(16).frame(maxWidth: .infinity)
        }.buttonStyle(.plain).background(selected ? KPB.sageSoft.opacity(0.55) : Color(.systemBackground))
         .clipShape(RoundedRectangle(cornerRadius: 16))
         .overlay(RoundedRectangle(cornerRadius: 16).stroke(selected ? KPB.sage : KPB.line, lineWidth: selected ? 2 : 1))
         .shadow(color: .black.opacity(selected ? 0.06 : 0.03), radius: 7, y: 3)
    }
}

struct KPBNotice: View {
    var text: String; var error = false
    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: error ? "exclamationmark.circle" : "info.circle")
            Text(text).font(.caption)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
         .background(error ? KPB.red.opacity(0.08) : KPB.amberSoft)
         .foregroundStyle(error ? KPB.red : KPB.ink)
         .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PrepBenchIllustration: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.96, green: 0.91, blue: 0.84))
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.73, green: 0.54, blue: 0.34))
                    .frame(width: w * 0.56, height: 78)
                    .offset(y: 34)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.96))
                    .frame(width: w * 0.18, height: 98)
                    .offset(x: -w * 0.32, y: -18)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.96))
                    .frame(width: w * 0.16, height: 72)
                    .offset(x: w * 0.34, y: -4)
                HStack(spacing: 7) {
                    ForEach(0..<4, id: \.self) { i in
                        Capsule().fill(i.isMultiple(of: 2) ? KPB.sage : Color(red: 0.82, green: 0.62, blue: 0.36))
                            .frame(width: 18, height: CGFloat(46 + i * 5))
                    }
                }.offset(y: -33)
                RoundedRectangle(cornerRadius: 3).fill(KPB.ink.opacity(0.78))
                    .frame(width: w * 0.34, height: 7).rotationEffect(.degrees(-7)).offset(y: 44)
                Circle().stroke(KPB.sageDark, lineWidth: 4).frame(width: 38, height: 38).offset(x: w * 0.32, y: 42)
                Image(systemName: "checkmark").font(.headline).foregroundStyle(KPB.sageDark).offset(x: w * 0.32, y: 42)
            }
        }
        .frame(height: 220)
        .accessibilityLabel("Kitchen prep station illustration")
    }
}
