//
//  GameWorld.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/15/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import UselessCommon

public class GameWorld {
    
    public weak var delegate: GameWorldDelegate?
    
    public var isPaused: Bool
    
    public var gravity: Float
    public private(set) var size: (width: Float, height: Float)
    public private(set) var objects: Set<GameObject>
    public private(set) var checkpoints: [Position]
    public private(set) var terrain: GameWorldTerrain
    public let collisionGrid: GameWorldCollisionGrid
    public let pathGraph: GameWorldGraph?
    
    private let collisionDelegate: GameWorldCollisionDelegate

    /// Initializes a game world.
    public init(gravity: Float,
                tileSize: Vector2d,
                collisionCellSize: Vector2d,
                collisionDelegate: GameWorldCollisionDelegate,
                pathGraphDelegate: GameWorldGraphDelegate? = nil) {
        
        self.isPaused = false
        self.gravity = gravity
        self.size = (.zero, .zero)
        self.objects = []
        self.checkpoints = []
        self.terrain = GameWorldTerrain(tileSize: tileSize)

        self.collisionGrid = GameWorldCollisionGrid(cellSize: collisionCellSize)
        self.collisionDelegate = collisionDelegate

        if let pathGraphDelegate = pathGraphDelegate {
            self.pathGraph = GameWorldGraph(graphDelegate: pathGraphDelegate)
        } else {
            self.pathGraph = nil
        }

        #if DEBUG_VERBOSE
        print("GameWorld:init")
        #endif
    }

    deinit {
        #if DEBUG_VERBOSE
        print("GameWorld:deinit")
        #endif
    }

    public func add(gameTile: GameTile) -> Bool {
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

    public func add(gameObject: GameObject) {
        // subscribe to the object's notifications
        gameObject.add(observer: self)
        
        // add the object to this world's object set
        objects.insert(gameObject)

        // update the collision grid with this object
        collisionGrid.update(for: gameObject)
        
        delegate?.gameWorld(self, added: gameObject)
        
        #if DEBUG_VERBOSE
        print(String(format: "GameObject added to GameWorld at (x: %.2f, y: %.2f, z: %.2f).", gameObject.position.x, gameObject.position.y, gameObject.position.z))
        #endif
    }
    
    public func add(member: GameWorldMember) {
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
        // remove the object from this world
        collisionGrid.remove(gameObject: gameObject)
        objects.remove(gameObject)
        
        // unsubscribe from the object's notifications
        gameObject.remove(observer: self)
        
        delegate?.gameWorld(self, removed: gameObject)
    }
    
    public func update(_ dt: Float, matchCriteria: (GameObject) -> Bool = { _ in return true })
    {
        if isPaused {
            return
        }

        // update all game objects
        objects.forEach { gameObject in
            // match the game object
            guard matchCriteria(gameObject) else {
                return
            }
            
            // update the game object
            let changesObserved = gameObject.update(dt, in: self)

            // if the object's position changed, check and resolve for boundaries or collisions
            if changesObserved.contains(.position) {
                // update the collision grid for position changes
                collisionGrid.update(for: gameObject)

                // resolve any collisions
                collisionGrid.onNeighbors(of: gameObject) { otherObject in
                    // check for a hit
                    if let hit = gameObject.physics.collision.contactAABB
                        .intersect(otherObject.physics.collision.contactAABB) {
                        // a hit is detected so if contactable,
                        // handle the contact
                        if collisionDelegate.isGameObject(gameObject, contactableWith: otherObject) {
                            // call event handlers
                            gameObject.state?.handleContact(between: gameObject, and: otherObject, in: self)
                            otherObject.state?.handleContact(between: otherObject, and: gameObject, in: self)
                        }
                        // and if collidable, handle collision
                        if collisionDelegate.isGameObject(gameObject, collidableWith: otherObject) {
                            // resolve the collision by correcting positions
                            let corrections = collisionDelegate.resolveCollision(on: gameObject, against: otherObject, for: hit)
                            // then call event handlers
                            gameObject.state?.handleCollision(between: gameObject,
                                                                          and: otherObject,
                                                                          withCorrection: corrections.thisCorrection,
                                                                          in: self)
                            otherObject.state?.handleCollision(between: otherObject,
                                                                         and: gameObject,
                                                                         withCorrection: corrections.otherCorrection,
                                                                         in: self)
                            // and update the collision grid for changes
                            if corrections.thisCorrection != .zero {
                                collisionGrid.update(for: gameObject)
                            }
                            if corrections.otherCorrection != .zero {
                                collisionGrid.update(for: otherObject)
                            }
                        }
                    }
                }
            }
        }
            
        // update terrain
        terrain.update(dt: dt, in: self)
    }

    public func elevation(at point: PlaneCoordinate) -> Float {
        return terrain.elevation(at: point)
    }
    
}

extension GameWorld: Equatable {
    
    public static func ==(lhs: GameWorld, rhs: GameWorld) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}

extension GameWorld: GameWorldMemberObserver {
    
    public func receive(event: GameWorldMemberEvent, from sender: GameWorldMember, payload: Any?) {
        delegate?.receive(event: event, from: sender, payload: payload)
    }
    
}
