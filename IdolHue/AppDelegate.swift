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

        Task.detached { @MainActor in
            do {
                self.idolsModel.idols = try await Idol.fetch(brand: .ShinyColors)
            } catch {
                NSLog("%@", "fetch error = \(String(describing: error))")
            }
        }
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
