import SwiftUI

struct HeaderBannerView: View {
    var body: some View {
        Image(.header)
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}
