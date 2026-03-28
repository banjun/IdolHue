//
//  AppDelegate.swift
//  IdolHue
//
//  Created by BAN Jun on R 2/10/01.
//

import Cocoa
import SwiftUI
import SwiftSparql

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    let idolsModel = ContentView.Model()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = HostingView(model: idolsModel)
        window.title = "Dye the sky in my hue"
        window.makeKeyAndOrderFront(nil)
        
        idolsModel.idols = [
            .init(name: "及川雫", color: "FFFFFF"),
            .init(name: "黒川千秋", color: "bc1212"),
            .init(name: "辻野あかり", color: "e10600"),
            .init(name: "日野茜", color: "f9423a"),
            .init(name: "大沼くるみ", color: "ffc1bd"),
            .init(name: "難波笑美", color: "e03c31"),
            .init(name: "楊菲菲", color: "e56f66"),
            .init(name: "関裕美", color: "ffb3ab"),
            .init(name: "持田亜里沙", color: "fd9286"),
            .init(name: "高橋礼子", color: "781000"),
            .init(name: "相原雪乃", color: "d06447"),
            .init(name: "ナターリア", color: "f4633a"),
            .init(name: "西島櫂", color: "f16029"),
            .init(name: "安斎都", color: "fa9063"),
            .init(name: "片桐早苗", color: "fc4c02"),
            .init(name: "藤本里奈", color: "623b2a"),
            .init(name: "槙原志保", color: "f97f4b"),
            .init(name: "野々村そら", color: "fc6e2e"),
            .init(name: "柳瀬美由紀", color: "ff5d14"),
            .init(name: "松山久美子", color: "ff7b2c"),
            .init(name: "矢口美羽", color: "ec5800"),
            .init(name: "依田芳乃", color: "c4bcb7"),
            .init(name: "大原みちる", color: "d8843e"),
            .init(name: "堀裕子", color: "eca154"),
            .init(name: "沢田麻理菜", color: "fca538"),
            .init(name: "城ヶ崎美嘉", color: "fe9d1a"),
            .init(name: "土屋亜子", color: "ffbe60"),
            .init(name: "姫川友紀", color: "ed8b00"),
            .init(name: "上田鈴帆", color: "cc8a00"),
            .init(name: "本田未央", color: "ffb81c"),
            .init(name: "相馬夏美", color: "fcc138"),
            .init(name: "愛野渚", color: "ffcb49"),
            .init(name: "クラリス", color: "ffda7b"),
            .init(name: "冴島清美", color: "f6bd30"),
            .init(name: "榊原里美", color: "fec520"),
            .init(name: "市原仁奈", color: "f8e08e"),
            .init(name: "大槻唯", color: "f6be00"),
            .init(name: "ヘレン", color: "BA910F"),
            .init(name: "喜多日菜子", color: "fcd757"),
            .init(name: "赤城みりあ", color: "ffcd00"),
            .init(name: "並木芽衣子", color: "feea9c"),
            .init(name: "諸星きらり", color: "ffd100"),
            .init(name: "首藤葵", color: "fbe983"),
            .init(name: "龍崎薫", color: "fae053"),
            .init(name: "キャシー・グラハム", color: "ffdc00"),
            .init(name: "城ヶ崎莉嘉", color: "fedd00"),
            .init(name: "相葉夕美", color: "f0e991"),
            .init(name: "喜多見柚", color: "f8f283"),
            .init(name: "小松伊吹", color: "fffb4e"),
            .init(name: "若林智香", color: "fdff4e"),
            .init(name: "日下部若葉", color: "c4d673"),
            .init(name: "海老原菜帆", color: "819832"),
            .init(name: "高森藍子", color: "cdea80"),
            .init(name: "古賀小春", color: "c2e189"),
            .init(name: "斉藤洋子", color: "cbfc9f"),
            .init(name: "荒木比奈", color: "a0d884"),
            .init(name: "緒方智絵里", color: "6cc24a"),
            .init(name: "氏家むつみ", color: "375637"),
            .init(name: "北川真尋", color: "4fd962"),
            .init(name: "三好紗南", color: "45f05b"),
            .init(name: "浅野風香", color: "618d75"),
            .init(name: "間中美里", color: "d1f9e6"),
            .init(name: "大和亜季", color: "28724f"),
            .init(name: "高垣楓", color: "47d7ac"),
            .init(name: "真鍋いつき", color: "58eabd"),
            .init(name: "梅木音葉", color: "75bbae"),
            .init(name: "ライラ", color: "7ce0d3"),
            .init(name: "久川颯", color: "7eddd3"),
            .init(name: "三船美優", color: "12bfb2"),
            .init(name: "北条加蓮", color: "2ad2c9"),
            .init(name: "結城晴", color: "71dad4"),
            .init(name: "瀬名詩織", color: "52c6c3"),
            .init(name: "森久保乃々", color: "9cdbd9"),
            .init(name: "水野翠", color: "43a0ab"),
            .init(name: "望月聖", color: "b7dde1"),
            .init(name: "浅利七海", color: "009cbd"),
            .init(name: "大石泉", color: "74d1ea"),
            .init(name: "岡崎泰葉", color: "ade5f6"),
            .init(name: "松尾千鶴", color: "99e3fc"),
            .init(name: "上条春菜", color: "5bc2e7"),
            .init(name: "渋谷凛", color: "009cde"),
            .init(name: "高峯のあ", color: "9fe1fd"),
            .init(name: "新田美波", color: "71c5e8"),
            .init(name: "水木聖來", color: "86dbff"),
            .init(name: "多田李衣菜", color: "0077c8"),
            .init(name: "塩見周子", color: "dce6ed"),
            .init(name: "佐々木千枝", color: "0072ce"),
            .init(name: "砂塚あきら", color: "7e93a7"),
            .init(name: "白坂小梅", color: "abcae9"),
            .init(name: "栗原ネネ", color: "0f7bf8"),
            .init(name: "脇山珠美", color: "407ec9"),
            .init(name: "アナスタシア", color: "b1c9e8"),
            .init(name: "木村夏樹", color: "53565a"),
            .init(name: "小室千奈美", color: "acc0e6"),
            .init(name: "橘ありす", color: "5c88da"),
            .init(name: "速水奏", color: "003087"),
            .init(name: "成宮由愛", color: "2b5cd5"),
            .init(name: "鷺沢文香", color: "606eb2"),
            .init(name: "松本沙理奈", color: "2943cb"),
            .init(name: "川島瑞樹", color: "485cc7"),
            .init(name: "和久井留美", color: "2e347e"),
            .init(name: "吉岡沙紀", color: "1b24c2"),
            .init(name: "佐城雪美", color: "171c8f"),
            .init(name: "西川保奈美", color: "5756d8"),
            .init(name: "藤原肇", color: "9595d2"),
            .init(name: "古澤頼子", color: "3f3c8b"),
            .init(name: "八神マキノ", color: "a6a4e0"),
            .init(name: "松永涼", color: "211551"),
            .init(name: "神谷奈緒", color: "9678d3"),
            .init(name: "服部瞳子", color: "633aa1"),
            .init(name: "木場真奈美", color: "8d8696"),
            .init(name: "浜口あやめ", color: "440099"),
            .init(name: "二宮飛鳥", color: "5f259f"),
            .init(name: "篠原礼", color: "bb68fe"),
            .init(name: "輿水幸子", color: "c1a0da"),
            .init(name: "伊集院惠", color: "521078"),
            .init(name: "藤居朋", color: "9b58c2"),
            .init(name: "鷹富士茄子", color: "5c068c"),
            .init(name: "相川千夏", color: "7a508f"),
            .init(name: "綾瀬穂乃香", color: "f5d6ff"),
            .init(name: "桐生つかさ", color: "ab4ec6"),
            .init(name: "神崎蘭子", color: "84329b"),
            .init(name: "イヴ・サンタクロース", color: "E5E1E6"),
            .init(name: "柳清良", color: "e7cbee"),
            .init(name: "小関麗奈", color: "9b26b6"),
            .init(name: "メアリー・コクラン", color: "f196ff"),
            .init(name: "白菊ほたる", color: "c964cf"),
            .init(name: "岸部彩華", color: "f14fee"),
            .init(name: "今井加奈", color: "ff3de5"),
            .init(name: "夢見りあむ", color: "e89cdc"),
            .init(name: "中野有香", color: "e277cd"),
            .init(name: "早坂美玲", color: "c800a1"),
            .init(name: "向井拓海", color: "b0008e"),
            .init(name: "小日向美穂", color: "db3eb1"),
            .init(name: "水本ゆかり", color: "eabedb"),
            .init(name: "櫻井桃華", color: "ef95cf"),
            .init(name: "浜川愛結奈", color: "a42678"),
            .init(name: "桃井あずき", color: "93256c"),
            .init(name: "的場梨沙", color: "ff00a0"),
            .init(name: "宮本フレデリカ", color: "a20067"),
            .init(name: "遊佐こずえ", color: "f4a6d7"),
            .init(name: "仙崎恵磨", color: "d30d85"),
            .init(name: "棟方愛海", color: "c7579a"),
            .init(name: "白雪千夜", color: "efd7e5"),
            .init(name: "小早川紗枝", color: "e56db1"),
            .init(name: "衛藤美紗希", color: "fe85c7"),
            .init(name: "大西由里子", color: "c90f74"),
            .init(name: "佐久間まゆ", color: "da1884"),
            .init(name: "松原早耶", color: "f743a6"),
            .init(name: "太田優", color: "f851a7"),
            .init(name: "福山舞", color: "ff68b5"),
            .init(name: "柊志乃", color: "ad1e66"),
            .init(name: "一ノ瀬志希", color: "a50050"),
            .init(name: "涼宮星花", color: "f994c4"),
            .init(name: "兵藤レナ", color: "d8076b"),
            .init(name: "横山千佳", color: "fc87bf"),
            .init(name: "佐藤心", color: "f04e98"),
            .init(name: "財前時子", color: "7d0837"),
            .init(name: "桐野アヤ", color: "c3396c"),
            .init(name: "赤西瑛梨華", color: "eb306d"),
            .init(name: "安部菜々", color: "ef4a81"),
            .init(name: "星輝子", color: "a6093d"),
            .init(name: "杉坂海", color: "d83c6a"),
            .init(name: "東郷あい", color: "9b274a"),
            .init(name: "久川凪", color: "f8a4bd"),
            .init(name: "双葉杏", color: "f8a3bc"),
            .init(name: "島村卯月", color: "f67599"),
            .init(name: "井村雪菜", color: "ed3767"),
            .init(name: "前川みく", color: "ce0037"),
            .init(name: "五十嵐響子", color: "fabbcb"),
            .init(name: "有浦柑奈", color: "ec4b6e"),
            .init(name: "十時愛梨", color: "df4661"),
            .init(name: "南条光", color: "e4002b"),
            .init(name: "丹羽仁美", color: "a80826"),
            .init(name: "池袋晶葉", color: "de2f4d"),
            .init(name: "奥山沙織", color: "e87487"),
            .init(name: "乙倉悠貴", color: "e4bec3"),
            .init(name: "椎名法子", color: "f8485e"),
            .init(name: "三村かな子", color: "ffb1bb"),
            .init(name: "村上巴", color: "ab192c"),
            .init(name: "村松さくら", color: "eb6174"),
            .init(name: "工藤忍", color: "eb3249"),
            .init(name: "ケイト", color: "cf142b"),
            .init(name: "西園寺琴歌", color: "e8cdd0"),
            .init(name: "江上椿", color: "e95b64"),
            .init(name: "黒埼ちとせ", color: "ef3340"),
            .init(name: "長富蓮実", color: "ea8a91"),
            .init(name: "月宮雅", color: "ffd9db"),
            .init(name: "道明寺歌鈴", color: "d22630"),
            .init(name: "原田美世", color: "e94047"),
        ]
        //        Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: SelectQuery(where: WhereClause(
        //            patterns:
        //                subject(Var("idol")).rdfTypeIsImasIdol()
        //                .rdfsLabel(is: Var("name"))
        //                .imasColor(is: Var("color"))
        //                .imasBrand(is: Var("brand"))
        ////                            .imasBrand(is: .rdf(.init(string: "va-liv", lang: "en")))
        //            //                .imasBrand(is: .rdf(.init(string: "ShinyColors", lang: "en")))
        ////                .imasBrand(is: .rdf(.init(string: "ShinyColors", lang: "en")))
        ////                .imasBrand(is: .rdf(.init(string: "CinderellaGirls", lang: "en")))
        ////                .filter(.regex(v: Var("brand"), pattern: "(ShinyColors|Gakuen)"))
        //                .triples
        //        ), order: [.by(.RAND)], limit: 100))
        //        .fetch()
        //        .onSuccess {(idols: [Idol]) in self.idolsModel.idols = idols}
        //        .onFailure {NSLog("%@", "query error: \(String(describing: $0))")}
    }
}

