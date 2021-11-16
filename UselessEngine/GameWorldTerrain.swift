//
//  GameWorldTerrain.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import Foundation

public class GameWorldTerrain {

    public private(set) var tileSize: Vector2d
    public private(set) var tiles: Set<GameTile>
    
    private var tileByGridPosition: [UnitPosition: GameTile]
    
    public init(tileSize: Vector2d) {
        self.tileSize = tileSize
        self.tiles = []
        self.tileByGridPosition = [:]
    }
    
    public func add(tile: GameTile) {
        let gridPositionKey = gridPosition(from: tile.position)
        
        if let preexistingTile = tileByGridPosition[gridPositionKey] {
            tiles.remove(preexistingTile)
            preexistingTile.world?.remove(member: preexistingTile)
        }
    
        tileByGridPosition[gridPositionKey] = tile
        tiles.insert(tile)
    }
    
    public func update(dt: Float, in world: GameWorld) {
        tiles.forEach {
            let _ = $0.update(dt, in: world)
        }
    }

    public func tile(at position: PlaneCoordinate) -> GameTile? {
        return tileByGridPosition[gridPosition(from: position)]
    }
    
    public func elevation(at point: PlaneCoordinate) -> Float {
        guard let tile = tile(at: point) else {
            return .zero
        }

        let checkPoint = point - tile.position
        return tile.elevation.getElevation(atPoint: checkPoint)
    }

    // MARK: - Helper Methods
    
    private func gridPosition(from position: PlaneCoordinate) -> UnitPosition {
        let gridPosition = UnitPosition(x: Int(round(position.x / tileSize.dx)),
                                        y: Int(round(position.y / tileSize.dy)))
        return gridPosition

    }
    
}
