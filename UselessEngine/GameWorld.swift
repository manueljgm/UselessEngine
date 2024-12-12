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

    // MARK: - Properties
    
    public weak var delegate: GameWorldDelegate? {
        didSet {
            delegateDidSet()
        }
    }
    
    public var isTimeFrozen: Bool = false

    public let terrain: GameWorldTerrain
    public var size: (width: Float, height: Float) = (.zero, .zero)
    public let collisionGrid: GameWorldCollisionGrid
    
    private var enteringMembers: [any GameWorldPositionable] = []
    private var updatingGameObjects: Set<GameObject> = []
    private var exitingMembers: [any GameWorldPositionable] = []

    private var customAttributes: [GameWorldCustomAttributeKey: Float] = [:]
    
    // MARK: - Init
    
    /// Initializes a game world.
    public init(tileSize: GameTileSize, collisionCellSize: Vector2d, collisionDelegate: GameWorldCollisionDelegate) throws {
        guard collisionCellSize.dx > 0.0 && collisionCellSize.dy > 0.0 else {
            throw GameWorldError.collisionCellSizeNotGreaterThanZero
        }

        terrain = GameWorldTerrain(tileSize: tileSize)
        collisionGrid = GameWorldCollisionGrid(cellSize: collisionCellSize,
                                                    delegate: collisionDelegate)
        
        #if DEBUG_VERBOSE
        print("GameWorld:init")
        #endif
    }

    deinit {
        #if DEBUG_VERBOSE
        print("GameWorld:deinit")
        #endif
    }
    
    // MARK: - Public Methods
    
    // MARK: Membership

    public func add(_ tile: GameTile) {
        // install thie tile to this world immediately
        install(enteringMember: tile)
    }

    public func stageEntry(of gameObject: GameObject) {
        // queue object to be added to this world
        enteringMembers.append(gameObject)
    }
    
    public func stageExit(of member: any GameWorldPositionable) {
        (member as? GameObject)?.isActive = false
        // queue object to be removed from this world
        exitingMembers.append(member)
    }
    
    // MARK: Attributes
    
    public func set(_ value: Float, for key: GameWorldCustomAttributeKey) {
        customAttributes[key] = value
    }
    
    public func value(for key: GameWorldCustomAttributeKey) -> Float {
        return customAttributes[key] ?? 0.0
    }
    
    // MARK: Update
    
    public func update(_ dt: Float) {
        if isTimeFrozen {
            return
        }

        // process exiting members
        processExiting()
        
        // process entering members
        processEntering()

        // update terrain
        terrain.update(dt: dt)

        // update inhabitants
        updatingGameObjects.forEach { gameObject in
            guard gameObject.isActive else {
                return
            }
            // update the game object
            gameObject.update(dt)
        }
    }
    
    // MARK: - Private Methods
    
    private func install(_ tile: GameTile, replacingPreexisting replacePreexisting: Bool = true) {
        // try adding the tile to this world's terrain
        do {
            // add the tile to the world's terrain
            try terrain.add(tile: tile)
            // associate this world
            tile.set(world: self)
            // update the size of this world
            size.width = max(size.width, tile.position.x + tile.size.width)
            size.height = max(size.height, tile.position.y + tile.size.height)
            // and notify the delegate
            delegate?.gameWorld(self, added: tile)
        } catch GameWorldTerrainError.tileExistsAtPosition(let preexistingTile) {
            print("WARNING: An attempt was made to add a tile over an existing tile in this world.")
            if replacePreexisting {
                print("An attempt will be made to swap it out.")
                uninstall(preexistingTile)
                // try to install the tile only one more time
                install(tile, replacingPreexisting: false)
                return
            } else {
                print("This attempt will be ignored.")
            }
        } catch {
            print("WARNING: An attempt to add a tile to this world apparently failed.")
        }
    }
    
    private func install(_ gameObject: GameObject) {
        // notify the delegate of the pending addition
        delegate?.gameWorld(self, willAdd: gameObject)
        
        if !gameObject.hasParent() {
            // children are updated by the parent so add the object to the update list only if parentless
            updatingGameObjects.insert(gameObject)
        }

        // set this world as the object's world
        gameObject.set(world: self)
        
        // also accept any children
        gameObject.children.forEach { childObject in
            install(childObject)
        }

        // subscribe to the object's notifications
        gameObject.add(observer: self)
        
        // and set the object as active
        gameObject.isActive = true
        
        // and notify the delegate of the add
        delegate?.gameWorld(self, added: gameObject)
    }
    
    private func install(enteringMember newMember: any GameWorldPositionable) {
        if newMember.inWorld() {
            // this member is already in a world so ignore it
            print("WARNING: An attempt was made to add a new member to this world that is already associated with a world.")
            return
        }
        
        #if DEBUG_VERBOSE
        var message: String = ""
        #endif
        
        switch newMember {
        case let tile as GameTile:
            install(tile)
            #if DEBUG_VERBOSE
            message = String(format: "GameTile added to GameWorld at (x: %.2f, y: %.2f)", newMember.position.x, newMember.position.y)
            #endif
        case let gameObject as GameObject:
            install(gameObject)
            #if DEBUG_VERBOSE
            message = String(format: "GameObject added to GameWorld at (x: %.2f, y: %.2f, z: %.2f)", newMember.position.x, newMember.position.y, newMember.position.z)
            #endif
        default:
            break
        }
        
        #if DEBUG_VERBOSE
        print(message)
        #endif
    }
    
    private func uninstall(_ tile: GameTile) {
        // remove from terrain
        terrain.remove(tile: tile)
        // and check for match with this world, just to be sure
        if tile.world === self {
            tile.set(world: nil)
        }
        
        // finally, notify the delegate
        delegate?.gameWorld(self, removed: tile)
    }
    
    private func uninstall(_ gameObject: GameObject) {
        // unsubscribe from the object's notifications
        gameObject.remove(observer: self)
        
        // orphan the object
        gameObject.removeFromParent()
        
        // queue children for removal
        gameObject.children.forEach { objectChild in
            stageExit(of: objectChild)
        }
        
        // remove any associations with this world
        collisionGrid.remove(gameObject)
        updatingGameObjects.remove(gameObject)
        // check for match with this world, just to be sure
        if gameObject.world === self {
            gameObject.set(world: nil)
        }
        
        // and notify the delegate
        delegate?.gameWorld(self, removed: gameObject)
    }
    
    private func processEntering() {
        while let newMember = enteringMembers.popLast() {
            install(enteringMember: newMember)
        }
    }
    
    private func processExiting() {
        while let exitingMember = exitingMembers.popLast() {
            switch exitingMember {
            case let tile as GameTile:
                uninstall(tile)
            case let gameObject as GameObject:
                uninstall(gameObject)
            default:
                fatalError("Exiting GameWorldPositionable is not supported.")
            }
        }
    }

    private func delegateDidSet() {
        // update delegate with world's tiles and objects
        terrain.tiles.forEach {
            delegate?.gameWorld(self, added: $0)
        }
        // and objects
        updatingGameObjects.forEach {
            delegate?.gameWorld(self, added: $0)
        }
    }

}
