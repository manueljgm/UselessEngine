//
//  GameWorldCollisionGrid.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public class GameWorldCollisionGrid {

    private var collisionCellSize: Vector2d
    private var collisionCellPositionsByGameObjectId: [UUID: [UnitPosition]]
    private var gameObjectsByCellPosition: [UnitPosition: [GameObject]]

    init(cellSize: Vector2d) {
        self.gameObjectsByCellPosition = [:]
        self.collisionCellPositionsByGameObjectId = [:]
        self.collisionCellSize = cellSize
    }
    
    func update(for gameObject: GameObject)
    {
        if let collisionBox = gameObject.physics?.collisionDelegate?.contactAABB
        {
            let previousPositions = collisionCellPositionsByGameObjectId[gameObject.id] ?? []
            let currentPositions = gridPositions(below: collisionBox)
            
            if currentPositions != previousPositions {
                previousPositions.forEach {
                    gameObjectsByCellPosition[$0]?.removeAll(where: { $0 == gameObject })
                }
                
                currentPositions.forEach {
                    var gameObjects = gameObjectsByCellPosition[$0] ?? []
                    gameObjects.append(gameObject)
                    gameObjectsByCellPosition[$0] = gameObjects
                    // TODO: Can this be optimized?
                }
            }
            
            collisionCellPositionsByGameObjectId[gameObject.id] = currentPositions
        }
    }
    
    func remove(gameObject: GameObject) {
        collisionCellPositionsByGameObjectId[gameObject.id]?.forEach { cellPosition in
            gameObjectsByCellPosition[cellPosition]?.removeAll(where: { $0 == gameObject })
            collisionCellPositionsByGameObjectId.removeValue(forKey: gameObject.id)
        }
    }

    public func onNeighbors(of gameObject: GameObject, doAction: (GameObject) -> Void) {
        collisionCellPositionsByGameObjectId[gameObject.id]?.forEach { cellPosition in
            gameObjectsByCellPosition[cellPosition]?.forEach { otherObject in
                if otherObject != gameObject {
                    doAction(otherObject)
                }
            }
        }
    }
    
    public func hasObject(at position: Position,
                          matchCriteria match: (GameObject) -> Bool = { _ in return true }) -> Bool
    {
        let cellPosition = UnitPosition(x: Int(floor((position.x) / collisionCellSize.dx)),
                                        y: Int(floor((position.y) / collisionCellSize.dy)))

        guard let gameObjects = gameObjectsByCellPosition[cellPosition], gameObjects.count > 0 else {
            return false
        }
        
        for gameObject in gameObjects {
            if match(gameObject) {
                if let collisionBox = gameObject.physics?.collisionDelegate?.contactAABB, collisionBox.contains(position) {
                    return true
                }
            }
        }
        
        return false
    }
    
    public func nextObject(between startPosition: Position,
                           and endPosition: Position,
                           matchCriteria match: (GameObject) -> Bool = { _ in return true }) -> (object: GameObject, distance: Vector)?
    {
        let x0 = startPosition.x / collisionCellSize.dx
        let y0 = startPosition.y / collisionCellSize.dy
        let x1 = endPosition.x / collisionCellSize.dx
        let y1 = endPosition.y / collisionCellSize.dy
        
        let dx = abs(x1 - x0)
        let dy = abs(y1 - y0)

        var x = Int(floor(x0));
        var y = Int(floor(y0));

        var n = 1
        var x_inc: Int, y_inc: Int
        var error: Float

        if dx == .zero {
            x_inc = 0
            error = .infinity
        } else if x1 > x0 {
            x_inc = 1
            n += Int(floor(x1)) - x
            error = (floor(x0) + 1 - x0) * dy
        } else {
            x_inc = -1
            n += x - Int(floor(x1))
            error = (x0 - floor(x0)) * dy
        }

        if dy == 0 {
            y_inc = 0;
            error -= .infinity
        } else if y1 > y0 {
            y_inc = 1
            n += Int(floor(y1)) - y
            error -= (floor(y0) + 1 - y0) * dx
        } else {
            y_inc = -1
            n += y - Int(floor(y1))
            error -= (y0 - floor(y0)) * dx
        }

        let ray = Ray(position: startPosition, direction: endPosition - startPosition)
        for _ in stride(from: n, to: 0, by: -1) {
            var nearestResult: (GameObject?, Vector) = (nil, Vector(dx: .infinity, dy: .infinity, dz: .infinity))
            gameObjectsByCellPosition[UnitPosition(x: x, y: y)]?.forEach { gameObject in
                if match(gameObject), let intersectDistance = gameObject.physics?.collisionDelegate?.contactAABB.intersect(ray, ignoringZ: true) {
                    if intersectDistance.magnitude < nearestResult.1.magnitude {
                        // store the closer match
                        nearestResult = (gameObject, intersectDistance)
                    }
                }
            }
            if nearestResult.0 != nil {
                return (nearestResult.0!, nearestResult.1)
            }

            if error > 0 {
                y += y_inc
                error -= dx
            } else {
                x += x_inc
                error += dy
            }
        }
        
        return nil
    }
    
    public func hasObject(between startPosition: Position,
                          and endPosition: Position,
                          matchCriteria match: (GameObject) -> Bool = { _ in return true }) -> Bool
    {
        return nextObject(between: startPosition, and: endPosition, matchCriteria: match) != nil
    }
    
    // MARK: - Helper Methods
    
    private func gridPositions(below boundingBox: AABB) -> [UnitPosition]
    {
        // calculate bottom left grid corner contain with padding
        let bottomLeftX = Int(floor((boundingBox.center.x - boundingBox.halfwidths.dx) / collisionCellSize.dx))
        let bottomLeftY = Int(floor((boundingBox.center.y - boundingBox.halfwidths.dy) / collisionCellSize.dy))

        // calculate top right contacted grid corner with padding
        let topRightX = Int(floor((boundingBox.center.x + boundingBox.halfwidths.dx) / collisionCellSize.dx))
        let topRightY = Int(floor((boundingBox.center.y + boundingBox.halfwidths.dy) / collisionCellSize.dy))

        var gridPositions: [UnitPosition] = []
        (bottomLeftY...topRightY).forEach { y in
            (bottomLeftX...topRightX).forEach { x in
                gridPositions.append(UnitPosition(x: x, y: y))
            }
        }

        return gridPositions
    }
    
}
