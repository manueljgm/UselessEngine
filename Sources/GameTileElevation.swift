//
//  GameTileElevation.swift
//  UselessEngine
//
//  Created by Manny Martins on 2/3/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public protocol GameTileElevation {
    func getElevation(atPoint point: PlaneCoordinate) -> Float 
}
