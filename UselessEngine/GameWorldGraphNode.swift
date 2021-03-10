//
//  GameWorldGraphNode.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/22/20.
//  Copyright © 2020 Useless Robot. All rights reserved.
//

import UselessCommon

public class GameWorldGraphNode {

    public let graphPosition: UnitPosition
    public let worldPosition: Position
    public private(set) var neighbors: [GameWorldGraphNode]
    
    public init(graphPosition: UnitPosition, worldPosition: Position) {
        self.graphPosition = graphPosition
        self.worldPosition = worldPosition
        neighbors = []
    }
    
    public func add(neighbor: GameWorldGraphNode) {
        if neighbors.contains(where: { $0 == neighbor}) {
            return
        }
        neighbors.append(neighbor)
        neighbor.neighbors.append(self)
    }
    
}

extension GameWorldGraphNode: Equatable {
    
    public static func ==(lhs: GameWorldGraphNode, rhs: GameWorldGraphNode) -> Bool {
        return lhs === rhs
    }
    
}
