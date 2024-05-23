//
//  ImageLoader.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/24.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//


import UIKit
import Kingfisher
import SwiftyGif

enum ImageKey {
    case client(String?)
    case candidate(String?)
    case candidateAvatar(String?)
    case experience(String?)
    case project(String?)
    case projectAsset(String?)
    case brand(String?)
    case message(String?)
    case company(String?)
    case companyTile(String?)
    case path(String?)
    
    var name: String {
        switch self {
        case .client(let key):
            return "client_\(key ?? "")"
        case .candidate(let key):
            return "candidate_\(key ?? "")"
        case .candidateAvatar(let key):
            return "candidate_avatar_\(key ?? "")"
        case .experience(let key):
            return "brand_\(key ?? "")"
        case .project(let key):
            return "project_\(key ?? "")"
        case .projectAsset(let key):
            return "project_asset_\(key ?? "")"
        case .brand(let key):
            return "brand_\(key ?? "")"
        case .message(let key):
            return "message_\(key ?? "")"
        case .company(let key):
            return "company_\(key ?? "")"
        case .companyTile(let key):
            return "company_tile_\(key ?? "")"
        case .path(let key):
            return key ?? ""
        }
    }


}

extension UIImage {

   static func imageWithColor(tintColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        tintColor.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)

        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(cgImage!, in: rect)

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    convenience init(withBackground color: UIColor) {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size);
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        context.setFillColor(color.cgColor);
        context.fill(rect)

        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(ciImage: CIImage(image: image)!)
    }

}

extension UIImageView {
    
    func setImage(with url: String?,
                  key: ImageKey? = nil,
                  placeholder: UIImage? = nil,
                  options: KingfisherOptionsInfo? = [.transition(ImageTransition.fade(1))],
                  completion: ((UIImage?)->())? = nil) {

        let gifManager = SwiftyGifManager(memoryLimit:100)
        self.image = nil
        
        //let key = key ?? ImageKey.path(url)
        let key = ImageKey.path(url)
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: key.name) {
            if (url?.contains(".gif"))! {
                self.setGifImage(image, manager: gifManager, loopCount: -1)
            }
            self.image = image
            completion?(image)
        }/* else if let image = ImageCache.default.retrieveImageInDiskCache(forKey: key.name) {
            self.image = image
            completion?(image)
        }*/ else {
            if let url = url, let downloadUrl =  URL(string: url){
                let resource = ImageResource(downloadURL: downloadUrl, cacheKey: key.name)
                self.kf.setImage(with: resource, placeholder: placeholder, options: options) { (result) in
                    switch result {
                    case .success(let image):
                        completion?(image.image)
                    case .failure( _):
                        completion?(nil)
                    }
                }
            } else {
                self.image = placeholder
                completion?(nil)
            }
        }
    }
}

extension UIButton {
    func setImage(with url: String?, key: ImageKey? = nil, placeholder: UIImage? = nil) {
        self.setImage(nil, for: .normal)
        //let key = key ?? ImageKey.path(url)
        let key = ImageKey.path(url)
        
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: key.name) {
            self.setImage(image, for: .normal)
        }/* else if let image = ImageCache.default.retrieveImageInDiskCache(forKey: key.name) {
            self.setImage(image, for: .normal)
        }*/ else {
            if let url = url, let downloadUrl = URL(string: url) {
                let resource = ImageResource(downloadURL: downloadUrl, cacheKey: key.name)
                self.kf.setImage(with: resource,
                                 for: .normal,
                                 placeholder: placeholder,
                                 options: [.transition(ImageTransition.fade(1))])
            } else {
                self.setImage(placeholder, for: .normal)
            }
        }
    }
}
