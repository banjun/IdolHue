import RealityKit

protocol NodeSugar {
    static var name: String { get }
    var name: String { get set }
    init(name: String)
}

extension NodeSugar {
    static var name: String {String(describing: self)}
    @available(visionOS 27.0, *)
    init?(graph: ShaderGraph, library: ShaderGraph.NodeLibrary) throws {
        guard let def = library.definition(named: Self.name) else { return nil }
        self.init(name: try graph.addNode(try library.makeNode(from: def)))
    }
}

@available(visionOS 27.0, *)
extension ShaderGraph.Node: NodeSugar {
    init(name: String) {fatalError()}
}

protocol NodeSugarOutputInt: NodeSugar {}
protocol NodeSugarOutputFloat: NodeSugar {}
protocol NodeSugarOutputFloat2: NodeSugar {}
protocol NodeSugarOutputFloat3: NodeSugar {}
protocol NodeSugarOutputColor3: NodeSugar {}
protocol NodeSugarOutputColor4: NodeSugar {}

@available(visionOS 27.0, *)
extension ShaderGraph {
    struct NodeBuilder {
        var graph: ShaderGraph
        var library: NodeLibrary

        func connect<N: NodeSugar>(from: N) -> NodeConnectionBuilder<N> {
            .init(nodeBuilder: self, last: from)
        }
        struct Constant: NodeSugar, NodeSugarOutputInt, NodeSugarOutputFloat, NodeSugarOutputFloat2, NodeSugarOutputFloat3 {var name: String}
        func connect(from: ShaderGraph.Value) throws -> NodeConnectionBuilder<Constant> {
            .init(nodeBuilder: self, last: Constant(name: try graph.addConstant(from)))
        }
        func graphInput(_ input: ShaderGraph.NodeDefinition.Input) -> NodeConnectionBuilder<ShaderGraph.Node> {
            .init(nodeBuilder: self, last: graph.arguments, outputPort: input.name)
        }

        struct NodeConnectionBuilder<N: NodeSugar> {
            var graph: ShaderGraph {nodeBuilder.graph}
            let nodeBuilder: NodeBuilder
            var last: N
            var outputPort: String?

            private func connectSugar(to: any NodeSugar, from: any NodeSugar, inputPort: String? = nil, caller: String = #function) throws {
                try graph.connect(from.name, outputPort: outputPort, to: to.name, inputPort: inputPort ?? String(caller.prefix {$0 != "("}))
            }

            private func build<From: NodeSugar, To: NodeSugar>(_ last: From, _ to: To, caller: String = #function) throws -> NodeConnectionBuilder<To> {
                try connectSugar(to: to, from: last, caller: caller)
                return .init(nodeBuilder: nodeBuilder, last: to)
            }

            func graphOutput(_ output: ShaderGraph.NodeDefinition.Output? = nil) throws {
                guard let output = output ?? graph.outputs.first else { return }
                try graph.connect(last.name, to: graph.results.name, inputPort: output.name)
            }

            // templates where N = RealityKit ShaderGraph Node Name, I1 = Node Input 1, ... In = Node Input N
            // @discardableResult func {{I1}}(_ to: {{N}}) throws -> NodeConnectionBuilder<{{N}}> {try build(last, to)}
            // :
            // @discardableResult func {{In}}(_ to: {{N}}) throws -> NodeConnectionBuilder<{{N}}> {try build(last, to)}

            @discardableResult func file(_ to: ND_RealityKitTexture2DPixel_color3) throws -> NodeConnectionBuilder<ND_RealityKitTexture2DPixel_color3> {try build(last, to)}
            @discardableResult func file(_ to: ND_RealityKitTexture2DPixel_color4) throws -> NodeConnectionBuilder<ND_RealityKitTexture2DPixel_color4> {try build(last, to)}
            @discardableResult func filter(_ to: ND_RealityKitTexture2DPixel_color3) throws -> NodeConnectionBuilder<ND_RealityKitTexture2DPixel_color3> {try build(last, to)}
        }
    }
}
@available(visionOS 27.0, *)
extension ShaderGraph.NodeBuilder.NodeConnectionBuilder where N: NodeSugarOutputInt {
    typealias NodeConnectionBuilder = ShaderGraph.NodeBuilder.NodeConnectionBuilder
    @discardableResult func `in`(_ to: ShaderGraph.NodeBuilder.ND_convert_integer_float) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_convert_integer_float> {try build(last, to)}
    @discardableResult func convert() throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_convert_integer_float> {try `in`( nodeBuilder.ND_convert_integer_float())}
}
@available(visionOS 27.0, *)
extension ShaderGraph.NodeBuilder.NodeConnectionBuilder where N: NodeSugarOutputFloat {
    typealias NodeConnectionBuilder = ShaderGraph.NodeBuilder.NodeConnectionBuilder
    @discardableResult func in1(_ to: ShaderGraph.NodeBuilder.ND_combine2_vector2) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_combine2_vector2> {try build(last, to)}
    @discardableResult func in2(_ to: ShaderGraph.NodeBuilder.ND_combine2_vector2) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_combine2_vector2> {try build(last, to)}
    @discardableResult func in1(_ to: ShaderGraph.NodeBuilder.ND_divide_float) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_divide_float> {try build(last, to)}
    @discardableResult func in2(_ to: ShaderGraph.NodeBuilder.ND_divide_float) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_divide_float> {try build(last, to)}
    @discardableResult func in1(_ to: ShaderGraph.NodeBuilder.ND_combine3_color3) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_combine3_color3> {try build(last, to)}
    @discardableResult func in2(_ to: ShaderGraph.NodeBuilder.ND_combine3_color3) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_combine3_color3> {try build(last, to)}
    @discardableResult func in3(_ to: ShaderGraph.NodeBuilder.ND_combine3_color3) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_combine3_color3> {try build(last, to)}
    
