//  Created by Maksim Kalik on 26/05/2022.

import UIKit
import SwiftUI

let text = "I am informed that my personal data is being processed for the issuance and servicing of a payment card, communication in connection with the mentioned service (s), for receiving commissions and other payments, for fulfillment of the obligations specified in the agreement, providing that my rights are exercised in accordance with the Privacy Protection Rules."

struct UniversalLabelView: UIViewRepresentable {
    private(set) var html: String
    @Binding var dynamicHeight: CGFloat
    var action: ((URL) -> Void)
    
    var mutatingWrapper = MutatingWrapper()
    class MutatingWrapper {
        var fontSize: CGFloat = 13
        var textAlignment: NSTextAlignment = .left
        var numberOfLines: Int = 0
        var textColor: UIColor = .black
        var linkColor: UIColor = .blue
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UniversalLabel {
        let label = UniversalLabel()
        label.isUserInteractionEnabled = true

        label.numberOfLines = mutatingWrapper.numberOfLines
        label.textFontSize = mutatingWrapper.fontSize
        label.textAlignment = mutatingWrapper.textAlignment
        label.textColor = mutatingWrapper.textColor
        label.linkColor = mutatingWrapper.linkColor
        label.lineBreakMode = .byWordWrapping
        
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        label.onPress { url in
            guard let url = url else { return }
            action(url)
        }

        return label
    }

    func updateUIView(_ uiView: UniversalLabel, context: UIViewRepresentableContext<Self>) {
        uiView.html = html
        uiView.numberOfLines = mutatingWrapper.numberOfLines

        DispatchQueue.main.async {
            dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
        }
    }
    
    func textFontSize(_ fontSize: CGFloat) -> Self {
        mutatingWrapper.fontSize = fontSize
        return self
    }
    
    func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        mutatingWrapper.textAlignment = textAlignment
        return self
    }
    
    func textColor(_ textColor: UIColor) -> Self {
        mutatingWrapper.textColor = textColor
        return self
    }
    
    func linkColor(_ linkColor: UIColor) -> Self {
        mutatingWrapper.linkColor = linkColor
        return self
    }
    
    
    func lineLimit(_ number: Int) -> Self {
        mutatingWrapper.numberOfLines = number
        return self
    }
}

