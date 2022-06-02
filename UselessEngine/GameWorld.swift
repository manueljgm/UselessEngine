//
//  GameWorld.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/15/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import UselessCommon

public enum GameWorldError: Error {
    case collisionCellSizeNotGreaterThanZero
}

public class GameWorld {
    
    public weak var delegate: GameWorldDelegate? {
        didSet {
            delegateDidSet()
        }
    }
    
    public var isTimeFrozen: Bool

    public private(set) var size: (width: Float, height: Float)
    public let terrain: GameWorldTerrain
    public let collisionGrid: GameWorldCollisionGrid
    public let pathGraph: GameWorldGraph?

    public var customAttributes: [GameWorldCustomAttributeKey: Float]
    
    private var entering: Set<GameWorldMember>
    private var inhabitants: Set<GameObject>
    private var extras: Set<GameWorldMember>
    private var exiting: Set<GameWorldMember>

    // MARK: - Init
    
    /// Initializes a game world.
    public init(tileSize: Vector2d,
                collisionCellSize: Vector2d,
                collisionDelegate: GameWorldCollisionDelegate,
                pathGraphDelegate: GameWorldGraphDelegate? = nil) throws
    {
        guard collisionCellSize.dx > 0.0 && collisionCellSize.dy > 0.0 else {
            throw GameWorldError.collisionCellSizeNotGreaterThanZero
        }

        self.isTimeFrozen = false
        self.size = (.zero, .zero)
        
        self.entering = []
        self.terrain = GameWorldTerrain(tileSize: tileSize)
        self.inhabitants = []
        self.extras = []
        self.exiting = []

        self.collisionGrid = GameWorldCollisionGrid(cellSize: collisionCellSize,
                                                    delegate: collisionDelegate)

        if let pathGraphDelegate = pathGraphDelegate {
            self.pathGraph = GameWorldGraph(graphDelegate: pathGraphDelegate)
        } else {
            self.pathGraph = nil
        }

        customAttributes = [:]
        
        #if DEBUG_VERBOSE
        print("GameWorld:init")
        #endif
    }

    deinit {
        #if DEBUG_VERBOSE
        print("GameWorld:deinit")
        #endif
    }
    
    public func update(_ dt: Float, matchCriteria: (GameWorldMember) -> Bool = { _ in return true }) {
        if isTimeFrozen {
            return
        }

        // process entering and exiting members
        processMembers()
        
        // update terrain
        terrain.update(dt: dt)

        // update extras
        extras.forEach { extra in
            // match the update criteria
            guard extra.isActive || matchCriteria(extra) else {
                return
            }
            // update the extra
            extra.update(dt)
        }

        // update inhabitants
        inhabitants.forEach { gameObject in
            // match the update criteria
            guard gameObject.isActive || matchCriteria(gameObject) else {
                return
            }
            // update the game object
            gameObject.update(dt)

            // resolve any collisions
            collisionGrid.resolve(for: gameObject)
            
            delegate?.gameWorld(self, updated: gameObject)
        }
    }
    
    public func add(member: GameWorldMember) {
        entering.insert(member)
    }

    public func remove(member: GameWorldMember) {
        exiting.insert(member)
    }
    
    public func processMembers() {
        // process exiting members
        processExiting()
        
        // process entering members
        processEntering()
    }
    
    // MARK: - Private Methods
    
    // MARK: World Member Management
    
    private func lay(gameTile: GameTile) {
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
    
    private func admit(gameObject: GameObject) {
        if !gameObject.hasParent {
            // add the object to this world's list of inhabitants
            inhabitants.insert(gameObject)
        }

        // elevate the object if set below floor
        gameObject.position.z = max(gameObject.position.z, terrain.elevation(at: gameObject.position))
        
        // resolve any collisions
        collisionGrid.resolve(for: gameObject)

        // subscribe to the object's notifications
        gameObject.add(observer: self)
    }
    
    private func processEntering() {
        while let newMember = entering.popFirst() {
            if newMember.inWorld {
                // this member is already in a world so ignore it
                continue
            }
            
            switch newMember {
            case let tile as GameTile:
                lay(gameTile: tile)
            case let object as GameObject:
                admit(gameObject: object)
            default:
                extras.insert(newMember)
            }
            newMember.world = self
            newMember.children.forEach { child in
                add(member: child)
            }
            
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
                // remove from parent
                object.removeFromParent()
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
            
            exitingMember.children.forEach { child in
                remove(member: child)
            }
        }
    }
    
    private func delegateDidSet() {
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

extension GameWorld: GameWorldMemberObserver {
    
    public func receive(event: GameWorldMemberEvent, from sender: GameWorldMember, payload: Any?) {
        delegate?.receive(event: event, from: sender, payload: payload)
    }
    
}
