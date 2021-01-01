//
//  GameWorldPathFindingDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/28/20.
//  Copyright © 2020 Useless Robot. All rights reserved.
//

public protocol GameWorldPathfindingDelegate {

    func path(from start: UnitPosition, to goal: UnitPosition, in grid: [UnitPosition: GameWorldGridNode]) -> [UnitPosition]
    
}
