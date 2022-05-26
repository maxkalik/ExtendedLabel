//
//  ExtendedLabelView.swift
//  ExtendedLabel
//
//  Created by Maksim Kalik on 26/05/2022.
//

import UIKit
import SwiftUI

struct BalanceWarningAttributedLabelView: UIViewRepresentable {
    private(set) var html: String
    var action: ((URL) -> Void)

    func makeUIView(context: UIViewRepresentableContext<Self>) -> AttributedLabel {
        let label = AttributedLabel()
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.textFontSize = 13
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.onPress { url in
            guard let url = url else { return }
            action(url)
        }
        return label
    }

    func updateUIView(_ uiView: AttributedLabel, context: UIViewRepresentableContext<Self>) {
        uiView.html = html
    }
}
