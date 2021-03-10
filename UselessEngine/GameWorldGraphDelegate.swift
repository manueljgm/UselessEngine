//
//  GameWorldGraphDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 3/8/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameWorldGraphDelegate {
    
    func cost(from origin: GameWorldGraphNode, to destination: GameWorldGraphNode) -> Float
    func heuristic(from origin: GameWorldGraphNode, to goal: GameWorldGraphNode) -> Float

}
