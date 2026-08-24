import SwiftUI

public struct GUPalette: Sendable {
    let canvas: Color, surface: Color, raised: Color, primary: Color, onPrimary: Color
    let text: Color, secondary: Color, border: Color, success: Color, warning: Color, error: Color
}
public enum GUPalettes {
    static let light = GUPalette(
        canvas: Color(hex:"#F5F7F8"), surface:.white, raised:Color(hex:"#EDF3F5"),
        primary:Color(hex:"#215B7A"), onPrimary:.white, text:Color(hex:"#13232D"),
        secondary:Color(hex:"#51636D"), border:Color(hex:"#CDD9DE"), success:Color(hex:"#2E7259"),
        warning:Color(hex:"#9A6508"), error:Color(hex:"#A74343")
    )
    static let dark = GUPalette(
        canvas:Color(hex:"#0E1519"), surface:Color(hex:"#162128"), raised:Color(hex:"#1D2B33"),
        primary:Color(hex:"#8FC8E8"), onPrimary:Color(hex:"#08202D"), text:Color(hex:"#EDF4F7"),
        secondary:Color(hex:"#B8C7CE"), border:Color(hex:"#40515B"), success:Color(hex:"#72C19A"),
        warning:Color(hex:"#E4B65E"), error:Color(hex:"#E08C8C")
    )
}

public struct GURuntime: Sendable {
    let palette:GUPalette
    let width:CGFloat
    let gutter:CGFloat
    let wideBoard:Bool
}
private struct GURuntimeKey: EnvironmentKey { static let defaultValue:GURuntime? = nil }
extension EnvironmentValues {
    var guRuntime:GURuntime? { get { self[GURuntimeKey.self] } set { self[GURuntimeKey.self]=newValue } }
}

public struct GoodUseFrame<Content:View>:View {
    @Environment(\.colorScheme) private var scheme
    let content:(GURuntime)->Content
    public init(@ViewBuilder content:@escaping(GURuntime)->Content){self.content=content}
    public var body: some View {
        GeometryReader { proxy in
            let p = scheme == .dark ? GUPalettes.dark : GUPalettes.light
            let width = proxy.size.width
            let gutter:CGFloat = width < 360 ? 12 : width < 600 ? 16 : width < 900 ? 24 : width < 1200 ? 32 : 40
            let rt=GURuntime(palette:p,width:width,gutter:gutter,wideBoard:width>=900)
            ZStack(alignment:.top) {
                p.canvas.ignoresSafeArea()
                content(rt)
                    .padding(.horizontal,gutter)
                    .frame(maxWidth: width >= 1200 ? 1360 : .infinity, alignment:.topLeading)
                    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.top)
            }
            .environment(\.guRuntime,rt)
        }
    }
}

public struct GUSection<Content:View>:View {
    @Environment(\.guRuntime) private var rt
    let title:String?
    let emphasis:Bool
    let content:Content
    public init(_ title:String?=nil,emphasis:Bool=false,@ViewBuilder content:()->Content){
        self.title=title; self.emphasis=emphasis; self.content=content()
    }
    public var body:some View {
        let p=rt?.palette ?? GUPalettes.light
        VStack(alignment:.leading,spacing:12){
            if let title { Text(title).font(.system(size:21,weight:.semibold)) }
            content
        }
        .padding(16)
        .frame(maxWidth:.infinity,alignment:.leading)
        .background(emphasis ? p.raised : p.surface)
        .clipShape(RoundedRectangle(cornerRadius:16,style:.continuous))
        .overlay(RoundedRectangle(cornerRadius:16,style:.continuous).stroke(p.border.opacity(0.65),lineWidth:1))
    }
}

