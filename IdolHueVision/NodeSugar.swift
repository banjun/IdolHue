import RealityKit

protocol NodeSugar {
    static var name: String { get }
    var node: String { get set }
    init(node: String)
}
extension NodeSugar {
    static var name: String {String(describing: self)}
    @available(visionOS 27.0, *)
    init?(graph: ShaderGraph, library: ShaderGraph.NodeLibrary) throws {
        guard let def = library.definition(named: Self.name) else { return nil }
        self.init(node: try graph.addNode(try library.makeNode(from: def)))
    }
}

@available(visionOS 27.0, *)
extension ShaderGraph {
    func connect<N: NodeSugar>(from: N) -> NodeConnectionBuilder<N> {
        .init(graph: self, last: from)
    }
    struct Constant: NodeSugar {var node: String}
    func connect(from: ShaderGraph.Value) throws -> NodeConnectionBuilder<Constant> {
        .init(graph: self, last: Constant(node: try addConstant(from)))
    }

    struct NodeConnectionBuilder<N: NodeSugar> {
        let graph: ShaderGraph
        var last: N

        private func connectSugar(to: any NodeSugar, from: any NodeSugar, inputPort: String? = nil, caller: String = #function) throws {
            try graph.connect(from.node, to: to.node, inputPort: inputPort ?? String(caller.prefix {$0 != "("}))
        }

        private func build<From: NodeSugar, To: NodeSugar>(_ last: From, _ to: To, caller: String = #function) throws -> NodeConnectionBuilder<To> {
            try connectSugar(to: to, from: last, caller: caller)
            return .init(graph: graph, last: to)
        }

        func out(out: String = "out") throws {
            try graph.connect(last.node, to: graph.results.name, inputPort: out)
        }

        @discardableResult func `in`(_ to: ND_convert_integer_float) throws -> NodeConnectionBuilder<ND_convert_integer_float> {try build(last, to)}
        @discardableResult func in1(_ to: ND_divide_float) throws -> NodeConnectionBuilder<ND_divide_float> {try build(last, to)}
        @discardableResult func in2(_ to: ND_divide_float) throws -> NodeConnectionBuilder<ND_divide_float> {try build(last, to)}
        @discardableResult func in1(_ to: ND_combine3_color3) throws -> NodeConnectionBuilder<ND_combine3_color3> {try build(last, to)}
        @discardableResult func baseColor(_ to: ND_realitykit_pbr_surfaceshader) throws -> NodeConnectionBuilder<ND_realitykit_pbr_surfaceshader> {try build(last, to)}
    }

    struct ND_realitykit_pbr_surfaceshader: NodeSugar {var node: String}
    func ND_realitykit_pbr_surfaceshader(_ library: NodeLibrary) -> ND_realitykit_pbr_surfaceshader {try! .init(graph: self, library: library)!}

    struct ND_combine3_color3: NodeSugar {var node: String}
    func ND_combine3_color3(_ library: NodeLibrary) -> ND_combine3_color3 {try! .init(graph: self, library: library)!}

    struct ND_convert_integer_float: NodeSugar {var node: String}
    func ND_convert_integer_float(_ library: NodeLibrary) -> ND_convert_integer_float {try! .init(graph: self, library: library)!}

    struct ND_realitykit_instance_id: NodeSugar {var node: String}
    func ND_realitykit_instance_id(_ library: NodeLibrary) -> ND_realitykit_instance_id {try! .init(graph: self, library: library)!}

    struct ND_divide_float: NodeSugar {var node: String}
    func ND_divide_float(_ library: NodeLibrary) -> ND_divide_float {try! .init(graph: self, library: library)!}
}
