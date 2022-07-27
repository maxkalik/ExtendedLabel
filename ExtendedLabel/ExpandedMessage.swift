//  Created by Maksim Kalik on 26/05/2022.

import SwiftUI

struct ExpandedMessageView: View {
    var text: String
    var readMore: String
    var readLess: String
    var closeAction: (() -> Void)

    @Environment(\.openURL) var openURL
    @State private var isExpanded: Bool = false
    @State private var height: CGFloat = .zero

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    
                    UniversalLabelView(html: text, dynamicHeight: $height) { url in
                        openURL(url)
                    }
                    .textFontSize(16)
                    .textColor(.darkGray)
                    .textAlignment(.center)
                    .frame(height: isExpanded ? height : 30)

                    HStack {
                        Button {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        } label: {
                            Text(isExpanded ? readLess : readMore)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .rotationEffect(.degrees(isExpanded ? -90 : 0))
                                .foregroundColor(.black)
                        }
                        .buttonStyle(.plain)
                    }
                }
                

                Spacer()
                Button { closeAction() } label: {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .foregroundColor(.black)
                        .frame(width: 44.0, height: 44.0)
                }

            }
            .padding(.leading, 12.0)
            .padding(.vertical, 12.0)
        }
        .frame(maxWidth: .infinity)
        .background(Color.yellow)
    }
}

#if DEBUG

struct ExpandedMessageView_Previews: PreviewProvider {

    static var previews: some View {
        ExpandedMessageView(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus velit justo, maximus in augue eget, sodales iaculis magna. Donec vitae ipsum lectus. Cras finibus nunc augue, id imperdiet magna tempor nec.",
                           readMore: "Lorem ipsum",
                           readLess: "Lorem ipsum",
                           closeAction: {})
    }
}

#endif

typealias ActionBlock = (() -> Void)

extension View {

    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryReader in
                Color.clear
                    .preference(key: ViewSizePreferenceKey.self, value: geometryReader.size)
            }
        )
        .onPreferenceChange(ViewSizePreferenceKey.self, perform: onChange)
    }
    
}

struct ViewSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
