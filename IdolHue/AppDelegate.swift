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
    let idolsModel = Idols(idols: [])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(model: idolsModel)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
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

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

