//
//  GameWorldCollisionGrid.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import Foundation

public class GameWorldCollisionGrid {

    public private(set) var delegate: GameWorldCollisionDelegate
    
    private var collisionCellSize: Vector2d
    
    private var gameObjectsOnCell: [UnitPosition: Set<GameObject>]
    private var lastKnownCellsBelowGameObject: [GameObject: Set<UnitPosition>]
    private var collisionChecksPerformed = [GameObject: Set<GameObject>]()
    
    private var updateFrame: Int = 0

    internal init(cellSize: Vector2d, delegate: GameWorldCollisionDelegate) {
        self.collisionCellSize = cellSize
        self.gameObjectsOnCell = [:]
        self.lastKnownCellsBelowGameObject = [:]
        self.delegate = delegate
    }
    
    public func nextObject(between startPosition: Position,
                           and endPosition: Position,
                           matchCriteria match: (GameObject) -> Bool = { _ in return true })
    -> (object: GameObject, distance: Vector)? {
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
            gameObjectsOnCell[UnitPosition(x: x, y: y)]?.forEach { candidate in
                if match(candidate), let intersectDistance = candidate.physics?.collision.contactAABB.intersect(ray, ignoringZ: true) {
                    if intersectDistance.magnitude < nearestResult.1.magnitude {
                        // store the closer match
                        nearestResult = (candidate, intersectDistance)
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
    
    public func hasObject(at position: Position,
                          matchCriteria match: (GameObject) -> Bool = { _ in return true })
    -> Bool {
        let cellPosition = UnitPosition(x: Int(floor((position.x) / collisionCellSize.dx)),
                                        y: Int(floor((position.y) / collisionCellSize.dy)))

        guard let matchCandidates = gameObjectsOnCell[cellPosition], matchCandidates.count > 0 else {
            return false
        }

        let matchFound = matchCandidates.contains { candidate in
            match(candidate) && candidate.physics?.collision.contactAABB.contains(position) ?? false
        }
        return matchFound
    }
    
    @inlinable public func hasObject(between startPosition: Position,
                          and endPosition: Position,
                          matchCriteria match: (GameObject) -> Bool = { _ in return true })
    -> Bool {
        return nextObject(between: startPosition, and: endPosition, matchCriteria: match) != nil
    }
    
    @inlinable public func isGameObject(_ gameObject: GameObject, contactableWith otherObject: GameObject) -> Bool {
        return delegate.isGameObject(gameObject, contactableWith: otherObject)
    }
    
    @inlinable public func isGameObject(_ gameObject: GameObject, collidableWith otherObject: GameObject) -> Bool {
        return delegate.isGameObject(gameObject, collidableWith: otherObject)
    }
    
    // MARK: - Helper Methods
    
    internal func worldDidAdd(gameObject: GameObject) {
        updateCellPositions(for: gameObject)
    }
    
    internal func worldDidUpdate(_ dt: Float) {
        collisionChecksPerformed = [:]
        
        updateFrame += 1
    }

    internal func resolve(for gameObject: GameObject) {
        defer {
            // refresh the update frame count for this collision check
            gameObject.updateFrame.forCollision = updateFrame
        }
        
        // ensure the object is not checked unnecessarily
        guard gameObject.contains(flags: .positionDidUpdate)
                && gameObject.updateFrame.forCollision < updateFrame else {
            return
        }
        
        // update game object's cell positions
        updateCellPositions(for: gameObject)

        // init hit tested object tracker and seed with this object to avoid a check against the self
        collisionChecksPerformed[gameObject] = [gameObject]

        // resolve any collisions
        lastKnownCellsBelowGameObject[gameObject]?.forEach { cellPosition in
            gameObjectsOnCell[cellPosition]?.forEach { neighboringObject in
                guard collisionChecksPerformed[gameObject]?.contains(neighboringObject) ?? false == false
                        && collisionChecksPerformed[neighboringObject]?.contains(gameObject) ?? false == false
                else {
                    return
                }
                
                // check for a hit
                if let hit = delegate.intersect(gameObject, with: neighboringObject) {
                    // a hit is detected so if contactable,
                    // handle the contact
                    if delegate.isGameObject(gameObject, contactableWith: neighboringObject) {
                        // call event handlers
                        gameObject.state?.handleContact(between: gameObject, and: neighboringObject)
                        neighboringObject.state?.handleContact(between: neighboringObject, and: gameObject)
                    }
                    // and if collidable, handle collision
                    if delegate.isGameObject(gameObject, collidableWith: neighboringObject) {
                        // resolve the collision by correcting positions
                        let corrections = delegate.resolveCollision(on: gameObject, against: neighboringObject, for: hit)
                        // then call event handlers
                        gameObject.state?.handleCollision(between: gameObject,
                                                          and: neighboringObject,
                                                          withCorrection: corrections.thisCorrection)
                        neighboringObject.state?.handleCollision(between: neighboringObject,
                                                                 and: gameObject,
                                                                 withCorrection: corrections.otherCorrection)
                        // and update the collision grid for changes
                        if corrections.thisCorrection != .zero {
                            updateCellPositions(for: gameObject)
                        }
                        if corrections.otherCorrection != .zero {
                            updateCellPositions(for: neighboringObject)
                        }
                    }
                }
                
                // track the check
                collisionChecksPerformed[gameObject]?.insert(neighboringObject)
            }
        }
    }
    
    internal func remove(_ gameObject: GameObject, from removedPosition: UnitPosition? = nil) {
        guard let removedPosition = removedPosition else {
            // remove game object from collision grid altogether
            lastKnownCellsBelowGameObject[gameObject]?.forEach { lastKnownCellPosition in
                gameObjectsOnCell[lastKnownCellPosition]?.remove(gameObject)
            }
            lastKnownCellsBelowGameObject.removeValue(forKey: gameObject)
            return
        }
        
        lastKnownCellsBelowGameObject[gameObject]?.remove(removedPosition)
        gameObjectsOnCell[removedPosition]?.remove(gameObject)
    }

    private func currentCellPositions(below boundingBox: AABB) -> Set<UnitPosition> {
        // calculate bottom left grid corner contain with padding
        let bottomLeftX = Int(floor((boundingBox.center.x - boundingBox.halfwidths.dx) / collisionCellSize.dx))
        let bottomLeftY = Int(floor((boundingBox.center.y - boundingBox.halfwidths.dy) / collisionCellSize.dy))

        // calculate top right contacted grid corner with padding
        let topRightX = Int(floor((boundingBox.center.x + boundingBox.halfwidths.dx) / collisionCellSize.dx))
        let topRightY = Int(floor((boundingBox.center.y + boundingBox.halfwidths.dy) / collisionCellSize.dy))

        var gridPositions: Set<UnitPosition> = []
        (bottomLeftY...topRightY).forEach { y in
            (bottomLeftX...topRightX).forEach { x in
                gridPositions.insert(UnitPosition(x: x, y: y))
            }
        }

        return gridPositions
    }
    
    private func updateCellPositions(for gameObject: GameObject) {
        guard let gameObjectPhysics = gameObject.physics else {
            return
        }
        
        let currentPositions = currentCellPositions(below: gameObjectPhysics.collision.contactAABB)
        
        let lastKnownPositions = lastKnownCellsBelowGameObject[gameObject] ?? []
        lastKnownPositions.subtracting(currentPositions).forEach { lastKnownCellPosition in
            gameObjectsOnCell[lastKnownCellPosition]?.remove(gameObject)
        }
        
        currentPositions.forEach { newCellPosition in
            if gameObjectsOnCell[newCellPosition]?.insert(gameObject) == nil {
                gameObjectsOnCell[newCellPosition] = [gameObject]
            }
        }
        
        lastKnownCellsBelowGameObject[gameObject] = currentPositions
    }
    
}
