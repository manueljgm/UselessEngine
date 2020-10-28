//
//  PhysicsWorld.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/15/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public class GameWorld
{
    public let gridDimensions: (width: Int, height: Int)
    public let gridSpacing: Vector2d
    public let gravity: Float // meters per second per second

    public private(set) var tiles: [UnitPosition: GameTile]
    public private(set) var objects: ContiguousArray<GameEntity>
    
    private var homeless = [GameObject]()
    
    private let collisionHandler: GameWorldCollisionHandler
    
    // MARK: - Init
    
    // Initializes a game world.
    public init(gridDimensions: (width: Int, height: Int),
                gridSpacing: Vector2d,
                gravity: Float,
                collisionHandler: GameWorldCollisionHandler)
    {
        self.gridDimensions = gridDimensions
        self.gridSpacing = gridSpacing
        self.gravity = gravity

        self.tiles = [:]
        self.objects = []
        
        self.collisionHandler = collisionHandler
        
        #if DEBUG_VERBOSE
        print("GameWorld:init")
        #endif
    }

    deinit {
        #if DEBUG_VERBOSE
        print("GameWorld:deinit")
        #endif
    }
    
    // MARK: - Object Management
    
    public func add(tile gameTile: GameTile)
    {
        let gridPosition = UnitPosition(x: Int(gameTile.position.x / gridSpacing.dx), y: Int(gameTile.position.y / gridSpacing.dy))
        
        let u = tile(atGridPosition: UnitPosition(x: gridPosition.x, y: gridPosition.y+1))
        let d = tile(atGridPosition: UnitPosition(x: gridPosition.x, y: gridPosition.y-1))
        let l = tile(atGridPosition: UnitPosition(x: gridPosition.x-1, y: gridPosition.y))
        let r = tile(atGridPosition: UnitPosition(x: gridPosition.x+1, y: gridPosition.y))
        
        u?.d = gameTile
        d?.u = gameTile
        l?.r = gameTile
        r?.l = gameTile
        
        gameTile.u = u
        gameTile.d = d
        gameTile.l = l
        gameTile.r = r
        
        tiles[gridPosition] = gameTile

        objects.append(gameTile)
        
        let pendingGameObjects = homeless
        pendingGameObjects.forEach { gameObject in
            if let tileAtPosition = tile(atPosition: gameObject.position) {
                if tileAtPosition.add(gameObject: gameObject) {
                    print("GameObject added to GameWorld after the fact.")
                    homeless.removeAll(where: { $0 == gameObject })
                }
            }
        }
    }
    
    public func add(gameObject: GameObject)
    {
        if !objects.contains(where: {
                                if let comparable = $0 as? GameObject {
                                    return gameObject == comparable
                                } else {
                                    return false
                                } })
        {
            // If not found, add game object to objects array.
            objects.append(gameObject)
        }
        
        if let tileAtPosition = tile(atPosition: gameObject.position) {
            if tileAtPosition.add(gameObject: gameObject) {
                print("GameObject added to GameWorld.")
            }
        } else {
            homeless.append(gameObject)
        }
    }

    public func tile(atGridPosition gridPosition: UnitPosition) -> GameTile? {
        return tiles[gridPosition]
    }
    
    public func tile(atPosition position: PlaneCoordinate) -> GameTile?
    {
        let gridPosition = UnitPosition(x: Int(position.x / gridSpacing.dx),
                                        y: Int(position.y / gridSpacing.dy))
        
        return tile(atGridPosition: gridPosition)
    }
    
    public func elevation(atPosition position: PlaneCoordinate) -> Float
    {
        guard let tile = tile(atPosition: position) else {
            return 0.0
        }
        
        return tile.elevation.getElevation(atPoint: position - tile.position)
    }
    
    // MARK: - Update Loop

    public func update(_ dt: Float)
    {
        objects.forEach {
            if let gameObject = $0 as? GameObject {
                let previousPosition = gameObject.position
                gameObject.update(dt)
                collisionHandler.resolveCollisions(onGameObject: gameObject, in: self)
                if gameObject.position != previousPosition {
                    positionDidChange(for: gameObject, from: previousPosition)
                }
            } else {
                $0.update(dt)
            }
        }
    }
    
    // MARK: - Event Handlers
    
    private func positionDidChange(for gameObject: GameObject, from previousPosition: Position)
    {
        let tileAtPreviousPosition = tile(atPosition: previousPosition)
        collisionHandler.resolveBounds(onGameObject: gameObject, previouslyAt: previousPosition, in: self)
        let tileAtCurrentPosition = tile(atPosition: gameObject.position)
        if tileAtCurrentPosition == tileAtPreviousPosition {
            return
        } else {
            tileAtPreviousPosition?.remove(gameObject: gameObject)
            let _ = tileAtCurrentPosition?.add(gameObject: gameObject)
        }
    }
    
}
