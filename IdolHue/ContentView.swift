//
//  ContentView.swift
//  IdolHue
//
//  Created by BAN Jun on R 2/10/01.
//

import SwiftUI

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

extension Idol: Identifiable {
    var id: String { name }
}

class Idols: ObservableObject {
    @Published var idols: [Idol]
    init(idols: [Idol]) { self.idols = idols }
}

struct ContentView: View {
    @ObservedObject var model: Idols

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let side = min(geometry.size.width, geometry.size.height) / 3
                ForEach(Array(stride(from: 0, to: 360, by: 1)), id: \.self) { hue in Rectangle()
                    .foregroundColor(.init(hue: Double(hue) / 360, saturation: 1, brightness: 1))
                    .frame(width: 32, height: 4)
                    .transformEffect(
                        CGAffineTransform.identity
                            .translatedBy(x: +16, y: +2)
                            .rotated(by: hue / 180 * .pi)
                            .translatedBy(x: side, y: 0)
                            .translatedBy(x: -16, y: -2))
                }
                ForEach(model.idols) { idol in
                    Text(idol.name)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 1, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                        .transformEffect(.init(translationX: side, y: 0))
                        .rotationEffect(Angle(degrees: 360 * Double(idol.hue ?? 0)), anchor: .center)
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
            Idol(name: "橘ありすB", color: "0000FF")
        ]))
    }
}
