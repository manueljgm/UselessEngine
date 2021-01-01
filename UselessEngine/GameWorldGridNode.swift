//
//  GameTilemapNode.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/22/20.
//  Copyright © 2020 Useless Robot. All rights reserved.
//

import UselessCommon

public protocol GameWorldGridNode: class {

    var position: UnitPosition { get }
    var tile: GameTile { get }
    var objects: [GameObject] { get set }
    var cost: Int { get set }
    
    var up: GameWorldGridNode? { get set }
    var down: GameWorldGridNode? { get set }
    var left: GameWorldGridNode? { get set }
    var right: GameWorldGridNode? { get set }
    
    var neighbors: [GameWorldGridNode] { get }
    
}

