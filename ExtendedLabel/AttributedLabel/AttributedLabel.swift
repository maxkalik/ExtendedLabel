//  Copyright © 2021 AS "Citadele Banka". All rights reserved.

import UIKit

protocol AttributedLabelDelegate: AnyObject {
    func attributedLabelLinkDidPress(url: URL?)
}

class AttributedLabel: UILabel {
    weak var delegate: AttributedLabelDelegate?
    private var tapGesture = UITapGestureRecognizer()
    private var links: [AttributedLabelLink] = []

    var textFontSize: CGFloat = 13
    var linkColor: UIColor = UIColor.blue
    var action: ((URL?) -> Void)?

    var html: String? {
        didSet {

            guard let string = html else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                if let data = string.data(using: String.Encoding.unicode),
                   let attributedString = try? NSAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil
                   ) {

                    var attributedLabelLinks: [AttributedTextWithLink] = []

                    attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { (attributes, range, _) in
                        let string = attributedString.attributedSubstring(from: range).string

                        guard let font: UIFont = attributes[NSAttributedString.Key.font] as? UIFont else { return }

                        let defaultFont: UIFont

                        if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                            defaultFont = UIFont.italicSystemFont(ofSize: self.textFontSize)
                        } else {
                            defaultFont = UIFont.systemFont(ofSize: self.textFontSize, weight: font.weight)
                        }

                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = self.textAlignment
                        
                        let defaultAttributes: [NSAttributedString.Key: Any] = [
                            .font: defaultFont,
                            .paragraphStyle: paragraphStyle
                        ]

                        var linkAttributes = defaultAttributes
                        linkAttributes[.foregroundColor] = self.linkColor

                        var linkActiveAttributes = defaultAttributes
                        linkActiveAttributes[.foregroundColor] = self.linkColor.withAlphaComponent(0.6)

                        if let link = attributes[.link], let url = link as? URL {
                            let attributedLink = AttributedTextWithLink(
                                text: string,
                                attributes: [:],
                                link: url.absoluteString,
                                linkAttributes: LinkAttributes(
                                    attributes: linkAttributes,
                                    activeAttributes: linkActiveAttributes,
                                    inactiveAttributes: linkAttributes
                                )
                            )
                            attributedLabelLinks.append(attributedLink)
                        } else {
                            var defaultTextAttributes = defaultAttributes
                            defaultTextAttributes[.foregroundColor] = self.textColor

                            if let _ = attributes[NSAttributedString.Key.underlineStyle] as? Int {
                                defaultTextAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                            }

                            let text = AttributedTextWithLink(text: string, attributes: defaultTextAttributes)
                            attributedLabelLinks.append(text)
                        }
                    }

                    AttributedTextHelper.concat(textsWithLinks: attributedLabelLinks, on: self)
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCommon()
    }

    func onPress(action: @escaping (URL?) -> Void) {
        self.action = action
    }
}

// MARK: - Add Link

extension AttributedLabel {
    func addLink(_ linkAttributes: AttributedLabelLink) {
        guard let attributedString = self.attributedText else { return }
        let attributedText = NSMutableAttributedString(attributedString: attributedString)
        attributedText.addAttributes(linkAttributes.attributes, range: linkAttributes.textCheckingResult.range)
        self.attributedText = attributedText
        links.append(linkAttributes)
    }
}

// MARK: - Setup

private extension AttributedLabel {
    func setupCommon() {
        isUserInteractionEnabled = true
        setupTapGestureRecognizer()
    }

    func setupTapGestureRecognizer() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    func setupAttributes(of link: AttributedLabelLink) {
        guard let attributedString = self.attributedText else { return }
        let attributedText = NSMutableAttributedString(attributedString: attributedString)
        attributedText.addAttributes(link.attributes, range: link.textCheckingResult.range)
        self.attributedText = attributedText
    }

    func setupActiveAttributes(of link: AttributedLabelLink) {
        guard let attributedString = self.attributedText else { return }
        let attributedText = NSMutableAttributedString(attributedString: attributedString)
        attributedText.addAttributes(link.activeAttributes, range: link.textCheckingResult.range)
        self.attributedText = attributedText
    }
}

private extension AttributedLabel {
    @objc func onTap(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        guard let link = getLinkAtPoint(touchPoint) else { return }
        let url = link.textCheckingResult.url
        delegate?.attributedLabelLinkDidPress(url: url)
        action?(url)
    }

    func getLinkAtPoint(_ point: CGPoint) -> AttributedLabelLink? {
        let index = indexOfAttributedTextCharacterAtPoint(point)
        return links.first { NSLocationInRange(index, $0.textCheckingResult.range) == true }
    }

    func containLinkAtPoint(_ point: CGPoint) -> Bool {
        let index = indexOfAttributedTextCharacterAtPoint(point)
        return links.contains { NSLocationInRange(index, $0.textCheckingResult.range) }
    }

    func indexOfAttributedTextCharacterAtPoint(_ point: CGPoint) -> Int {
        guard let attributedString = self.attributedText else { return -1 }

        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

// MARK: - UIGestureRecognizerDelegate

extension AttributedLabel: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        containLinkAtPoint(touch.location(in: self))
    }
}

// MARK: - Touches

extension AttributedLabel {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self),
              let link = getLinkAtPoint(touchPoint) else { return }
        setupActiveAttributes(of: link)
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self),
              let link = getLinkAtPoint(touchPoint) else { return }
        setupAttributes(of: link)
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self),
              let link = getLinkAtPoint(touchPoint) else { return }
        setupAttributes(of: link)
        super.touchesCancelled(touches, with: event)
    }
}

