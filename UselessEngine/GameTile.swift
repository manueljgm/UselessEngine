//
//  GameTile.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public class GameTile: GameEntity {
    
    public let graphics: GameEntityGraphicsComponent?
    
    public var position: Position {
        didSet {
            positionDidUpdate(from: oldValue)
        }
    }
    
    public let elevation: GameTileElevation
    
    /// Reference to neighboring tile above self.
    public weak var u: GameTile?
    /// Reference to neighboring tile below self.
    public weak var d: GameTile?
    /// Reference to neighboring tile to the left of self.
    public weak var l: GameTile?
    /// Reference to neighboring tile to the right of self.
    public weak var r: GameTile?
    
    /// Reference to the list of game objects standing on this tile.
    public private(set) var objects: [GameObject]

    private static var inited: Int = 0
    
    public init(graphics graphicsComponent: GameEntityGraphicsComponent, elevation: GameTileElevation) {
        self.graphics = graphicsComponent
        self.position = .zero
        self.elevation = elevation
        self.objects = []

        GameTile.inited += 1
    }
    
    deinit {
        GameTile.inited -= 1
        #if DEBUG_VERBOSE
        print(Unmanaged.passUnretained(self).toOpaque(), String(format: "TileObject:deinit; %d remain", GameTile.inited))
        #endif
    }
    
    public func update(_ dt: Float) {
        
    }
    
    public func executeOnObjectsAndNeighbors(work: (GameObject) -> Void ) {
        objects.forEach { work($0) }
        u?.objects.forEach { work($0) }
        u?.r?.objects.forEach { work($0) }
        r?.objects.forEach { work($0) }
        r?.d?.objects.forEach { work($0) }
        d?.objects.forEach { work($0) }
        d?.l?.objects.forEach { work($0) }
        l?.objects.forEach { work($0) }
        l?.u?.objects.forEach { work($0) }
    }
    
    public func add(gameObject: GameObject) -> Bool{
        if !objects.contains(where: { $0 === gameObject }) {
            objects.append(gameObject)
            return true
        }
        return false
    }
    
    public func remove(gameObject: GameObject) {
        if let i = objects.firstIndex(where: { $0 === gameObject }) {
            objects.remove(at: i)
        }
    }
    
    // MARK: - Events
    
    private func positionDidUpdate(from previousPosition: Position) {
        graphics?.positionDidUpdate(from: previousPosition, for: self)
    }
    
}
