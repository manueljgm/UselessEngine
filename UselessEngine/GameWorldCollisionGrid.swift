//
//  GameWorldCollisionGrid.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public class GameWorldCollisionGrid {

    private var collisionCellSize: Vector2d
    private var collisionCellPositionsByGameObjectKey: [UUID: [UnitPosition]]
    private var gameObjectsByCellPosition: [UnitPosition: [GameObject]]

    init(cellSize: Vector2d) {
        self.gameObjectsByCellPosition = [:]
        self.collisionCellPositionsByGameObjectKey = [:]
        self.collisionCellSize = cellSize
    }
    
    func update(for gameObject: GameObject, collisionBox gameObjectCollisionBox: (GameObject) -> AABB?)
    {
        if let collisionBox = gameObjectCollisionBox(gameObject)
        {
            let previousPositions = collisionCellPositionsByGameObjectKey[gameObject.id] ?? []
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
            
            collisionCellPositionsByGameObjectKey[gameObject.id] = currentPositions
        }
    }

    public func onNeighbors(of gameObject: GameObject, doAction: (GameObject) -> Void) {
        collisionCellPositionsByGameObjectKey[gameObject.id]?.forEach { cellPosition in
            gameObjectsByCellPosition[cellPosition]?.forEach { otherObject in
                if otherObject != gameObject {
                    doAction(otherObject)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func gridPositions(below boundingBox: AABB) -> [UnitPosition]
    {
        // calculate bottom left grid corner contain with padding
        let bottomLeftX = Int(floor((boundingBox.centerPosition.x - boundingBox.halfwidths.dx) / collisionCellSize.dx))
        let bottomLeftY = Int(floor((boundingBox.centerPosition.y - boundingBox.halfwidths.dy) / collisionCellSize.dy))

        // calculate top right contacted grid corner with padding
        let topRightX = Int(floor((boundingBox.centerPosition.x + boundingBox.halfwidths.dx) / collisionCellSize.dx))
        let topRightY = Int(floor((boundingBox.centerPosition.y + boundingBox.halfwidths.dy) / collisionCellSize.dy))

        var gridPositions: [UnitPosition] = []
        (bottomLeftY...topRightY).forEach { y in
            (bottomLeftX...topRightX).forEach { x in
                gridPositions.append(UnitPosition(x: x, y: y))
            }
        }

        return gridPositions
    }
    
}
