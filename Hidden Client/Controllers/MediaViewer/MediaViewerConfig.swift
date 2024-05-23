//
//  MediaViewerConfig.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/27.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MediaViewerConfig {
    static var hideStatusBar = true

    static var handleVideo: (_ from: UIViewController, _ videoURL: String) -> Void = { from, videoURL in
        guard let url = URL(string: videoURL) else { return }
        let videoController = AVPlayerViewController()
        videoController.player = AVPlayer(url: url)

        from.present(videoController, animated: true) {
            videoController.player?.play()
        }
    }

    static var loadImage: (UIImageView, String, ImageKey?, ((UIImage?) -> Void)?) -> Void = { (imageView, imageURL, key, completion) in
        imageView.hero.id = key?.name ?? "media"
        imageView.setImage(with: imageURL, key: key, completion: { (img) in
            completion?(img)
        })
    }

    static var makeLoadingIndicator: () -> UIView = {
        return LoadingIndicator()
    }

    static var preload = 0

    struct PageIndicator {
        static var enabled = true
        static var separatorColor = UIColor(hex: "3D4757")

        static var textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor(hex: "899AB8"),
            .paragraphStyle: {
                var style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
    }

    struct CloseButton {
        static var enabled = true
        static var size: CGSize?
        static var text = NSLocalizedString("Close", comment: "")
        static var image: UIImage?

        static var textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.white,
            .paragraphStyle: {
                var style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
    }

    struct DeleteButton {
        static var enabled = false
        static var size: CGSize?
        static var text = NSLocalizedString("Delete", comment: "")
        static var image: UIImage?

        static var textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor(hex: "FA2F5B"),
            .paragraphStyle: {
                var style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
    }

    struct InfoLabel {
        static var enabled = true
        static var textColor = UIColor.white
        static var ellipsisText = NSLocalizedString("Show more", comment: "")
        static var ellipsisColor = UIColor(hex: "899AB9")

        static var textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.avenirBook(14),
            .foregroundColor: UIColor(hex: "FFFFFF")
        ]
    }

    struct Zoom {
        static var minimumScale: CGFloat = 1.0
        static var maximumScale: CGFloat = 3.0
    }
}
