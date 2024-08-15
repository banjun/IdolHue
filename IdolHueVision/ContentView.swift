import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var idols: [Idol] = []

    var body: some View {
        VStack {
            RealityView { content in
                content.add(ModelEntity(mesh: .generateSphere(radius: 1)))
            } update: { _ in
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
            .onAppear {
                Task.detached { @MainActor in
                    self.idols = try await Idol.fetch()
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
