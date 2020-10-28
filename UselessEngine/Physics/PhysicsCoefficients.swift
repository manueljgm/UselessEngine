//
//  PhysicsCoefficients.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/9/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public struct PhysicsCoefficients {

    /// Coefficient of friction
    public var groundCof: Float
    
    /// Air drag coefficient
    public var dragCoeff: Float
    
    /// Bounce coefficient
    public var bounceCoeff: Float
    
    public init(groundCof: Float, dragCoeff: Float, bounceCoeff: Float) {
        self.groundCof = max(groundCof, 0.0)
        self.dragCoeff = max(dragCoeff, 0.0)
        self.bounceCoeff = min(max(bounceCoeff, 0.0), 0.95)
    }
    
}
