//
//  Subject.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/26/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import Foundation

public protocol Subject: class {
    var observers: Observers { get }
    func broadcast(event: Event, payload: Any?)
}

extension Subject {
    public func broadcast(event: Event, payload: Any? = nil) {
        observers.receive(event: event, from: self, payload: payload)
    }
}
