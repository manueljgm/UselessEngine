//
//  PhysicsWorld.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/15/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public class GameWorld
{
    public var gravity: Float
    public private(set) var size: (width: Float, height: Float)
    public private(set) var objects: [GameObject]
    public private(set) var terrain: GameWorldTerrain
    public let collisionGrid: GameWorldCollisionGrid
    
    private let collisionDelegate: GameWorldCollisionDelegate

    /// Initializes a game world.
    public init(gravity: Float, tileSize: Vector2d, collisionCellSize: Vector2d, collisionDelegate: GameWorldCollisionDelegate)
    {
        self.gravity = gravity
        self.size = (.zero, .zero)
        self.objects = []
        self.terrain = GameWorldTerrain(tileSize: tileSize)

        self.collisionGrid = GameWorldCollisionGrid(cellSize: collisionCellSize)
        self.collisionDelegate = collisionDelegate

        #if DEBUG_VERBOSE
        print("GameWorld:init")
        #endif
    }

    deinit {
        #if DEBUG_VERBOSE
        print("GameWorld:deinit")
        #endif
    }

    public func add(gameTile: GameTile) -> Bool
    {
        let success = terrain.add(tile: gameTile)
        if success {
            size.width = max(size.width, gameTile.position.x + gameTile.size.width)
            size.height = max(size.height, gameTile.position.y + gameTile.size.height)
            #if DEBUG_VERBOSE
            print("GameTile added to GameWorld.")
            #endif
        }
        
        return success
    }

    public func add(gameObject: GameObject)
    {
        objects.append(gameObject)

        // update the collision grid with this object
        collisionGrid.update(for: gameObject)
        
        #if DEBUG_VERBOSE
        print(String(format: "GameObject added to GameWorld at (x: %.2f, y: %.2f, z: %.2f).", gameObject.position.x, gameObject.position.y, gameObject.position.z))
        #endif
    }
    
    public func update(_ dt: Float)
    {
        // update all game objects
        let movingObjects: [GameObject] = objects.compactMap { gameObject in
            // update world object
            let observedChanges = gameObject.update(dt, in: self)
            // and if the object's position changed...
            if observedChanges.contains(.position) {
                // keep game object within the world's boundaries
                collisionDelegate.resolveBoundaries(on: gameObject, in: self)
                collisionGrid.update(for: gameObject)
                // and return the game object
                return gameObject
            }
            // if here, the object did not move
            return nil
        }
        
        // resolve any collisions
        movingObjects.forEach { movingObject in
            collisionGrid.onNeighbors(of: movingObject) { otherObject in
                
                guard let movingObjectPhysics = movingObject.physics,
                      let movingObjectCollisionDelegate = movingObjectPhysics.collisionDelegate,
                      let otherObjectPhysics = otherObject.physics,
                      let otherObjectCollisionDelegate = otherObjectPhysics.collisionDelegate
                else {
                    return
                }

                if otherObjectCollisionDelegate.collisionBitmask.contains(movingObjectCollisionDelegate.categoryBitmask)
                    && movingObjectCollisionDelegate.collisionBitmask.contains(otherObjectCollisionDelegate.categoryBitmask)
                {
                    // resolve potential collision
                    if let hit = movingObjectCollisionDelegate.contactAABB.intersect(otherObjectCollisionDelegate.contactAABB),
                       let corrections = collisionDelegate.resolveCollision(on: movingObject, against: otherObject, for: hit)
                    {
                        // call event handlers
                        movingObjectCollisionDelegate.handleCollision(between: movingObject, and: otherObject, withCorrection: corrections.thisCorrection)
                        otherObjectCollisionDelegate.handleCollision(between: otherObject, and: movingObject, withCorrection: corrections.otherCorrection)

                        // update collision grid
                        collisionGrid.update(for: movingObject)
                        collisionGrid.update(for: otherObject)
                    }
                }
            }
        }
        
        // update terrain
        terrain.update(dt: dt, in: self)
    }

    public func elevation(at point: PlaneCoordinate) -> Float
    {
        return terrain.elevation(at: point)
    }

}
