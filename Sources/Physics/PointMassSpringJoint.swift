//
//  PointMassSpringJoint.swift
//  UselessEngine
//
//  JS version created by Orlando Roman on 1/10/16.
//  Ported to Swift by Manny Martins on 1/11/16.
//  Copyright © 2016 Useless Robot. All rights reserved.
//

public class PointMassSpringJoint {
    
    public let pointMassA: PointMass
    public let pointMassB: PointMass
    public let normalLength: Float
    public let k: Float

    public init(pointMassA: PointMass, pointMassB: PointMass, normalLength: Float, k: Float) {
        self.pointMassA = pointMassA
        self.pointMassB = pointMassB
        self.normalLength = max(normalLength, 0.0)
        self.k = max(k, 0.0)
    }
    
    public func update(_ dt: Float) {
        self.pointMassA.force = Vector2d.zero
        self.pointMassB.force = Vector2d.zero
        
        var v0 = Vector2d.zero
        v0.add(bx: self.pointMassB.position.x, by: self.pointMassB.position.y)
        v0.subtract(bx: self.pointMassA.position.x, by: self.pointMassA.position.y)
        let mag = v0.magnitude
        if mag != 0.0 { // avoid division by 0
            let fm = self.k * (mag - self.normalLength);
            // if the spring is stretched,  m > normalLen so fm is positive
            // if the spring is compressed, m < normalLen so fm is negative
            
            // I want a vector in the same direction as (pA - pB), which we have in v0
            // but with magnitude fm. We already have the length (pB - pA) in m so
            // we can resize v0 to the correct length in one multiply.
            v0.scale( fm/mag );
            
            // if the spring is stretched, we want to pull pA and pB together
            // if the spring is compressed, we want to push them apart
            self.pointMassA.force.add(b: v0)
            self.pointMassB.force.add(b: v0, scaled: -1.0)
        }
    }
    
}
