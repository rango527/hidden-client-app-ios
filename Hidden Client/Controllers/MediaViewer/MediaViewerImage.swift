//
//  MediaViewerImage.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/28.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class MediaViewerImage {

    var key: ImageKey?
    var text: String
    var imageURL: String?
    var videoURL: String?
    var image: UIImage?
    var imageClosure: (() -> UIImage)?


    // MARK: - Initialization

    internal init(text: String = "") {
        self.text = text
    }

    init(image: UIImage, text: String = "", videoURL: String? = nil) {
        self.image = image
        self.text = text
        self.videoURL = videoURL
    }

    init(key: ImageKey? = nil, imageURL: String? = nil, text: String = "", videoURL: String? = nil) {
        self.key = key
        self.imageURL = imageURL
        self.text = text
        self.videoURL = videoURL
    }

    init(imageClosure: @escaping () -> UIImage, text: String = "", videoURL: String? = nil) {
        self.imageClosure = imageClosure
        self.text = text
        self.videoURL = videoURL
    }

    func addImageTo(_ imageView: UIImageView, completion: ((UIImage?) -> Void)? = nil) {
        if let image = image {
            imageView.image = image
            completion?(image)
        } else if let imageURL = imageURL {
            MediaViewerConfig.loadImage(imageView, imageURL, key, completion)
        } else if let imageClosure = imageClosure {
            let img = imageClosure()
            imageView.image = img
            completion?(img)
        } else {
            imageView.image = nil
            completion?(nil)
        }
    }
}
