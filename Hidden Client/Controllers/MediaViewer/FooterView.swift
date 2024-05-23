//
//  FooterView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/29.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

protocol FooterViewDelegate: class {
    func footerView(_ footerView: FooterView, didExpand expanded: Bool)
}

class FooterView: UIView {

    fileprivate(set) lazy var infoLabel: InfoLabel = { [unowned self] in
        let label = InfoLabel(text: "")
        label.isHidden = !MediaViewerConfig.InfoLabel.enabled

        label.textColor = MediaViewerConfig.InfoLabel.textColor
        label.isUserInteractionEnabled = true
        label.delegate = self

        return label
    }()

    fileprivate(set) lazy var pageLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: CGRect.zero)
        label.isHidden = !MediaViewerConfig.PageIndicator.enabled
        label.numberOfLines = 1

        return label
    }()

    fileprivate(set) lazy var separatorView: UIView = { [unowned self] in
        let view = UILabel(frame: CGRect.zero)
        view.isHidden = !MediaViewerConfig.PageIndicator.enabled
        view.backgroundColor = MediaViewerConfig.PageIndicator.separatorColor

        return view
    }()
  
    let gradientColors = [UIColor.colorFrom(rgb: 0x040404, alpha: 0.1), UIColor.colorFrom(rgb: 0x040404)]
    weak var delegate: FooterViewDelegate?

    // MARK: - Initializers

    init() {
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.clear
        _ = addGradientLayer(gradientColors)

        [pageLabel, infoLabel, separatorView].forEach { addSubview($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    func expand(_ expand: Bool) {
        expand ? infoLabel.expand() : infoLabel.collapse()
    }

    func updatePage(_ page: Int, _ numberOfPages: Int) {
        let text = "\(page)/\(numberOfPages)"

        pageLabel.attributedText = NSAttributedString(string: text,
                                                      attributes: MediaViewerConfig.PageIndicator.textAttributes)
        pageLabel.sizeToFit()
    }

    func updateText(_ text: String) {
        infoLabel.fullText = text

        if text.isEmpty {
            _ = removeGradientLayer()
        } else if !infoLabel.expanded {
            _ = addGradientLayer(gradientColors)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let bottomPadding: CGFloat
        if #available(iOS 11, *) {
            bottomPadding = safeAreaInsets.bottom
        } else {
            bottomPadding = 0
        }

        pageLabel.frame.origin = CGPoint(
            x: (frame.width - pageLabel.frame.width) / 2,
            y: frame.height - pageLabel.frame.height - 2 - bottomPadding
        )

        separatorView.frame = CGRect(
            x: 0,
            y: pageLabel.frame.minY - 2.5,
            width: frame.width,
            height: 0.5
        )

        infoLabel.frame.origin.y = separatorView.frame.minY - infoLabel.frame.height - 15

        resizeGradientLayer()
    }
}

// MARK: - LayoutConfigurable
protocol LayoutConfigurable: class {
    func configureLayout()
}

extension FooterView: LayoutConfigurable {
    @objc func configureLayout() {
        infoLabel.frame = CGRect(x: 17, y: 0, width: frame.width - 17 * 2, height: 35)
        infoLabel.configureLayout()
    }
}

extension FooterView: InfoLabelDelegate {
    func infoLabel(_ infoLabel: InfoLabel, didExpand expanded: Bool) {
        _ = (expanded || infoLabel.fullText.isEmpty) ? removeGradientLayer() : addGradientLayer(gradientColors)
        delegate?.footerView(self, didExpand: expanded)
    }
}
