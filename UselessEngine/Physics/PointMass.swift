//
//  PointMass.swift
//  UselessEngine
//
//  JS version created by Orlando Roman on 1/10/16.
//  Ported to Swift by Manny Martins on 1/11/16.
//  Copyright © 2016 Useless Robot. All rights reserved.
//

public class PointMass {
    
    public let mass: Float
    public var position: Position2d
    public var velocity: Vector2d
    public var acceleration: Vector2d
    public var force: Vector2d
    
    public init(mass: Float = 1.0) {
        
        self.mass = mass
        self.position = Position2d.zero
        self.acceleration = Vector2d.zero
        self.force = Vector2d.zero
        self.velocity = Vector2d.zero
        
    }
    
    public func update(_ dt: Float) {
        
        self.acceleration = Vector2d.zero
        self.acceleration.add(b: self.force, scaled: 1.0/self.mass)
        self.velocity.add(b: self.acceleration, scaled: dt)
        self.position.add(b: self.velocity, scaled: dt)
        
    }
    
}
