import SwiftUI
import Observation

struct ContentView: View {
    private let model: Model = .init()
    @Observable final class Model {
        var idols: [Idol] = []
        var brand: Brand? = .Gakuen

        func fetch() {
            Task.detached { @MainActor in
                do {
                    self.idols = try await Idol.fetch(brand: self.brand)
                } catch {
                    self.idols = []
                    NSLog("%@", "fetch error = \(String(describing: error))")
                }
            }
        }
    }

    var body: some View {
        @Bindable var model = model
        IdolHueView(idols: model.idols)
            .onAppear { model.fetch() }
            .onChange(of: model.brand) { _, _ in model.fetch() }
            .ornament(attachmentAnchor: .scene(.bottomFront), contentAlignment: .top) {
                VStack {
                    Picker("Brand", selection: $model.brand) {
                        ForEach([nil] + Brand.allCases as [Brand?], id: \.self) {
                            Text($0?.rawValue ?? "All").id($0)
                        }
                    }
                    .pickerStyle(.palette)
                    Text("\(model.idols.count) idols")
                }
                .padding()
                .glassBackgroundEffect()
            }
    }
}
