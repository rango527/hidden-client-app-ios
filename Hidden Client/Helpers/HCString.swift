//
//  HCString.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/05.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation

extension String {
    var firstName: String {
        return String(self.split(separator: " ").first ?? "")
    }
    
    var thumbnail: String? {
        var pathComponents = self.components(separatedBy: ".")
        if pathComponents.count > 1 {
            pathComponents[pathComponents.count - 1] = "jpg"
            return pathComponents.joined(separator: ".")
        }
        return nil
    }
 
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=(),.!_?\n£$€\"'")
        return self.filter {okayChars.contains($0) }
    }

    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }

    func take(_ n: Int) -> String {
        guard n >= 0 else {
            fatalError("n should never negative")
        }
        let index = self.index(self.startIndex, offsetBy: min(n, self.count))
        return String(self[..<index])
    }

    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }

    func height(width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()

        return label.frame.height
     }
}
