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

    private func log01(s: Float) -> CGFloat {
        log(CGFloat((expf(1) - 1) * s + 1))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let side = min(geometry.size.width, geometry.size.height) / 3
                ForEach([CGFloat](stride(from: 0, to: 360, by: 0.5)), id: \.self) { hue in Rectangle()
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
                    HStack(alignment: .center, spacing: 4) {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.init(hue: Double(idol.hue ?? 0), saturation: Double(idol.saturation ?? 0), brightness: Double(idol.brightness ?? 0)))
                        Text(idol.name + (idol.hue.map {" (\(Int(round($0 * 360)))°)"} ?? ""))
                            .shadow(color: .init(.textBackgroundColor), radius: 1)
                    }
                    .transformEffect(.init(translationX: side * log01(s: idol.saturation ?? 0), y: 0))
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
            Idol(name: "橘ありすW", color: "FFFFFF"),
            Idol(name: "橘ありすWB", color: "9999FF")
        ]))
    }
}
