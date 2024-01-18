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

    private var entering: Set<GameWorldMember>
    private var inhabitants: Set<GameObject>
    private var extras: Set<GameWorldMember>
    private var exiting: Set<GameWorldMember>

    private var customAttributes: [GameWorldCustomAttributeKey: Float]

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
    
    public func set(_ value: Float, for key: GameWorldCustomAttributeKey) {
        customAttributes[key] = value
    }
    
    public func value(for key: GameWorldCustomAttributeKey) -> Float {
        return customAttributes[key] ?? 0.0
    }
    
    public func update(_ dt: Float) {
        if isTimeFrozen {
            return
        }

        processMembers()

        // update terrain
        terrain.update(dt: dt)

        // update extras
        extras.forEach { extra in
            guard extra.isActive else {
                return
            }
            // update the extra
            extra.update(dt)
        }

        // update inhabitants
        inhabitants.forEach { gameObject in
            guard gameObject.isActive else {
                return
            }
            // update the game object
            gameObject.update(dt)
        }
    }
    
    public func add(member: GameWorldMember) {
        if let tile = member as? GameTile {
            processEntering(member: tile)
        } else {
            entering.insert(member)
        }
    }

    public func remove(member: GameWorldMember) {
        member.isActive = false
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

        // update the size of this world
        size.width = max(size.width, gameTile.position.x + gameTile.size.width)
        size.height = max(size.height, gameTile.position.y + gameTile.size.height)
    }
    
    private func admit(gameObject: GameObject) {
        delegate?.gameWorld(self, willAdd: gameObject)
        
        if !gameObject.hasParent {
            // add the object to this world's list of inhabitants
            inhabitants.insert(gameObject)
        }

        // subscribe to the object's notifications
        gameObject.add(observer: self)
        
        gameObject.isActive = true
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
    
    private func processEntering(member newMember: GameWorldMember) {
        guard !newMember.inWorld else {
            // this member is already in a world so ignore it
            return
        }
        
        switch newMember {
        case let tile as GameTile:
            lay(gameTile: tile)
        case let object as GameObject:
            admit(gameObject: object)
        default:
            extras.insert(newMember)
            newMember.isActive = true
        }
        newMember.world = self
        newMember.children.forEach { child in
            processEntering(member: child)
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
    
    private func processEntering() {
        while let newMember = entering.popFirst() {
            processEntering(member: newMember)
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
        switch event {
        case .memberUpdate:
            if let gameObject = sender as? GameObject {
                delegate?.gameWorld(self, updated: gameObject)
            }
        default:
            delegate?.receive(event: event, from: sender, payload: payload)
        }
        
    }
    
}
