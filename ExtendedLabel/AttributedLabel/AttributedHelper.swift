//  Copyright © 2017. AS "Citadele Banka". All rights reserved.

import UIKit

struct AttributedTextWithLink {
    var text: String
    var attributes: [NSAttributedString.Key: Any]
    var link: String?
    var linkAttributes: LinkAttributes?

    init(text: String, attributes: [NSAttributedString.Key: Any]) {
        self.text = text
        self.attributes = attributes
    }

    init(
        text: String,
        attributes: [NSAttributedString.Key: Any],
        link: String,
        linkAttributes: LinkAttributes?) {

        self.text = text
        self.attributes = attributes
        self.link = link
        self.linkAttributes = linkAttributes
    }
}

struct LinkAttributes {
    var attributes: [NSAttributedString.Key: Any]
    var activeAttributes: [NSAttributedString.Key: Any]
    var inactiveAttributes: [NSAttributedString.Key: Any]
}

struct UniversalLabelLink {
    var attributes: [NSAttributedString.Key: Any]
    var activeAttributes: [NSAttributedString.Key: Any]
    var inactiveAttributes: [NSAttributedString.Key: Any]
    var textCheckingResult: NSTextCheckingResult

    init(
        attributes: [NSAttributedString.Key: Any],
        activeAttributes: [NSAttributedString.Key: Any],
        inactiveAttributes: [NSAttributedString.Key: Any],
        textCheckingResult: NSTextCheckingResult
    ) {
        self.attributes = attributes
        self.activeAttributes = activeAttributes
        self.inactiveAttributes = inactiveAttributes
        self.textCheckingResult = textCheckingResult
    }

    // Regular
    init(
        attributes: [NSAttributedString.Key: Any],
        textCheckingResult: NSTextCheckingResult
    ) {
        self.attributes = attributes
        self.activeAttributes = attributes
        self.inactiveAttributes = attributes
        self.textCheckingResult = textCheckingResult
    }
}

final class AttributedTextHelper {

    class func concat(textsWithLinks: [AttributedTextWithLink], on label: UniversalLabel) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedText = NSMutableAttributedString(string: "", attributes: [.paragraphStyle : paragraphStyle])
        var labelLinks = [UniversalLabelLink]()

        textsWithLinks.forEach {
            attributedText.append(NSAttributedString(
                string: $0.text,
                attributes: $0.attributes)
            )

            guard let link = $0.link, let url = URL(string: link) else { return }

            let range = (attributedText.string as NSString).range(of: $0.text)
            let labelLink: UniversalLabelLink

            if let linkAttributes = $0.linkAttributes {
                labelLink = UniversalLabelLink(
                    attributes: linkAttributes.attributes,
                    activeAttributes: linkAttributes.activeAttributes,
                    inactiveAttributes: linkAttributes.inactiveAttributes,
                    textCheckingResult: .linkCheckingResult(range: range, url: url)
                )
            } else {
                labelLink = UniversalLabelLink(
                    attributes: $0.attributes,
                    textCheckingResult: .linkCheckingResult(range: range, url: url)
                )
            }
            labelLinks.append(labelLink)
        }

        label.attributedText = attributedText
        labelLinks.forEach { label.addLink($0) }
    }
}

public extension UIFont {
    var weight: UIFont.Weight {
        guard let weightNumber = traits[.weight] as? NSNumber else { return .regular }
        let weightRawValue = CGFloat(weightNumber.doubleValue)
        let weight = UIFont.Weight(rawValue: weightRawValue)
        return weight
    }

    private var traits: [UIFontDescriptor.TraitKey: Any] {
        fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any] ?? [:]
    }
}

extension String {
    func stripOutHtml() -> String {
        print("*****", self, self.isHtml)
        let string = self.replacingOccurrences(of: "<br>", with: "\n")
        
        
        return string.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
    
    var isHtml: Bool {
        self.range(of: "<(\"[^\"]*\"|'[^']*'|[^'\">])*>", options: .regularExpression) != nil
    }
}
