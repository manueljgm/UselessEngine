//
//  Animation.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/6/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

import SpriteKit
import Common

public typealias AnimationData = (textures: [SKTexture], rates: [UInt8], repeats: Bool)

public class Animation {
    
    public private(set) var positionIndex: Int {
        didSet {
            if !skipRender { renderFrame() }
            skipRender = false
        }
    }
    
    public private(set) var elapsed: Float {
        didSet {
            elapsed = clamp(elapsed, lower: 0.0, upper: 1.0)
        }
    }
    
    public private(set) var repeats: Bool
    public var finished: Bool {
        return positionIndex == (textures.count - 1) && elapsed >= 1.0
    }

    private let targetSprite: SKSpriteNode
    private var textures: [SKTexture]
    private var currentTexture: SKTexture {
        return textures[positionIndex]
    }
    private var rates: [Float]
    private var currentRate: Float {
        return rates[positionIndex]
    }
    
    private var skipRender = false
    
    private static var inited = 0
    
    public init(targetSprite: SKSpriteNode, headFrame: (texture: SKTexture, rate: UInt8), repeats: Bool) {
        positionIndex = 0
        elapsed = 0.0
        self.repeats = repeats

        self.targetSprite = targetSprite
        textures = [headFrame.texture]
        rates = [Float(headFrame.rate)]
        
        renderFrame()
        
        Animation.inited += 1
    }
    
    public init(targetSprite: SKSpriteNode, textures: [SKTexture], rates: [UInt8], repeats: Bool) {
        positionIndex = 0
        elapsed = 0.0
        self.repeats = repeats

        self.targetSprite = targetSprite
        self.textures = textures.count > 0 ? textures : [SKTexture()]
        
        // init frame rates array to length of frames array
        self.rates = Array(repeating: Float(Settings.defaults.graphics.animationFrameRate), count: textures.count)
        if rates.count > 0 {
            for i in 0...min(rates.count, textures.count)-1 {
                // overwrite frame rate values with provided frame rate values
                self.rates[i] = Float(rates[i])
            }
        }

        renderFrame()

        Animation.inited += 1
    }
    
    public convenience init(targetSprite: SKSpriteNode, headFrameTexture: SKTexture, repeats: Bool) {
        self.init(targetSprite: targetSprite, headFrame: (texture: headFrameTexture, rate: Settings.defaults.graphics.animationFrameRate), repeats: repeats)
    }
    
    public convenience init(targetSprite: SKSpriteNode, textures: [SKTexture], repeats: Bool) {
        self.init(targetSprite: targetSprite, textures: textures, rates: [], repeats: repeats)
    }
    
    public convenience init(targetSprite: SKSpriteNode, frames: AnimationData) {
        self.init(targetSprite: targetSprite, textures: frames.textures, rates: frames.rates, repeats: frames.repeats)
    }
    
    deinit {
        Animation.inited -= 1
        #if DEBUG_VERBOSE
        print(String(format: "Animation:deinit; %d remain", Animation.inited))
        #endif
    }
    
    public func addFrame(withTexture texture: SKTexture, rate: UInt8 = 0) {
        textures.append(texture)
        rates.append(Float(rate > 0 ? rate : Settings.defaults.graphics.animationFrameRate))
    }

    public func renderFrame() {
        targetSprite.texture = currentTexture
        targetSprite.size = currentTexture.size()
    }
    
    public func update(_ dt: Float) {
        guard elapsed < 1.0 else {
            return
        }

        elapsed += currentRate * dt
        if elapsed >= 1.0 { // TODO: consider distributing the remaining dt onto subsequent frames
            if positionIndex == (textures.count - 1) {
                if repeats {
                    positionIndex = 0
                    // TODO: confirm that the loop behavior is correct
                } else {
                    return
                }
            } else {
                positionIndex += 1
            }
            
            elapsed = 0.0
        }
    }
    
    public func setFrame(toIndex newPosition: Int, elapsed newElapsed: Float = 0.0, andRender render: Bool) {
        guard newPosition < textures.count else {
            return
        }
        skipRender = !render
        positionIndex = max(newPosition, 0)
        elapsed = max(newElapsed, 0.0)
    }
    
    public func reset(andRenderFrame render: Bool = true) {
        skipRender = !render
        positionIndex = 0
        elapsed = 0.0
    }
    
}
