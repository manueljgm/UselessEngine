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
    
    public private(set) weak var target: (any GameWorldPositionable)?
    public let targetSprite: SKSpriteNode
    
    public private(set) var positionIndex: Int {
        didSet {
            if !skipLoad { loadFrame() }
            skipLoad = false
        }
    }
    
    public private(set) var elapsed: Float
    
    public let isRepeating: Bool
    public var isFinalFrame: Bool {
        return positionIndex == (textures.count - 1)
    }
    public var isFrameElapsed: Bool {
        return (1.0 - elapsed) < Animation.epsilon
    }
    public var isFinished: Bool {
        return isFinalFrame && isFrameElapsed
    }
    
    public weak var delegate: AnimationDelegate?
    
    private var textures: [SKTexture]
    private var currentTexture: SKTexture {
        return textures[positionIndex]
    }
    private var rates: [Float]
    private var currentRate: Float {
        return rates[positionIndex]
    }
    
    private var skipLoad = false
    
    private static let epsilon: Float = 1e-6
    private static var inited = 0
    
    public convenience init(targetSprite: SKSpriteNode, frames: [AnimationFrame], repeats isRepeating: Bool) {
        self.init(target: nil, targetSprite: targetSprite, frames: frames, repeats: isRepeating)
    }
    
    public convenience init(target: any GameWorldPositionable, frames: [AnimationFrame], repeats isRepeating: Bool) {
        self.init(target: target, targetSprite: target.graphics.sprite, frames: frames, repeats: isRepeating)
    }
    
    public convenience init(target: any GameWorldPositionable, textures: [SKTexture], repeats: Bool) {
        let frames = textures.map { AnimationFrame(texture: $0) }
        self.init(target: target, frames: frames, repeats: repeats)
    }
    
    private init(target: (any GameWorldPositionable)?, targetSprite: SKSpriteNode, frames: [AnimationFrame], repeats isRepeating: Bool) {
        self.target = target
        self.targetSprite = targetSprite

        self.positionIndex = 0
        self.elapsed = 0.0
        self.isRepeating = isRepeating

        let frames = frames.count > 0 ? frames : [AnimationFrame(texture: SKTexture())]
        self.textures = frames.map { $0.texture }
        self.rates = frames.map { Float($0.rate) }

        loadFrame()

        Animation.inited += 1
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

    public func loadFrame() {
        targetSprite.texture = currentTexture
        targetSprite.size = currentTexture.size()
    }
    
    public func update(_ dt: Float) {
        if isFinished {
            // the animation is finished
            return
        }

        // increment the elapsed counter for the current frame
        elapsed += currentRate * dt
        
        if isFrameElapsed {
            if positionIndex == (textures.count - 1) {
                // the final frame has elapsed
                if isRepeating {
                    // jump back to the first frame to repeat the animation
                    positionIndex = 0
                } else {
                    // the animation has finished
                    delegate?.didFinish(animation: self)
                    return
                }
            } else {
                // the current frame has elapsed, so the frame position is advanced
                positionIndex += 1
            }
            
            // unwind the elapsed counter for the next frame
            elapsed = 0.0
        }
    }
    
    public func setFrame(toIndex newPosition: Int, elapsed newElapsed: Float = 0.0, andLoad doLoad: Bool) {
        let newPosition = clamp(newPosition, lower: 0, upper: textures.count - 1)
        skipLoad = !doLoad
        positionIndex = max(newPosition, 0)
        elapsed = max(newElapsed, 0.0)
    }
    
    public func reset(andLoadFrame doLoad: Bool = true) {
        skipLoad = !doLoad
        positionIndex = 0
        elapsed = 0.0
    }
    
}
