//
//  Animation.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/6/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

import SpriteKit
import UselessCommon

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
    
    public init(targetSprite: SKSpriteNode, frames: [AnimationFrame], repeats: Bool)
    {
        let frames = frames.count > 0 ? frames : [AnimationFrame(texture: SKTexture())]
        
        positionIndex = 0
        elapsed = 0.0
        self.repeats = repeats

        self.targetSprite = targetSprite
        textures = frames.map { $0.texture }
        rates = frames.map { Float($0.rate) }

        renderFrame()

        Animation.inited += 1
    }
    
    public convenience init(targetSprite: SKSpriteNode, textures: [SKTexture], repeats: Bool) {
        let frames = textures.map { AnimationFrame(texture: $0) }
        self.init(targetSprite: targetSprite, frames: frames, repeats: repeats)
    }
    
    public convenience init(targetSprite: SKSpriteNode, headFrame: AnimationFrame, repeats: Bool)
    {
        self.init(targetSprite: targetSprite, frames: [headFrame], repeats: repeats)
    }
    
    public convenience init(targetSprite: SKSpriteNode, headFrameTexture: SKTexture, repeats: Bool) {
        self.init(targetSprite: targetSprite, headFrame: AnimationFrame(texture: headFrameTexture, rate: Settings.defaults.graphics.animationFrameRate), repeats: repeats)
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
