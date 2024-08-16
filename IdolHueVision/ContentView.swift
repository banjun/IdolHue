import SwiftUI
import RealityKit
import IdolSpace

struct ContentView: View {
    @State private var idols: [Idol] = []
    var body: some View {
        ZStack {
            IdolHueView(idols: idols)
                .onAppear {
                    Task.detached { @MainActor in
                        self.idols = try await Idol.fetch()
                    }
                }

            VStack {
                Button {
                } label: {
                    Text("Button")
                }
                .fontWeight(.semibold)

                Text("\(idols.count) idols")
            }
            .padding()
            .glassBackgroundEffect()
        }
    }
}
struct IdolHueView: View {
    var idols: [Idol] = []
    @Environment(\.physicalMetrics) private var physicalMetrics
    @State private var scene: Entity = try! Entity.load(named: "Scene", in: idolSpaceBundle)
    @State private var idolEntitiesRoot = Entity()

    var body: some View {
        GeometryReader3D { geometry in
            RealityView { content in
                content.add(scene)
                scene.addChild(idolEntitiesRoot)
                layout(geometry: geometry)
            } update: { _ in
                layout(geometry: geometry)
            }
            .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
                print(value.entity.name)
            })
        }
    }

    private func layout(geometry: GeometryProxy3D) {
        let scale = Float(physicalMetrics.convert(Double(geometry.size.width), to: .meters))
        scene.transform.scale = .init(repeating: scale)
        scene.position.y = -scale / 2

        if idolEntitiesRoot.children.count != idols.count {
            idolEntitiesRoot.children.forEach { $0.removeFromParent() }
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
                if let hue {
                    let θ = hue * .pi * 2
                    let r = ((saturation ?? 0) / 2) * (1 - 2 * sphereSize)
                    e.position = .init(r * cos(θ), y, r * sin(θ))
                } else {
                    e.position = .init(0, y, 0)
                }
                idolEntitiesRoot.addChild(e)
            }
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


import simd
import Foundation

func generateOvalPlaneMesh(radiusInMeter: Float = 0.5, divisions: Int = 100, name: String = "GeneratedOvalPlane") {
    let n = divisions
    let points: [SIMD3<Float>] = (0..<n).map { i in
        let theta = Float(i) * 2 * .pi / Float(n - 1)
        return SIMD3(cos(theta), 0, -sin(theta)) * radiusInMeter
    }
    let faceVertexIndices: [Int] = (0..<(n-2)).flatMap { i in
        [0, i + 1, i + 2]
    }
    let faceVertexCounts: [Int] = .init(repeating: 3, count: faceVertexIndices.count / 3)
    // USDA
    print("")
    print("#usda 1.0")
    print("")
    print("def Mesh \"\(name)\" {")
    print("  float3[] points = \(points.map {($0.x, $0.y, $0.z)})")
    print("  int[] faceVertexIndices = \(faceVertexIndices)")
    print("  int[] faceVertexCounts = \(faceVertexCounts)")
    print("}")
    print("")
}
