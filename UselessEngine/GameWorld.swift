//
//  GameWorld.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/15/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import UselessCommon

public class GameWorld {
    
    public weak var delegate: GameWorldDelegate? {
        didSet {
            // update delegate with world's tiles and objects
            terrain.tiles.forEach {
                delegate?.gameWorld(self, added: $0)
            }
            inhabitants.forEach {
                delegate?.gameWorld(self, added: $0)
            }
            extras.forEach {
                delegate?.gameWorld(self, added: $0)
            }
        }
    }
    
    public var isPaused: Bool
    public var gravity: Float
    public private(set) var size: (width: Float, height: Float)

    public let terrain: GameWorldTerrain
    public let pathGraph: GameWorldGraph?
    public let collisionGrid: GameWorldCollisionGrid
    
    private let collisionDelegate: GameWorldCollisionDelegate
    
    private var entering: Set<GameWorldMember>
    private var inhabitants: Set<GameObject>
    private var extras: Set<GameWorldMember>
    private var exiting: Set<GameWorldMember>

    // MARK: - Init
    
    /// Initializes a game world.
    public init(gravity: Float,
                tileSize: Vector2d,
                collisionCellSize: Vector2d,
                collisionDelegate: GameWorldCollisionDelegate,
                pathGraphDelegate: GameWorldGraphDelegate? = nil) {
        
        self.isPaused = false
        self.gravity = gravity
        self.size = (.zero, .zero)
        
        self.entering = []
        self.terrain = GameWorldTerrain(tileSize: tileSize)
        self.inhabitants = []
        self.extras = []
        self.exiting = []

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

    public func update(_ dt: Float, matchCriteria: (GameObject) -> Bool = { _ in return true }) {
        if isPaused {
            return
        }

        // update terrain
        terrain.update(dt: dt)

        // update extras
        extras.forEach {
            let _ = $0.update(dt)
        }

        // update all game objects
        inhabitants.forEach { gameObject in
            // match the game object
            guard matchCriteria(gameObject) else {
                return
            }
            
            // update the game object
            let changesObserved = gameObject.update(dt)

            // if the object's position changed, check and resolve for boundaries or collisions
            if changesObserved.contains(.position) {
                // update the collision grid for position changes
                collisionGrid.update(for: gameObject)

                // resolve any collisions
                collisionGrid.onNeighbors(of: gameObject) { otherObject in
                    // check for a hit
                    if let hit = collisionDelegate.intersect(gameObject, with: otherObject) {
                        // a hit is detected so if contactable,
                        // handle the contact
                        if collisionDelegate.isGameObject(gameObject, contactableWith: otherObject) {
                            // call event handlers
                            gameObject.state?.handleContact(between: gameObject, and: otherObject)
                            otherObject.state?.handleContact(between: otherObject, and: gameObject)
                        }
                        // and if collidable, handle collision
                        if collisionDelegate.isGameObject(gameObject, collidableWith: otherObject) {
                            // resolve the collision by correcting positions
                            let corrections = collisionDelegate.resolveCollision(on: gameObject, against: otherObject, for: hit)
                            // then call event handlers
                            gameObject.state?.handleCollision(between: gameObject,
                                                              and: otherObject,
                                                              withCorrection: corrections.thisCorrection)
                            otherObject.state?.handleCollision(between: otherObject,
                                                               and: gameObject,
                                                               withCorrection: corrections.otherCorrection)
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

        // process exiting members
        processExiting()

        // process entering members
        processEntering()
    }
    
    public func add(member: GameWorldMember) {
        entering.insert(member)
    }

    public func remove(member: GameWorldMember) {
        exiting.insert(member)
    }
    
    // MARK: - Private Methods
    
    // MARK: World Member Management
    
    private func add(gameTile: GameTile) {
        // add the tile to this world's terrain
        terrain.add(tile: gameTile)

        // update all inhabitants for any elevation changes (there must be a more efficient way)
        inhabitants.forEach {
            let elevationAtPosition = terrain.elevation(at: $0.position)
            if $0.position.z < elevationAtPosition {
                // prevent premature notifications
                $0.remove(observer: self)
                $0.position.z = elevationAtPosition
                $0.add(observer: self)
            }
        }
            
        size.width = max(size.width, gameTile.position.x + gameTile.size.width)
        size.height = max(size.height, gameTile.position.y + gameTile.size.height)
    }
    
    private func add(gameObject: GameObject) {
        // elevate the object if set below floor
        gameObject.position.z = max(gameObject.position.z, terrain.elevation(at: gameObject.position))

        // add the object to this world's list of inhabitants
        inhabitants.insert(gameObject)
        
        // update the collision grid
        collisionGrid.update(for: gameObject)

        // subscribe to the object's notifications
        gameObject.add(observer: self)
    }
    
    private func processEntering() {
        while let newMember = entering.popFirst() {
            switch newMember {
            case let tile as GameTile:
                add(gameTile: tile)
            case let object as GameObject:
                add(gameObject: object)
            default:
                extras.insert(newMember)
            }
            
            newMember.world = self
            
            delegate?.gameWorld(self, added: newMember)
            
            #if DEBUG_VERBOSE
            let message: String
            switch newMember {
            case is GameTile:
                message = String(format: "GameTile added to GameWorld at (x: %.2f, y: %.2f)", newMember.position.x, newMember.position.y)
            default:
                message = String(format: "GameWorldMember added to GameWorld at (x: %.2f, y: %.2f, z: %.2f)", newMember.position.x, newMember.position.y, newMember.position.z)
            }
            print(message)
            #endif
        }
    }
    
    private func processExiting() {
        while let exitingMember = exiting.popFirst() {
            switch exitingMember {
            case is GameTile:
                fatalError("Tile removal has not been implemented yet.")
                // TODO: implement
            case let object as GameObject:
                // unsubscribe from the object's notifications
                object.remove(observer: self)
                // remove the object from this world
                collisionGrid.remove(object)
                inhabitants.remove(object)
                entering.remove(object)
            default:
                extras.remove(exitingMember)
            }
    
            exitingMember.world = nil
            
            delegate?.gameWorld(self, removed: exitingMember)
        }
    }

}

extension GameWorld: GameWorldMemberObserver {
    
    public func receive(event: GameWorldMemberEvent, from sender: GameWorldMember, payload: Any?) {
        delegate?.receive(event: event, from: sender, payload: payload)
    }
    
}
