import SwiftUI

struct HeaderContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .bottom) {
                Spacer()
                
                Button {
                    print("action")
                } label: {
                    Text("Follow")
                }
                .buttonStyle(.borderedProminent)
            }
            .overlay(alignment: .bottomLeading) {
                Circle()
                    .frame(width: 80, height: 80)
                    .alignmentGuide(VerticalAlignment.top, computeValue: {
                        $0[VerticalAlignment.center]
                    })
            }
            
            VStack(alignment: .leading) {
                Text("Title").font(.headline).bold()
                Text("Subtitle").font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
