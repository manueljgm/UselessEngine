//
//  Event.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/29/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public struct Event: Hashable {
    
    public let name: String

    public init(named eventName: String) {
        name = eventName
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
}

public func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.name.caseInsensitiveCompare(rhs.name) == .orderedSame
}

public func != (lhs: Event, rhs: Event) -> Bool {
    return !(lhs == rhs)
}
