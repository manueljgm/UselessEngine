//
//  Observer.swift
//  UselessEngine
//
//  Created by Manny Martins on 7/30/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public protocol Observer: class {
    func receive(_ event: EngineEvent, from sender: AnyObject, payload: Any?)
}

extension Observer {
    public func receive(_ event: EngineEvent, from sender: AnyObject, payload: Any? = nil) { }
}