public struct GUPrimary:View {
    @Environment(\.guRuntime) private var rt
    let text:String; let icon:String?; let action:()->Void
    public init(_ text:String,icon:String?=nil,action:@escaping()->Void){self.text=text;self.icon=icon;self.action=action}
    public var body:some View {
        let p=rt?.palette ?? GUPalettes.light
        Button(action:action){
            HStack(spacing:8){
                if let icon { GoodUseVectorIcon(key:icon).frame(width:20,height:20) }
                Text(text).font(.system(size:14,weight:.medium))
            }
            .frame(maxWidth:.infinity,minHeight:44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(p.onPrimary)
        .background(p.primary)
        .clipShape(RoundedRectangle(cornerRadius:12,style:.continuous))
    }
}

public struct GUSecondary:View {
    @Environment(\.guRuntime) private var rt
    let text:String; let icon:String?; let action:()->Void
    public init(_ text:String,icon:String?=nil,action:@escaping()->Void){self.text=text;self.icon=icon;self.action=action}
    public var body:some View {
        let p=rt?.palette ?? GUPalettes.light
        Button(action:action){
            HStack(spacing:8){
                if let icon { GoodUseVectorIcon(key:icon).frame(width:20,height:20) }
                Text(text).font(.system(size:14,weight:.medium))
            }
            .frame(maxWidth:.infinity,minHeight:44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(p.text)
        .overlay(RoundedRectangle(cornerRadius:12,style:.continuous).stroke(p.border,lineWidth:1))
    }
}

public struct GUStatus:View {
    @Environment(\.guRuntime) private var rt
    let text:String; let tone:String
    public init(_ text:String,tone:String="neutral"){self.text=text;self.tone=tone}
    public var body:some View{
        let p=rt?.palette ?? GUPalettes.light
        let c = tone=="warning" ? p.warning : tone=="error" ? p.error : tone=="success" ? p.success : p.secondary
        Text(text).font(.system(size:14,weight:.medium)).foregroundStyle(c)
            .padding(.horizontal,10).padding(.vertical,6).background(c.opacity(0.13)).clipShape(Capsule())
    }
}

/** GOODUSE_ICON_REGISTRY 1.1.0 canonical 24x24 subset. */
public struct GoodUseVectorIcon:View {
    let key:String
    public init(key:String){self.key=key}
    public var body:some View {
        Canvas { context,size in
            let s=min(size.width,size.height)/24
            let color=GraphicsContext.Shading.color(Color.primary)
            func pt(_ x:CGFloat,_ y:CGFloat)->CGPoint { CGPoint(x:x*s,y:y*s) }
            func stroke(_ points:[CGPoint]) {
                var p=Path(); guard let first=points.first else{return}; p.move(to:first); for q in points.dropFirst(){p.addLine(to:q)}
                context.stroke(p,with:color,lineWidth:1.8*s)
            }
            switch key {
            case "play","resume":
                var p=Path(); p.move(to:pt(8,5)); p.addLine(to:pt(19,12)); p.addLine(to:pt(8,19)); p.closeSubpath(); context.fill(p,with:color)
            case "pause":
                var a=Path(); a.addRect(CGRect(x:7*s,y:5*s,width:3.5*s,height:14*s)); context.fill(a,with:color)
                var b=Path(); b.addRect(CGRect(x:13.5*s,y:5*s,width:3.5*s,height:14*s)); context.fill(b,with:color)
            case "stop":
                var p=Path(); p.addRect(CGRect(x:6*s,y:6*s,width:12*s,height:12*s)); context.fill(p,with:color)
            case "complete","check","save":
                stroke([pt(4,12),pt(9.5,17.5),pt(20,6)])
            case "plus":
                stroke([pt(12,4),pt(12,20)]); stroke([pt(4,12),pt(20,12)])
            case "settings":
                stroke([pt(3,6),pt(21,6)]); stroke([pt(3,12),pt(21,12)]); stroke([pt(3,18),pt(21,18)])
                context.stroke(Path(ellipseIn:CGRect(x:6*s,y:4*s,width:4*s,height:4*s)),with:color,lineWidth:1.8*s)
                context.stroke(Path(ellipseIn:CGRect(x:14*s,y:10*s,width:4*s,height:4*s)),with:color,lineWidth:1.8*s)
                context.stroke(Path(ellipseIn:CGRect(x:9*s,y:16*s,width:4*s,height:4*s)),with:color,lineWidth:1.8*s)
            default:
                context.stroke(Path(ellipseIn:CGRect(x:3*s,y:3*s,width:18*s,height:18*s)),with:color,lineWidth:1.8*s)
            }
        }
    }
}

extension Color {
    init(hex:String) {
        let v=hex.trimmingCharacters(in:CharacterSet(charactersIn:"#"))
        var raw:UInt64=0; Scanner(string:v).scanHexInt64(&raw)
        let r=Double((raw & 0xFF0000)>>16)/255, g=Double((raw & 0x00FF00)>>8)/255, b=Double(raw & 0x0000FF)/255
        self.init(.sRGB,red:r,green:g,blue:b,opacity:1)
    }
}
