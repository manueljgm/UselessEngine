//
//  GameWorldDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/28/20.
//  Copyright © 2020 Useless Robot. All rights reserved.
//

public protocol GameWorldDelegate {
    
    var gravity: Float { get }
    
    func initGrid(for gameObject: GameObject, in world: GameWorld)
    func updateGrid(for gameObject: GameObject, in world: GameWorld)
    func gridPosition(from position: PlaneCoordinate) -> UnitPosition
    func elevation(at position: PlaneCoordinate, in world: GameWorld) -> Float

}
