import Foundation
import SwiftSparql

extension Idol {
    static func fetch() async throws -> [Idol] {
        try await Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: SelectQuery(where: WhereClause(
            patterns:
                subject(Var("idol")).rdfTypeIsImasIdol()
                .rdfsLabel(is: Var("name"))
                .imasColor(is: Var("color"))
                .imasBrand(is: .rdf(.init(string: "ShinyColors", lang: "en")))
            //                .imasBrand(is: .rdf(.init(string: "CinderellaGirls", lang: "en")))
                .triples
        ), order: [.by(.RAND)], limit: 100))
        .fetch()
    }
}

struct Idol: Codable, Hashable {
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
