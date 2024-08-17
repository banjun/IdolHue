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
                layout(geometry: geometry)
            } update: { _ in
                layout(geometry: geometry)
            }
            .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
                print(value.entity.name)
            })
            .onChange(of: idols) { _, _ in layout(geometry: geometry) }
        }
    }

    private func layout(geometry: GeometryProxy3D) {
        let scale = Float(physicalMetrics.convert(Double(geometry.size.width), to: .meters))
        scene.transform.scale = .init(repeating: scale)
        scene.position.y = -scale / 2

        if idolEntitiesRoot.children.count != idols.count {
            idolEntitiesRoot.children.removeAll()
            idols.forEach { idol in
                let sphereSize: Float = 0.03
                let hue = idol.hue
                let saturation = idol.saturation
                let brightness = idol.brightness
                let y = (idol.brightness ?? 0) * (1 - 2 * sphereSize) + sphereSize
                var m = PhysicallyBasedMaterial()
                m.baseColor = .init(tint: .init(hue: .init(hue ?? 0), saturation: .init(saturation ?? 0), brightness: .init(brightness ?? 0), alpha: hue.map {_ in 1} ?? 0))
                m.emissiveColor = .init(color: m.baseColor.tint)
                m.emissiveIntensity = 0.8
                m.roughness = 0.2
                m.metallic = 0.01
                m.blending = .transparent(opacity: 0.9)
                let e = ModelEntity(mesh: .generateSphere(radius: sphereSize), materials: [m])
                e.name = idol.name
                e.components.set(HoverEffectComponent())
                e.components.set(InputTargetComponent())
                e.components.set(CollisionComponent(shapes: [.generateSphere(radius: sphereSize)]))
                e.components.set(ModelSortGroupComponent(group: modelSortGroup, order: 9))
                if let hue {
                    let θ = hue * .pi * 2
                    let r = ((saturation ?? 0) / 2) * (1 - 2 * sphereSize)
                    e.position = .init(r * cos(θ), y, r * sin(θ))
                } else {
                    e.position = .init(0, y, 0)
                }

                // Lab
                if let (l, a, b) = idol.lab {
                    e.position = .init(Float(a) / 128 / 2 * (1 - sphereSize), Float(l) / 100 * (1 - sphereSize), Float(b) / 128 / 2 * (1 - sphereSize))
                }

                idolEntitiesRoot.addChild(e)
            }
            // NSLog("%@", "\(Self.self)(\(id)) updated idol entities \(idolEntitiesRoot.children.count) == \(idols.count)")
        }
    }
}

#Preview(windowStyle: .volumetric) {
    IdolHueView(idols: [
        Idol(name: "橘ありす", color: "5881C1"),
        Idol(name: "橘ありすR", color: "FF0000"),
        Idol(name: "橘ありすG", color: "00FF00"),
        Idol(name: "橘ありすB", color: "0000FF"),
        Idol(name: "橘ありすW", color: "FFFFFF"),
        Idol(name: "橘ありすWB", color: "9999FF"),
    ])
}