struct Idol: Codable {
    var name: String
    var color: String
    
    private var rgb_min_max: (r: Float, g: Float, b: Float, min: Float, max: Float)? {
        guard color.count == 6,
              let rgb = Int(color, radix: 16) else { return nil }
        let r = Float((rgb & 0xff0000) >> 16) / 255
        let g = Float((rgb & 0x00ff00) >> 8) / 255
        let b = Float((rgb & 0x0000ff) >> 0) / 255
        return (r, g, b, min(r, g, b), max(r, g, b))
    }
    
    var hue: Float? {
        guard let (r, g, b, min, max) = rgb_min_max else { return nil }
        guard min < max else { return nil }
        let h: Float = {
            switch max {
            case r: return (g - b) / (max - min) / 6 + (0 / 3)
            case g: return (b - r) / (max - min) / 6 + (1 / 3)
            case b: return (r - g) / (max - min) / 6 + (2 / 3)
            default: fatalError()
            }
        }()
        return h + (h < 0 ? 1 : 0)
    }
    
    var saturation: Float? {
        guard let (_, _, _, min, max) = rgb_min_max else { return nil }
        return (max - min) / max
    }
    
    var brightness: Float? {
        rgb_min_max?.max
    }
}

final class HostingView: NSHostingView<ContentView> {
    init(model: ContentView.Model) {
        super.init(rootView: ContentView(model: model))
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(rootView: ContentView) {
        fatalError("init(rootView:) has not been implemented")
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        bounds.contains(point) ? self : super.hitTest(point)
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard case .scrollWheel = event.type else { return }
        rootView.model.scrollOffset += Double(event.deltaY)
    }
}

struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