    @discardableResult func combine(in1: Float) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_combine2_vector2> {
        let to = nodeBuilder.ND_combine2_vector2()
        try nodeBuilder.connect(from: .float(in1)).in1(to)
        return try in2(to)
    }
    @discardableResult func combine(in2: Float) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_combine2_vector2> {
        let to = nodeBuilder.ND_combine2_vector2()
        try in1(to)
        return try nodeBuilder.connect(from: .float(in2)).in2(to)
    }
}
@available(visionOS 27.0, *)
extension ShaderGraph.NodeBuilder.NodeConnectionBuilder where N: NodeSugarOutputFloat2 {
    typealias NodeConnectionBuilder = ShaderGraph.NodeBuilder.NodeConnectionBuilder
    @discardableResult func texcoord(_ to: ShaderGraph.NodeBuilder.ND_RealityKitTexture2DPixel_color3) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_RealityKitTexture2DPixel_color3> {try build(last, to)}
    @discardableResult func texcoord(_ to: ShaderGraph.NodeBuilder.ND_RealityKitTexture2DPixel_color4) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_RealityKitTexture2DPixel_color4> {try build(last, to)}
}
@available(visionOS 27.0, *)
extension ShaderGraph.NodeBuilder.NodeConnectionBuilder where N: NodeSugarOutputColor3 {
    typealias NodeConnectionBuilder = ShaderGraph.NodeBuilder.NodeConnectionBuilder
    @discardableResult func color(_ to: ShaderGraph.NodeBuilder.ND_realitykit_unlit_surfaceshader) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_realitykit_unlit_surfaceshader> {try build(last, to)}
    @discardableResult func baseColor(_ to: ShaderGraph.NodeBuilder.ND_realitykit_pbr_surfaceshader) throws -> NodeConnectionBuilder<ShaderGraph.NodeBuilder.ND_realitykit_pbr_surfaceshader> {try build(last, to)}
}

@available(visionOS 27, *)
extension ShaderGraph.NodeBuilder {
    init(named: String = "graph", inputs: [ShaderGraph.NodeDefinition.Input] = [], outputs: [ShaderGraph.NodeDefinition.Output] = [.init(name: "out", type: .surfaceShader)], version: ShaderGraph.NodeLibrary.Version = .default) throws {
        let library = ShaderGraph.NodeLibrary(version: version)
        self.init(graph: try ShaderGraph(named: named, inputs: inputs, outputs: outputs, nodeLibrary: library), library: library)
    }

    struct ND_realitykit_unlit_surfaceshader: NodeSugar {var name: String}
    func ND_realitykit_unlit_surfaceshader() -> ND_realitykit_unlit_surfaceshader {try! .init(graph: graph, library: library)!}

    struct ND_realitykit_pbr_surfaceshader: NodeSugar {var name: String}
    func ND_realitykit_pbr_surfaceshader() -> ND_realitykit_pbr_surfaceshader {try! .init(graph: graph, library: library)!}

    struct ND_combine2_vector2: NodeSugar, NodeSugarOutputFloat2 {var name: String}
    func ND_combine2_vector2() -> ND_combine2_vector2 {try! .init(graph: graph, library: library)!}

    struct ND_combine3_color3: NodeSugar, NodeSugarOutputColor3 {var name: String}
    func ND_combine3_color3() -> ND_combine3_color3 {try! .init(graph: graph, library: library)!}

    struct ND_convert_integer_float: NodeSugar, NodeSugarOutputFloat {var name: String}
    func ND_convert_integer_float() -> ND_convert_integer_float {try! .init(graph: graph, library: library)!}

    struct ND_realitykit_instance_id: NodeSugar, NodeSugarOutputInt {var name: String}
    func ND_realitykit_instance_id() -> ND_realitykit_instance_id {try! .init(graph: graph, library: library)!}

    struct ND_divide_float: NodeSugar {var name: String}
    func ND_divide_float() -> ND_divide_float {try! .init(graph: graph, library: library)!}

    struct ND_RealityKitTexture2DPixel_color3: NodeSugar, NodeSugarOutputColor3 {var name: String}
    func ND_RealityKitTexture2DPixel_color3() -> ND_RealityKitTexture2DPixel_color3 {try! .init(graph: graph, library: library)!}
    enum Filter: String {case nearest, linear}
    func ND_RealityKitTexture2DPixel_color3(filter: Filter) -> ND_RealityKitTexture2DPixel_color3 {
        try! connect(from: .string(filter.rawValue)).filter(self.ND_RealityKitTexture2DPixel_color3()).last
    }

    struct ND_RealityKitTexture2DPixel_color4: NodeSugar, NodeSugarOutputColor4 {var name: String}
    func ND_RealityKitTexture2DPixel_color4() -> ND_RealityKitTexture2DPixel_color4 {try! .init(graph: graph, library: library)!}
}
@available(visionOS 27, *)
extension ShaderGraphMaterial {
    init(from builder: ShaderGraph.NodeBuilder, inputValues: [String: MaterialParameters.Value] = [:]) async throws {
        try await self.init(program: .init(descriptor: .init(inferredFrom: builder.graph, inputValues: inputValues)))
    }
}
