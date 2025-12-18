import SwiftUI

struct HeaderBackgroundView: View {
    var body: some View {
        Image(.header)
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}
