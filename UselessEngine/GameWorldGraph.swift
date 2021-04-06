//
//  GameWorldGraph.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/19/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import UselessCommon

public enum GameWorldGraphError: Error {
    case GameWorldNotCompatible
}

public class GameWorldGraph {
    
    private var nodes: [UnitPosition: GameWorldGraphNode]
    private var nodeSpacing: (dx: Float, dy: Float)?
    private let delegate: GameWorldGraphDelegate
    
    public init(graphDelegate: GameWorldGraphDelegate) {
        self.nodes = [:]
        self.delegate = graphDelegate
    }
 
    public func generate(for world: GameWorld,
                  nodeSpacing: (dx: Float, dy: Float),
                  isIncluded checkCriteria: @escaping (GameObject) -> Bool = { _ in return true }) throws
    {
        guard world.size.width - nodeSpacing.dx > nodeSpacing.dx && world.size.height - nodeSpacing.dy > nodeSpacing.dy else {
            throw GameWorldGraphError.GameWorldNotCompatible
        }
        
        self.nodeSpacing = nodeSpacing
        
        let upperX = Int(floor(world.size.width / nodeSpacing.dx))
        let upperY = Int(floor(world.size.height / nodeSpacing.dy))
        
        nodes.removeAll()
        nodes.reserveCapacity(upperY+1 * upperX+1)
        for j in 0...upperY {
            for i in 0...upperX {
                let x = Float(i) * nodeSpacing.dx
                let y = Float(j) * nodeSpacing.dy
                let checkPosition = Position(x: x, y: y, z: world.elevation(at: Position2d(x: x, y: y)))
                if world.terrain.tile(at: checkPosition) != nil
                    && !world.collisionGrid.hasObject(at: checkPosition, matchCriteria: checkCriteria)
                {
                    let node = GameWorldGraphNode(graphPosition: UnitPosition(x: i, y: j),
                                                  worldPosition: checkPosition)
                    nodes[node.graphPosition] = node
                }
            }
        }
        
        let checkAndAddEdge: (GameWorldGraphNode, UnitPosition) -> Void = { thisNode, checkPosition in
            if let neighborCandidate = self.nodes[checkPosition]
            {
                if !world.collisionGrid.hasObject(between: neighborCandidate.worldPosition,
                                                  and: thisNode.worldPosition,
                                                  matchCriteria: checkCriteria)
                {
                    thisNode.add(neighbor: neighborCandidate)
                }
            }
        }
        
        nodes.keys.forEach { nodeGridPosition in
            guard let node = nodes[nodeGridPosition] else {
                return
            }
            checkAndAddEdge(node, UnitPosition(x: nodeGridPosition.x, y: nodeGridPosition.y+1)) // u
            checkAndAddEdge(node, UnitPosition(x: nodeGridPosition.x, y: nodeGridPosition.y-1)) // d
            checkAndAddEdge(node, UnitPosition(x: nodeGridPosition.x-1, y: nodeGridPosition.y)) // l
            checkAndAddEdge(node, UnitPosition(x: nodeGridPosition.x+1, y: nodeGridPosition.y)) // r
        }
    }
 
    public func path(from start: Position, to goal: Position) -> [Position]
    {
        guard let nodeSpacing = self.nodeSpacing else {
            return []
        }
        
        let startGraphPosition = UnitPosition(x: Int(round(start.x / nodeSpacing.dx)), y: Int(round(start.y / nodeSpacing.dy)))
        let goalGraphPosition = UnitPosition(x: Int(round(goal.x / nodeSpacing.dx)), y: Int(round(goal.y / nodeSpacing.dy)))
        guard let start = nodes[startGraphPosition],
              let goal = nodes[goalGraphPosition] else {
            return []
        }
        
        var frontier: PriorityQueue<(GameWorldGraphNode, Float)>
        frontier = PriorityQueue<(GameWorldGraphNode, Float)>(sort: { return $0.1 < $1.1 })
        frontier.enqueue((start, 0))
        var cameFrom = [UnitPosition: GameWorldGraphNode]()
        cameFrom[start.graphPosition] = start
        var costSoFar = [UnitPosition: Float]()
        costSoFar[start.graphPosition] = 0

        var current: GameWorldGraphNode
        while let dequeued = frontier.dequeue() {
            current = dequeued.0
            if current == goal {
                break
            }

            nodes[current.graphPosition]?.neighbors.forEach { next in
                let newCost = (costSoFar[current.graphPosition] ?? 0) + cost(from: current, to: next)
                if !costSoFar.keys.contains(next.graphPosition) || newCost < costSoFar[next.graphPosition]! {
                    costSoFar[next.graphPosition] = newCost
                    let priority = newCost + heuristic(from: current, to: next)
                    frontier.enqueue((next, priority))
                    cameFrom[next.graphPosition] = current
                }
            }
        }

        current = goal
        var path = [Position]()
        while current != start {
            path.append(current.worldPosition)
            if let cameFrom = cameFrom[current.graphPosition] {
                current = cameFrom
            } else {
                break
            }
        }

        return path.reversed()
    }
    
    public func node(at graphPosition: UnitPosition) -> GameWorldGraphNode? {
        return nodes[graphPosition]
    }
    
    // MARK: - Private Methods
    
    private func cost(from origin: GameWorldGraphNode, to destination: GameWorldGraphNode) -> Float {
        return delegate.cost(from: origin, to: destination)
    }
    
    private func heuristic(from origin: GameWorldGraphNode, to goal: GameWorldGraphNode) -> Float {
        return delegate.heuristic(from: origin, to: goal)
    }
    
}
