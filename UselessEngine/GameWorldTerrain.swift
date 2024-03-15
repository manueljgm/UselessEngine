//
//  GameWorldTerrain.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public class GameWorldTerrain {

    public private(set) var tileSize: GameTileSize
    public private(set) var tiles: Set<GameTile>
    
    private var tileLayout: [UnitPosition: GameTile]
    
    public init(tileSize: GameTileSize) {
        self.tileSize = tileSize
        self.tiles = []
        self.tileLayout = [:]
    }
    
    public func add(tile: GameTile) {
        let gridPositionKey = gridPosition(from: tile.position, componentPreprocessor: round)
        
        if let preexistingTile = tileLayout[gridPositionKey] {
            tiles.remove(preexistingTile)
            preexistingTile.world?.remove(member: preexistingTile)
        }
    
        tileLayout[gridPositionKey] = tile
        tiles.insert(tile)
        
        tile.isActive = true
    }
    
    public func update(dt: Float) {
        tiles.forEach {
            let _ = $0.update(dt)
        }
    }

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
    
    public func remove(tile: GameTile) {
        tiles.remove(tile)
        tileLayout.removeValue(forKey: gridPosition(from: tile.position, componentPreprocessor: round))
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
