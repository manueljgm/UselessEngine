//
//  PhysicsWorld.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/15/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public class GameWorld
{
    public var gravity: Float {
        return delegate.gravity
    }

    public var grid: [UnitPosition: GameWorldGridNode]
    public private(set) var objects: ContiguousArray<GameEntity>
    
    private let delegate: GameWorldDelegate

    private let collisionGrid: GameWorldCollisionGrid
    private let collisionDelegate: GameWorldCollisionDelegate
    
    private let pathfindingDelegate: GameWorldPathfindingDelegate
    
    /// Initializes a game world.
    public init(worldDelegate: GameWorldDelegate,
                collisionCellSize: Vector2d,
                collisionDelegate: GameWorldCollisionDelegate,
                pathfindingDelegate: GameWorldPathfindingDelegate)
    {
        self.collisionGrid = GameWorldCollisionGrid(cellSize: collisionCellSize)
        
        self.grid = [:]
        
        self.objects = []
        
        self.delegate = worldDelegate
        self.collisionDelegate = collisionDelegate
        self.pathfindingDelegate = pathfindingDelegate
        
        #if DEBUG_VERBOSE
        print("GameWorld:init")
        #endif
    }

    deinit {
        #if DEBUG_VERBOSE
        print("GameWorld:deinit")
        #endif
    }
    
    public func add(gridNode: GameWorldGridNode)
    {
        // add tile node reference to grid
        grid[gridNode.position] = gridNode
        
        let u = grid[UnitPosition(x: gridNode.position.x, y: gridNode.position.y+1)]
        let d = grid[UnitPosition(x: gridNode.position.x, y: gridNode.position.y-1)]
        let l = grid[UnitPosition(x: gridNode.position.x-1, y: gridNode.position.y)]
        let r = grid[UnitPosition(x: gridNode.position.x+1, y: gridNode.position.y)]
        
        gridNode.up = u
        gridNode.down = d
        gridNode.left = l
        gridNode.right = r

        u?.down = gridNode
        d?.up = gridNode
        l?.right = gridNode
        r?.left = gridNode
        
        // add tile node to objects list
        objects.append(gridNode.tile)
        
        #if DEBUG_VERBOSE
        print("GameTile added to GameWorld.")
        #endif
    }

    public func add(gameObject: GameObject)
    {
        objects.append(gameObject)

        // update the collision grid with this object
        collisionGrid.update(for: gameObject, collisionBox: { $0.physics?.collisionDelegate?.contactAABB })
        
        #if DEBUG_VERBOSE
        print("GameObject added to GameWorld.")
        #endif
    }
    
    public func update(_ dt: Float) // TODO: get viewport, update "up to" viewport
    {
        // update all world objects
        let movingObjects: [GameObject] = objects.compactMap { worldObject in
            // update world object
            let observedChanges = worldObject.update(dt, in: self)
            if observedChanges.contains(.position) {
                // if the object's position changed...
                if let gameObject = worldObject as? GameObject {
                    // keep game object within the world's boundaries
                    collisionDelegate.resolveBoundaries(on: gameObject, in: self)
                    collisionGrid.update(for: gameObject, collisionBox: { $0.physics?.collisionDelegate?.contactAABB })
                    // and return the game object
                    return gameObject
                }
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
                    || movingObjectCollisionDelegate.collisionBitmask.contains(otherObjectCollisionDelegate.categoryBitmask)
                {
                    // resolve potential collision
                    if let hit = movingObjectCollisionDelegate.contactAABB.intersect(otherObjectCollisionDelegate.contactAABB),
                       let corrections = collisionDelegate.resolveCollision(on: movingObject, against: otherObject, for: hit)
                    {
                        // call event handlers
                        movingObjectCollisionDelegate.handleCollision(between: movingObject, and: otherObject, withCorrection: corrections.thisCorrection)
                        otherObjectCollisionDelegate.handleCollision(between: otherObject, and: movingObject, withCorrection: corrections.otherCorrection)

                        // update collision grid
                        collisionGrid.update(for: movingObject, collisionBox: { $0.physics?.collisionDelegate?.contactAABB })
                        collisionGrid.update(for: otherObject, collisionBox: { $0.physics?.collisionDelegate?.contactAABB })
                    }
                }
            }
        }
    }
    
    public func gridPosition(from position: PlaneCoordinate) -> UnitPosition
    {
        return delegate.gridPosition(from: position)
    }
    
    public func elevation(at position: PlaneCoordinate) -> Float
    {
        return delegate.elevation(at: position, in: self)
    }
    
    public func path(from start: UnitPosition, to goal: UnitPosition) -> [UnitPosition]
    {
        return pathfindingDelegate.path(from: start, to: goal, in: grid)
    }

}
