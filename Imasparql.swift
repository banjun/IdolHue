import Foundation
import SwiftSparql

struct Imasparql {
    var query: SelectQuery

    func fetch<T: Decodable>() async throws -> [T] {
        NSLog("%@", "query = \(Serializer.serialize(query))")
        let result: [T] = try await Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: query).fetch()
        NSLog("%@", "result = \(result.count) \(String(describing: T.self))")
        return result
    }
}
