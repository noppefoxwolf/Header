import SwiftUI

struct HeaderBackgroundContentView: View {
    var body: some View {
        Image(.header)
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}
