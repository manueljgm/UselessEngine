//
//  PhysicsWorld.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/15/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import UselessCommon

public class GameWorld
{
    public weak var delegate: GameWorldDelegate?
    
    public var isPaused: Bool
    
    public var gravity: Float
    public private(set) var size: (width: Float, height: Float)
    public private(set) var objects: [GameObject]
    public private(set) var checkpoints: [Position]
    public private(set) var terrain: GameWorldTerrain
    public let collisionGrid: GameWorldCollisionGrid
    public let pathGraph: GameWorldGraph
    
    private let collisionDelegate: GameWorldCollisionDelegate

    /// Initializes a game world.
    public init(gravity: Float,
                tileSize: Vector2d,
                collisionCellSize: Vector2d,
                collisionDelegate: GameWorldCollisionDelegate,
                pathGraphDelegate: GameWorldGraphDelegate)
    {
        self.isPaused = false
        self.gravity = gravity
        self.size = (.zero, .zero)
        self.objects = []
        self.checkpoints = []
        self.terrain = GameWorldTerrain(tileSize: tileSize)

        self.collisionGrid = GameWorldCollisionGrid(cellSize: collisionCellSize)
        self.collisionDelegate = collisionDelegate

        self.pathGraph = GameWorldGraph(graphDelegate: pathGraphDelegate)

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
            
            delegate?.gameWorld(self, added: gameTile)
            
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
        
        delegate?.gameWorld(self, added: gameObject)
        
        #if DEBUG_VERBOSE
        print(String(format: "GameObject added to GameWorld at (x: %.2f, y: %.2f, z: %.2f).", gameObject.position.x, gameObject.position.y, gameObject.position.z))
        #endif
    }
    
    public func add(member: GameWorldMember)
    {
        switch member {
            case let gameTile as GameTile:
                let _ = add(gameTile: gameTile)
            case let gameObject as GameObject:
                add(gameObject: gameObject)
            default:
                break
        }
    }
    
    public func addCheckpoint(at position: Position) {
        checkpoints.append(position)
        checkpoints.sort(by: {
            if $0.x < $1.x {
                return true
            } else if $0.x > $1.x {
                return false
            } else if $0.y < $0.y { // && $0.x == $1.x
                return true
            } else {
                return false
            }
        })
    }
    
    public func remove(gameObject: GameObject) {
        collisionGrid.remove(gameObject: gameObject)
        objects.removeAll(where: { $0 == gameObject })
        delegate?.gameWorld(self, removed: gameObject)
    }
    
    public func update(_ dt: Float)
    {
        if isPaused {
            return
        }

        // set up queue to broadcast game object change notifications
        var changeNotificationQueue = [GameObject: GameWorldMemberChanges]()
        
        // update all game objects
        objects.forEach { gameObject in

            // update the game object
            let changesObserved = gameObject.update(dt, in: self)
            if changesObserved != .none {
                changeNotificationQueue[gameObject] = changesObserved
            }

            // if the object's position changed, check and resolve for boundaries or collisions
            if changesObserved.contains(.position) {
                
                // update the collision grid for position changes
                collisionGrid.update(for: gameObject)

                // resolve any collisions
                collisionGrid.onNeighbors(of: gameObject) { otherObject in
                    guard let gameObjectPhysics = gameObject.physics,
                          let gameObjectCollisionDelegate = gameObjectPhysics.collisionDelegate,
                          let otherObjectPhysics = otherObject.physics,
                          let otherObjectCollisionDelegate = otherObjectPhysics.collisionDelegate
                    else {
                        return
                    }

                    if otherObjectCollisionDelegate.collisionBitmask.contains(gameObjectCollisionDelegate.categoryBitmask)
                        && gameObjectCollisionDelegate.collisionBitmask.contains(otherObjectCollisionDelegate.categoryBitmask)
                    {
                        // resolve potential collision
                        if let hit = gameObjectCollisionDelegate.contactAABB.intersect(otherObjectCollisionDelegate.contactAABB),
                           let corrections = collisionDelegate.resolveCollision(on: gameObject, against: otherObject, for: hit)
                        {
                            // a hit occurred, so call collision handlers
                            gameObjectCollisionDelegate.handleCollision(between: gameObject,
                                                                          and: otherObject,
                                                                          withCorrection: corrections.thisCorrection,
                                                                          in: self)
                            otherObjectCollisionDelegate.handleCollision(between: otherObject,
                                                                         and: gameObject,
                                                                         withCorrection: corrections.otherCorrection,
                                                                         in: self)
                            
                            // and update the collision grid for changes
                            if corrections.thisCorrection != .zero {
                                collisionGrid.update(for: gameObject)
                                changeNotificationQueue[gameObject]?.insert(.position)
                            }
                            if corrections.otherCorrection != .zero {
                                collisionGrid.update(for: otherObject)
                                changeNotificationQueue[otherObject]?.insert(.position)
                            }
                        }
                    }
                }
            }

        }
            
        // update terrain
        terrain.update(dt: dt, in: self)
        
        // broadcast game object change events
        changeNotificationQueue.forEach {
            if $0.value != .none {
                delegate?.receive(event: .memberChange(with: $0.value), from: $0.key, payload: nil)
            }
        }
    }

    public func elevation(at point: PlaneCoordinate) -> Float
    {
        return terrain.elevation(at: point)
    }

}
