//
//  PhysicsEvent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/29/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import Foundation

final public class PhysicsEvent {
    
    public static let positionDidChange: Event = Event(named: "positionDidChange")
    public static let velocityDidChange: Event = Event(named: "velocityDidChange")
    
}
