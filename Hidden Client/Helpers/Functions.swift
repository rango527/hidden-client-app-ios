//
//  Functions.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/05.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation

func delay(_ delay: TimeInterval, _ completion: (() -> ())?) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        completion?()
    }
}
