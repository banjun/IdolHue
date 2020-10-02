//
//  ContentView.swift
//  IdolHue
//
//  Created by BAN Jun on R 2/10/01.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model

    class Model: ObservableObject {
        @Published var idols: [Idol]
        @Published var scrollOffset: Double = 0

        init(idols: [Idol] = []) {self.idols = idols}
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let side = min(geometry.size.width, geometry.size.height) / 3
                ForEach([CGFloat](stride(from: 0, to: 360, by: 1)), id: \.self) { hue in Rectangle()
                    .foregroundColor(.init(hue: Double(hue) / 360, saturation: 1, brightness: 1))
                    .frame(width: 32, height: 4)
                    .transformEffect(
                        CGAffineTransform.identity
                            .translatedBy(x: +16, y: +2)
                            .rotated(by: (CGFloat(model.scrollOffset) + hue) / 180 * .pi)
                            .translatedBy(x: side, y: 0)
                            .translatedBy(x: -16, y: -2))
                }
                ForEach(model.idols, id: \.name) { idol in
                    Text(idol.name)
                        .shadow(color: .init(.textBackgroundColor), radius: 1)
                        .transformEffect(.init(translationX: idol.hue != nil ? side : 0, y: 0))
                        .rotationEffect(Angle(degrees: idol.hue.map {model.scrollOffset + 360 * Double($0)} ?? 0), anchor: .center)
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: .init(idols: [
            Idol(name: "橘ありす", color: "5881C1"),
            Idol(name: "橘ありすR", color: "FF0000"),
            Idol(name: "橘ありすG", color: "00FF00"),
            Idol(name: "橘ありすB", color: "0000FF"),
            Idol(name: "橘ありすW", color: "FFFFFF")
        ]))
    }
}
