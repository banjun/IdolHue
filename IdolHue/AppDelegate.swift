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

        Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: SelectQuery(where: WhereClause(
            patterns:
                subject(Var("idol")).rdfTypeIsImasIdol()
                .rdfsLabel(is: Var("name"))
                .imasColor(is: Var("color"))
//                .imasTitle(is: .rdf(.init(string: "CinderellaGirls", lang: "en")))
                .imasTitle(is: .rdf(.init(string: "283Pro", lang: "en")))
                .triples
        ), order: [.by(.RAND)], limit: 100))
        .fetch()
        .onSuccess {(idols: [Idol]) in self.idolsModel.idols = idols}
        .onFailure {NSLog("%@", "query error: \(String(describing: $0))")}
    }
}

struct Idol: Codable {
    var name: String
    var color: String

    var hue: Float? {
        guard color.count == 6,
              let rgb = Int(color, radix: 16) else { return nil }
        let r = Float((rgb & 0xff0000) >> 16) / 255
        let g = Float((rgb & 0x00ff00) >> 8) / 255
        let b = Float((rgb & 0x0000ff) >> 0) / 255
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
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
