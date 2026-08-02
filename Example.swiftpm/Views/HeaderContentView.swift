import SwiftUI

struct HeaderContentView: View {
    var isTall = false

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
            
            if isTall {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(0..<24, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Title \(index + 1)").font(.headline).bold()
                            Text("Subtitle \(index + 1)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Title").font(.headline).bold()
                    Text("Subtitle").font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}
