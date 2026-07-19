import Foundation
import SwiftUI
import RealityKit
import IdolSpace

struct IdolHueView: View {
    // var id = UUID()
    var idols: [Idol] = []
    @Environment(\.physicalMetrics) private var physicalMetrics
    @State private var scene: Entity = try! Entity.load(named: "Scene", in: idolSpaceBundle)
    @State private var idolEntitiesRoot = Entity()
    let modelSortGroup = ModelSortGroup(depthPass: .prePass)

    var body: some View {
        GeometryReader3D { geometry in
            RealityView { content in
                content.add(scene)
                scene.addChild(idolEntitiesRoot)
                idolEntitiesRoot.components.set(ModelSortGroupComponent(group: modelSortGroup, order: 9))
                scene.findEntity(named: "Cylinder")?.components.set(ModelSortGroupComponent(group: modelSortGroup, order: 199))
                await layout(geometry: geometry)
            } update: { _ in
                Task {await layout(geometry: geometry)}
            }
            .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
                print(value.entity.name)
//                value.entity.playAnimation(try! .makeActionAnimation(for: EmphasizeAction(motionType: .pulse, style: .basic), bindTarget: .transform))
            })
//            .onChange(of: idols) { _, _ in Task {await layout(geometry: geometry)}}
        }
    }

    private func layout(geometry: GeometryProxy3D) async {
        let scale = Float(physicalMetrics.convert(Double(geometry.size.width), to: .meters))
        scene.transform.scale = .init(repeating: scale)
        scene.position.y = -scale / 2

        if idolEntitiesRoot.children.count != idols.count {
            idolEntitiesRoot.children.removeAll()
            let sphereSize: Float = 0.03
            let sphere = ModelEntity(mesh: .generateSphere(radius: sphereSize))
            if #available(visionOS 27.0, *) {
                let instanceCount = idols.count
                let instanceData = try! LowLevelInstanceData(instanceCount: instanceCount)
                instanceData.withMutableTransforms { transforms in
                    for i in 0..<instanceCount {
                        let idol = idols[i]
                        let hue = idol.hue
                        let saturation = idol.saturation
                        let brightness = idol.brightness
                        let y = (idol.brightness ?? 0) * (1 - 2 * sphereSize) + sphereSize

                        if let hue {
                            let θ = hue * .pi * 2
                            let r = ((saturation ?? 0) / 2) * (1 - 2 * sphereSize)
                            transforms[i] = Transform(translation: .init(r * cos(θ), y, r * sin(θ))).matrix
                        } else {
                            transforms[i] = Transform(translation: .init(0, y, 0)).matrix
                        }
                    }
                }
                sphere.components.set(try! MeshInstancesComponent(mesh: .generateSphere(radius: sphereSize), instances: instanceData))
            } else {
            }
            sphere.components.set(HoverEffectComponent(.shader(.default)))
            sphere.components.set(InputTargetComponent())
            sphere.components.set(CollisionComponent(shapes: [.generateSphere(radius: sphereSize)]))
            sphere.components.set(ModelSortGroupComponent(group: modelSortGroup, order: 9))
            let sphereMaterial: ShaderGraphMaterial
            if #available(visionOS 27, *) {
                let library = ShaderGraph.NodeLibrary(version: .materialX139)
                let graph = try! ShaderGraph(named: "g", inputs: [], outputs: [.init(name: "out", type: .surfaceShader)], nodeLibrary: library)
                let pbr = graph.ND_realitykit_pbr_surfaceshader(library)
                let color = graph.ND_combine3_color3(library)
                try! graph.connect(from: graph.ND_realitykit_instance_id(library))
                    .in(graph.ND_convert_integer_float(library))
                    .in1(graph.connect(from: .float(Float(idols.count))).in2(graph.ND_divide_float(library)).last)
                    .in1(color)
                    .baseColor(pbr)
                    .out()
                sphereMaterial = try! await ShaderGraphMaterial(program: .init(descriptor: .init(inferredFrom: graph)))

                sphere.model!.materials = [sphereMaterial]
                idolEntitiesRoot.addChild(sphere)
            } else {
                sphereMaterial = try! await ShaderGraphMaterial(named: "/SphereMaterial", from: "Scene", in: idolSpaceBundle)
                idols.forEach { idol in
                    let hue = idol.hue
                    let saturation = idol.saturation
                    let brightness = idol.brightness
                    let y = (idol.brightness ?? 0) * (1 - 2 * sphereSize) + sphereSize
                    //                var m = PhysicallyBasedMaterial()
                    //                m.baseColor = .init(tint: .init(hue: .init(hue ?? 0), saturation: .init(saturation ?? 0), brightness: .init(brightness ?? 0), alpha: hue.map {_ in 1} ?? 0))
                    //                m.emissiveColor = .init(color: m.baseColor.tint)
                    //                m.emissiveIntensity = 0.8
                    //                m.roughness = 0.2
                    //                m.metallic = 0.01
                    //                m.blending = .transparent(opacity: 0.9)
                    //                var m2 = UnlitMaterial(color: .init(hue: .init(hue ?? 0), saturation: .init(saturation ?? 0), brightness: .init(brightness ?? 0), alpha: hue.map {_ in 1} ?? 0), applyPostProcessToneMap: true)
                    //                m2.blending = .opaque

                    var m = sphereMaterial
                    try? m.setParameter(name: "color", value: .color(UIColor(hue: .init(hue ?? 0), saturation: .init(saturation ?? 0), brightness: .init(brightness ?? 0), alpha: hue.map {_ in 1} ?? 0).cgColor))

                    let e = sphere.clone(recursive: false)
                    e.model!.materials = [m]
                    e.name = idol.name
                    if let hue {
                        let θ = hue * .pi * 2
                        let r = ((saturation ?? 0) / 2) * (1 - 2 * sphereSize)
                        e.position = .init(r * cos(θ), y, r * sin(θ))
                    } else {
                        e.position = .init(0, y, 0)
                    }



                    //                // Lab
                    //                if let (l, a, b) = idol.lab {
                    //                    e.position = .init(Float(a) / 128 / 2 * (1 - sphereSize), Float(l) / 100, Float(b) / 128 / 2 * (1 - sphereSize))
                    //                }

                    // original
                    if let hue, let saturation, let (l, _, _) = idol.lab, let (r, g, b, _, _) = idol.rgb_min_max {
                        let l: Float = Float(l / 50) - 1 // [-1,+1]
                        //                    let l: Float = (r + g + b) / 3 * 2 - 1
                        let θ: Float = (l + 1) * .pi / 4
                        let hr: Float = sin(θ)
                        let c: Float = l - hr + 1
                        let φ: Float = (1 - saturation) * .pi / 2
                        let sr: Float = hr * cos(φ)
                        let hθ: Float = hue * .pi * 2
                        e.position = .init(sr * cos(hθ) / 2,
                                           (c + hr * sin(φ)) / 2 * (1 - 2 * sphereSize),
                                           sr * sin(hθ) / 2)
                    }


                    idolEntitiesRoot.addChild(e)
                }
            }
            // NSLog("%@", "\(Self.self)(\(id)) updated idol entities \(idolEntitiesRoot.children.count) == \(idols.count)")
        }
    }
}

#Preview(windowStyle: .volumetric) {
    IdolHueView(idols: [
        Idol(name: "橘ありす", color: "5881C1"),
        Idol(name: "橘ありすR", color: "FF0000"),
        Idol(name: "橘ありすR4", color: "FF4444"),
        Idol(name: "橘ありすR8", color: "FF8888"),
        Idol(name: "橘ありすRC", color: "FFCCCC"),
        Idol(name: "橘ありすG", color: "00FF00"),
        Idol(name: "橘ありすB", color: "0000FF"),
        Idol(name: "橘ありすW", color: "FFFFFF"),
        Idol(name: "橘ありすWB", color: "9999FF"),
    ])
}
