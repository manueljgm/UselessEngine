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
    private let collisionDelegate: GameWorldCollisionDelegate
    private let pathfindingDelegate: GameWorldPathfindingDelegate
    
    /// Initializes a game world.
    public init(worldDelegate: GameWorldDelegate,
                collisionDelegate: GameWorldCollisionDelegate,
                pathfindingDelegate: GameWorldPathfindingDelegate)
    {
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

        // update grid for game object
        delegate.initGrid(for: gameObject, in: self)
        
        #if DEBUG_VERBOSE
        print("GameObject added to GameWorld.")
        #endif
    }

    public func update(_ dt: Float)
    {
        // update all world objects
        objects.forEach { worldObject in
            // update world object
            let observedChanges = worldObject.update(dt, in: self)
            if observedChanges.contains(.position) {
                if let gameObject = worldObject as? GameObject
                {
                    // keep game object within the world's boundaries
                    collisionDelegate.resolveBoundaries(on: gameObject, in: self)
                    
                    // update grid with game object's position change
                    delegate.updateGrid(for: gameObject, in: self)
                }
            }
        }
        
        // resolve any collisions
        grid.values.forEach {
            guard $0.objects.count > 1 else {
                return
            }

            $0.objects.forEach { gameObject in
                let hitObjects = collisionDelegate.resolveCollisions(on: gameObject, in: self)
                hitObjects.forEach {
                    // update grid with game object's position change
                    delegate.updateGrid(for: $0, in: self)
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
