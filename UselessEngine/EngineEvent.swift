//
//  EngineEvent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/29/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public enum EngineEvent: Equatable
{
    case velocityChange
    case positionChange
    case eventStart(byId: UUID)
    case eventChange(byId: UUID)
    case eventEnd(byId: UUID)
}
