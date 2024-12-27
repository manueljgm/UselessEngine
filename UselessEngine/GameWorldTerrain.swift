//
//  GameWorldTerrain.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

internal enum GameWorldTerrainError: Error {
    case tileExistsAtPosition(GameTile)
}


public class GameWorldTerrain {

    public private(set) var tileSize: GameTileSize
    public private(set) var tiles: Set<GameTile>

    private var tileLayout: [UnitPosition: GameTile]

    public func tile(at position: PlaneCoordinate) -> GameTile? {
        let gridPositionKey = gridPosition(from: position, componentPreprocessor: floor)
        return tileLayout[gridPositionKey]
    }
    
    public func elevation(at point: PlaneCoordinate) -> Float {
        guard let tile = tile(at: point) else {
            return .zero
        }

        let checkPoint = point - tile.position
        return tile.elevation.getElevation(atPoint: checkPoint)
    }
    
    internal init(tileSize: GameTileSize) {
        self.tileSize = tileSize
        self.tiles = []
        self.tileLayout = [:]
    }

    internal func add(tile: GameTile) throws {
        let gridPositionKey = gridPosition(from: tile.position, componentPreprocessor: round)
        
        if let preexistingTile = tileLayout[gridPositionKey] {
            throw GameWorldTerrainError.tileExistsAtPosition(preexistingTile)
        }
    
        tileLayout[gridPositionKey] = tile
        tiles.insert(tile)
    }
    
    internal func remove(tile: GameTile) {
        tiles.remove(tile)
        tileLayout.removeValue(forKey: gridPosition(from: tile.position, componentPreprocessor: round))
    }

    internal func update(dt: Float) {
        tiles.forEach {
            // update the tile
            $0.update(dt)
            // notify the tile's world of the update event
            if let world = $0.world {
                world.delegate?.gameWorld(world, updated: $0)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func gridPosition(from position: PlaneCoordinate,
                              componentPreprocessor preprocess: (Float) -> Float)
    -> UnitPosition {
        let gridPosition = UnitPosition(x: Int(preprocess(position.x / tileSize.width)),
                                        y: Int(preprocess(position.y / tileSize.height)))
        return gridPosition
    }
    
}
