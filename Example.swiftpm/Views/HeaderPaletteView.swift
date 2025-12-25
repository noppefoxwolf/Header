import SwiftUI

struct HeaderPaletteView: View {
    let onSelectPage: ((Int) -> Void)?

    init(onSelectPage: ((Int) -> Void)? = nil) {
        self.onSelectPage = onSelectPage
    }

    var body: some View {
        HStack {
            let isEnabled = onSelectPage != nil
            Button {
                onSelectPage?(0)
            } label: {
                Text("Page1")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isEnabled)

            Button {
                onSelectPage?(1)
            } label: {
                Text("Page2")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isEnabled)

            Button {
                onSelectPage?(2)
            } label: {
                Text("Page3")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isEnabled)

            Spacer()

        }
        .padding(4)
    }
}
