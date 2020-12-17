//
//  Boost.swift
//  UselessEngine
//
//  Created by Manny Martins on 7/24/20.
//  Copyright © 2020 Useless Robot. All rights reserved.
//

import UselessCommon

public class Boost {
    
    /// Represents boost velocity in m/s.
    public private(set) var velocity: Vector

    /// Represents time remaining of boost in seconds.
    public private(set) var timeout: Float // in seconds
    
    /// Represents decay amount per dt of boost velocity in m/s.
    public let decay: Float // in meters per second pet dt

    public init(velocity: Vector, timeout: Float = 0.0, decay: Float) {
        self.velocity = velocity
        self.timeout = max(timeout, 0.0)
        self.decay = min(velocity.magnitude, max(decay, Settings.defaults.physics.minimumBoostDecayValue))
    }

    public func update(_ dt: Float)
    {
        if timeout > 0.0 {
           timeout -= dt
        }
        
        if timeout < dt {
            // decay any boost if boost timeout has elapsed
            let velocityMagnitude = velocity.magnitude
            if velocityMagnitude > decay {
                let reductionFactor = (velocityMagnitude - decay) / velocityMagnitude
                velocity.dx *= reductionFactor
                velocity.dy *= reductionFactor
                velocity.dz *= reductionFactor
            } else {
                velocity = .zero
            }
        }
    }
    
}
