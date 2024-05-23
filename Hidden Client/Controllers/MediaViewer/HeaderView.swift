//
//  HeaderView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/29.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: class {
    func headerView(_ headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
    func headerView(_ headerView: HeaderView, didPressCloseButton closeButton: UIButton)
}

class HeaderView: UIView {
    fileprivate(set) lazy var closeButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: MediaViewerConfig.CloseButton.text,
            attributes: MediaViewerConfig.CloseButton.textAttributes)

        let button = UIButton(type: .system)

        button.setAttributedTitle(title, for: UIControl.State())

        if let size = MediaViewerConfig.CloseButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }

        button.addTarget(self, action: #selector(closeButtonDidPress(_:)), for: .touchUpInside)

        if let image = MediaViewerConfig.CloseButton.image {
            button.setBackgroundImage(image, for: UIControl.State())
        }

        button.isHidden = !MediaViewerConfig.CloseButton.enabled

        return button
    }()

    fileprivate(set) lazy var deleteButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
          string: MediaViewerConfig.DeleteButton.text,
          attributes: MediaViewerConfig.DeleteButton.textAttributes)

        let button = UIButton(type: .system)

        button.setAttributedTitle(title, for: .normal)

        if let size = MediaViewerConfig.DeleteButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }

        button.addTarget(self, action: #selector(deleteButtonDidPress(_:)), for: .touchUpInside)

        if let image = MediaViewerConfig.DeleteButton.image {
            button.setBackgroundImage(image, for: UIControl.State())
        }

        button.isHidden = !MediaViewerConfig.DeleteButton.enabled

        return button
    }()

    weak var delegate: HeaderViewDelegate?

    // MARK: - Initializers

    init() {
    super.init(frame: CGRect.zero)

        backgroundColor = UIColor.clear

        [closeButton, deleteButton].forEach { addSubview($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions
    
    @objc func deleteButtonDidPress(_ button: UIButton) {
        delegate?.headerView(self, didPressDeleteButton: button)
    }

    @objc func closeButtonDidPress(_ button: UIButton) {
        delegate?.headerView(self, didPressCloseButton: button)
    }
}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {

    @objc func configureLayout() {
        let topPadding: CGFloat

        if #available(iOS 11, *) {
            topPadding = safeAreaInsets.top
        } else {
            topPadding = 0
        }

        closeButton.frame.origin = CGPoint(
            x: bounds.width - closeButton.frame.width - 17,
            y: topPadding
        )

        deleteButton.frame.origin = CGPoint(
            x: 17,
            y: topPadding
        )
    }
}
