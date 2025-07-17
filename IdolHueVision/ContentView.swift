import SwiftUI
import Observation

struct ContentView: View {
    private let model: Model = .init()
    @MainActor @Observable final class Model {
        var idols: [Idol] = []
        var brand: Brand? = .Gakuen

        func fetch() async {
            do {
                idols = []
                idols = try await Idol.fetch(brand: brand)
            } catch {
                NSLog("%@", "fetch error = \(String(describing: error))")
                idols = Imasparql.cinderellaGirls20250717
            }
        }
    }

    var body: some View {
        @Bindable var model = model
        IdolHueView(idols: model.idols)
            .task { await model.fetch() }
            .onChange(of: model.brand) { _, _ in Task { await model.fetch() } }
            .ornament(attachmentAnchor: .scene(.bottomFront), contentAlignment: .top) {
                VStack {
                    Picker("Brand", selection: $model.brand) {
                        ForEach([nil] + Brand.allCases as [Brand?], id: \.self) {
                            Text($0?.rawValue ?? "All").id($0)
                        }
                    }
                    .pickerStyle(.palette)
                    Text("\(model.idols.isEmpty ? "--" : String(model.idols.count)) idols")
                }
                .padding()
                .glassBackgroundEffect()
            }
    }
}
