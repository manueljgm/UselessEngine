//
//  GameTile.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

import Foundation

public typealias GameTileSize = (width: Float, height: Float)

public class GameTile: GameWorldPositionable {
    
    public private(set) weak var world: GameWorld?
    
    public let size: GameTileSize
    public let elevation: GameTileElevation
    public var position: Position = .zero
    
    public var graphics: any GameWorldMemberGraphicsComponent<GameTile>

    private let id = UUID()
    
#if DEBUG_VERBOSE
    private static var inited: Int = 0
#endif
    
    public init(graphics graphicsComponent: any GameWorldMemberGraphicsComponent<GameTile>,
                size: GameTileSize,
                elevation: GameTileElevation)
    {
        self.size = size
        self.elevation = elevation

        graphics = graphicsComponent

#if DEBUG_VERBOSE
        GameTile.inited += 1
        print(String(format: "GameTile:init; %d exist", GameTile.inited))
#endif
    }
    
    deinit {
#if DEBUG_VERBOSE
        GameTile.inited -= 1
        print(String(format: "GameTile:deinit; %d remain", GameTile.inited))
#endif
    }
    
    public func update(_ dt: Float) {
        // update graphics
        graphics.update(with: self, dt: dt)
    }
    
    public func removeFromWorld() {
        world?.stageExit(of: self)
    }
    
    internal func set(world: GameWorld?) {
        self.world = world
    }
    
}

extension GameTile: Hashable {
        
    public static func == (lhs: GameTile, rhs: GameTile) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
