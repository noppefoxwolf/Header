import SwiftUI

struct HeaderBannerView: View {
    var body: some View {
        if #available(iOS 26.0, *) {
            image
                .backgroundExtensionEffect()
        } else {
            image
        }
    }
    
    var image: some View {
        Image(.header)
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fill)
    }
}
