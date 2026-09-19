import SwiftUI

struct HeaderBannerView: View {
    let imageStyle: ImageStyle

    var body: some View {
        backgroundExtendsImage
            .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    var backgroundExtendsImage: some View {
        if #available(iOS 26.0, *) {
            image
                .backgroundExtensionEffect()
        } else {
            image
        }
    }
    
    var image: some View {
        Image(imageStyle.resource)
            .resizable()
            .scaledToFill()
    }

    enum ImageStyle: Equatable {
        case landscape
        case square

        var resource: ImageResource {
            switch self {
            case .landscape:
                return .landscape
            case .square:
                return .square
            }
        }
    }
}
