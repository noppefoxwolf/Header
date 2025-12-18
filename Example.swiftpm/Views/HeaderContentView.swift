import SwiftUI

struct HeaderContentView: View {
    var body: some View {
        HStack(content: {
            RoundedRectangle(cornerRadius: 32)
                .frame(width: 100, height: 100)
            VStack(alignment: .leading) {
                Text("Title").font(.title).bold()
                Text("Subtitle").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                HStack(alignment: .center) {
                    Button {
                        print("action")
                    } label: {
                        Text("Action")
                    }
                    .buttonStyle(.borderedProminent)
                    Text("Hello, world!")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
        })
        .padding()
    }
}
