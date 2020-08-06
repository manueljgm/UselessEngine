//
//  AnimationFrame.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/5/20.
//  Copyright © 2020 Useless Robot. All rights reserved.
//

import SpriteKit

public class AnimationFrame {

    public let texture: SKTexture
    public let rate: UInt8
    
    public init(texture: SKTexture, rate: UInt8? = nil) {
        self.texture = texture
        self.rate = rate ?? Settings.defaults.graphics.animationFrameRate
    }
}
