//
//  GameTile.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public class GameTile: GameWorldMember {
    
    public let size: (width: Float, height: Float)
    
    public let elevation: GameTileElevation

    private static var inited: Int = 0
    
    public init(graphics graphicsComponent: GameWorldMemberGraphicsComponent,
                size: (width: Float, height: Float),
                elevation: GameTileElevation)
    {
        self.size = size
        self.elevation = elevation
        
        super.init(graphics: graphicsComponent, position: .zero)

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
    
}

