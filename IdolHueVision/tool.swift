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
