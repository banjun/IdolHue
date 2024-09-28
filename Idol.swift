import Foundation
import SwiftSparql

extension Idol {
    static func fetch(brand: Brand?) async throws -> [Idol] {
        try await Imasparql(query: SelectQuery(where: WhereClause(
            patterns: {
                let p = subject(Var("idol")).rdfTypeIsImasIdol()
                    .rdfsLabel(is: Var("name"))
                    .optional {$0.imasColor(is: Var("color"))}
                if let brand {
                    return p.imasBrand(is: .rdf(.init(string: brand.rawValue, lang: "en"))).triples
                } else {
                    return p.triples
                }
            }()
        ), order: [.by(.RAND)], limit: 400))
        .fetch()
    }
}

struct Idol: Codable, Hashable {
    var name: String
    var color: String?

    var rgb_min_max: (r: Float, g: Float, b: Float, min: Float, max: Float)? {
        guard let color, color.count == 6,
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

import CoreGraphics
extension Idol {
    var lab: (l: CGFloat, a: CGFloat, b: CGFloat)? {
        guard let (r, g, b, _, _) = rgb_min_max else { return nil }
        guard let lab = CGColor(srgbRed: .init(r), green: .init(g), blue: .init(b), alpha: 1)
            .converted(to: .init(name: CGColorSpace.genericLab)!,
                       intent: CGColorRenderingIntent.perceptual,
                       options: nil)?.components else { return nil }
        return (lab[0], lab[1], lab[2])
    }
}
