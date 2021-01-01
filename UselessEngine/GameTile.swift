//
//  GameTile.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public class GameTile: GameEntity, Identifiable
{
    public let id: UUID = UUID()
    
    public let graphics: GameEntityGraphicsComponent?
    
    public var position: Position {
        didSet {
            graphics?.receive(event: .positionChange, from: self)
        }
    }
    
    public let elevation: GameTileElevation

    private static var inited: Int = 0
    
    public init(graphics graphicsComponent: GameEntityGraphicsComponent, elevation: GameTileElevation)
    {
        self.graphics = graphicsComponent
        self.position = .zero
        self.elevation = elevation

        GameTile.inited += 1
        #if DEBUG_VERBOSE
        print(String(format: "GameTile:init; %d exist", GameTile.inited))
        #endif
    }
    
    deinit {
        GameTile.inited -= 1
        #if DEBUG_VERBOSE
        print(String(format: "GameTile:deinit; %d remain", GameTile.inited))
        #endif
    }
    
    public func update(_ dt: Float, in world: GameWorld) -> GameEntityChanges {
        return []
    }
    
}

extension GameTile: Equatable {
    public static func == (lhs: GameTile, rhs: GameTile) -> Bool {
        return lhs.id == rhs.id
    }
}
