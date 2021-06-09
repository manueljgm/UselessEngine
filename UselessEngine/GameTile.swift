//
//  GameTile.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public class GameTile: GameWorldMember
{
    public let graphics: GameWorldMemberGraphicsComponent
    
    public let size: (width: Float, height: Float)
    
    public var position: Position {
        didSet {
            graphics.receive(event: .memberChange(with: .position), from: self, payload: oldValue)
        }
    }
    
    public let elevation: GameTileElevation

    private static var inited: Int = 0
    
    public init(graphics graphicsComponent: GameWorldMemberGraphicsComponent,
                size: (width: Float, height: Float),
                elevation: GameTileElevation)
    {
        self.graphics = graphicsComponent
        self.size = size
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
    
    public func update(_ dt: Float, in world: GameWorld) -> GameWorldMemberChanges {
        graphics.update(with: self, dt: dt)
        return .none
    }
    
}

extension GameTile: Equatable {
    
    public static func == (lhs: GameTile, rhs: GameTile) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}

extension GameTile: Hashable {

    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self))
    }
    
}
