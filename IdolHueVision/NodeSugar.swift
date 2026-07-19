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
    struct NodeBuilder {
        var graph: ShaderGraph
        var library: NodeLibrary

        func connect<N: NodeSugar>(from: N) -> NodeConnectionBuilder<N> {
            .init(graph: graph, last: from)
        }
        struct Constant: NodeSugar {var node: String}
        func connect(from: ShaderGraph.Value) throws -> NodeConnectionBuilder<Constant> {
            .init(graph: graph, last: Constant(node: try graph.addConstant(from)))
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

            // templates where N = RealityKit ShaderGraph Node Name, I1 = Node Input 1, ... In = Node Input N
            // @discardableResult func {{I1}}(_ to: {{N}}) throws -> NodeConnectionBuilder<{{N}}> {try build(last, to)}
            // :
            // @discardableResult func {{In}}(_ to: {{N}}) throws -> NodeConnectionBuilder<{{N}}> {try build(last, to)}

            @discardableResult func `in`(_ to: ND_convert_integer_float) throws -> NodeConnectionBuilder<ND_convert_integer_float> {try build(last, to)}
            @discardableResult func in1(_ to: ND_divide_float) throws -> NodeConnectionBuilder<ND_divide_float> {try build(last, to)}
            @discardableResult func in2(_ to: ND_divide_float) throws -> NodeConnectionBuilder<ND_divide_float> {try build(last, to)}
            @discardableResult func in1(_ to: ND_combine3_color3) throws -> NodeConnectionBuilder<ND_combine3_color3> {try build(last, to)}
            @discardableResult func baseColor(_ to: ND_realitykit_pbr_surfaceshader) throws -> NodeConnectionBuilder<ND_realitykit_pbr_surfaceshader> {try build(last, to)}
        }
    }
}
@available(visionOS 27, *)
extension ShaderGraph.NodeBuilder {
    init(named: String = "graph", outputs: [ShaderGraph.NodeDefinition.Output] = [.init(name: "out", type: .surfaceShader)], version: ShaderGraph.NodeLibrary.Version = .default) throws {
        let library = ShaderGraph.NodeLibrary(version: version)
        self.init(graph: try ShaderGraph(named: named, inputs: [], outputs: outputs, nodeLibrary: library), library: library)
    }

    struct ND_realitykit_pbr_surfaceshader: NodeSugar {var node: String}
    func ND_realitykit_pbr_surfaceshader() -> ND_realitykit_pbr_surfaceshader {try! .init(graph: graph, library: library)!}

    struct ND_combine3_color3: NodeSugar {var node: String}
    func ND_combine3_color3() -> ND_combine3_color3 {try! .init(graph: graph, library: library)!}

    struct ND_convert_integer_float: NodeSugar {var node: String}
    func ND_convert_integer_float() -> ND_convert_integer_float {try! .init(graph: graph, library: library)!}

    struct ND_realitykit_instance_id: NodeSugar {var node: String}
    func ND_realitykit_instance_id() -> ND_realitykit_instance_id {try! .init(graph: graph, library: library)!}

    struct ND_divide_float: NodeSugar {var node: String}
    func ND_divide_float() -> ND_divide_float {try! .init(graph: graph, library: library)!}
}
@available(visionOS 27, *)
extension ShaderGraphMaterial {
    init(from builder: ShaderGraph.NodeBuilder) async throws {
        try await self.init(program: .init(descriptor: .init(inferredFrom: builder.graph)))
    }
}
//@available(visionOS 27, *)
//extension ShaderGraph {
//    // templates where N = RealityKit ShaderGraph Node Name
//    // struct {{N}}: NodeSugar {var node: String}
//    // func {{N}}(_ library: NodeLibrary) -> {{N}} {try! .init(graph: self, library: library)!}
//
//    struct ND_realitykit_pbr_surfaceshader: NodeSugar {var node: String}
//    func ND_realitykit_pbr_surfaceshader(_ library: NodeLibrary) -> ND_realitykit_pbr_surfaceshader {try! .init(graph: self, library: library)!}
//
//    struct ND_combine3_color3: NodeSugar {var node: String}
//    func ND_combine3_color3(_ library: NodeLibrary) -> ND_combine3_color3 {try! .init(graph: self, library: library)!}
//
//    struct ND_convert_integer_float: NodeSugar {var node: String}
//    func ND_convert_integer_float(_ library: NodeLibrary) -> ND_convert_integer_float {try! .init(graph: self, library: library)!}
//
//    struct ND_realitykit_instance_id: NodeSugar {var node: String}
//    func ND_realitykit_instance_id(_ library: NodeLibrary) -> ND_realitykit_instance_id {try! .init(graph: self, library: library)!}
//
//    struct ND_divide_float: NodeSugar {var node: String}
//    func ND_divide_float(_ library: NodeLibrary) -> ND_divide_float {try! .init(graph: self, library: library)!}
//}
