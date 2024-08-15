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
    var radius: Float = 0.5
    @Environment(\.physicalMetrics) private var physicalMetrics
    @State private var scene: Entity!

    var body: some View {
        GeometryReader3D { geometry in
            RealityView { content in
                scene = try! await Entity(named: "Scene", in: idolSpaceBundle)
                scene.position.y = -0.5
                content.add(scene)
            } update: { content in
                guard let scene else { return }
                let scale = Float(physicalMetrics.convert(Double(geometry.size.height), to: .meters))
                scene.transform.scale = .init(repeating: scale)
                scene.position.y = -scale / 2
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
