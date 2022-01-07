//
//  GameWorldConfiguration.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/4/22.
//  Copyright © 2022 Useless Robot. All rights reserved.
//

import UselessCommon

public struct GameWorldConfiguration {

    public let tileSize: Vector2d
    public let collisionCellSize: Vector2d
    public let gravity: Float

    public var sunAngleInDegrees: Float {
        get {
            return _sunAngleInDegrees
        }
        set {
            _sunAngleInDegrees = clamp(newValue, lower: 0.0, upper: 180.0)
            _sunAngleInRadians = _sunAngleInDegrees * Float.pi / 180.0
        }
    }
    public var sunAngleInRadians: Float {
        get {
            return _sunAngleInRadians
        }
        set {
            _sunAngleInRadians = clamp(newValue, lower: 0.0, upper: Float.pi)
            _sunAngleInDegrees = _sunAngleInRadians * 180.0 / Float.pi
        }
    }
    
    private var _sunAngleInDegrees: Float = 90.0
    private var _sunAngleInRadians: Float = 1.5708

    public init(tileSize: Vector2d, collisionCellSize: Vector2d, gravity: Float, sunAngleInDegrees: Float) {
        self.tileSize = tileSize
        self.collisionCellSize = collisionCellSize
        
        self.gravity = gravity

        defer {
            // deferring setting this value will result in the necessary call to the sunAngleInDegrees property's set
            self.sunAngleInDegrees = sunAngleInDegrees
        }
    }
    
}
