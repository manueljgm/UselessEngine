//
//  GameWorldTerrain.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/27/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import UselessCommon

internal enum GameWorldTerrainError: Error {
    case tileExistsAtPosition(GameTile)
}

public class GameWorldTerrain {

    public private(set) var tileSize: GameTileSize
    public private(set) var tiles: Set<GameTile>

    private var tileLayout: [UnitPosition: GameTile]

    private var xMinMax: (min: Int, max: Int) = (Int.max, Int.min)
    private var yMinMax: (min: Int, max: Int) = (Int.max, Int.min)
    private var xMinMaxByY: [Int: (min: Int, max: Int)] = [:]
    private var yMinMaxByX: [Int: (min: Int, max: Int)] = [:]

    public func tile(at position: PlaneCoordinate) -> GameTile? {
        let gridPositionKey = gridPosition(from: position, componentPreprocessor: floor)
        return tileLayout[gridPositionKey]
    }

    public func nearestTile(to position: PlaneCoordinate) -> GameTile? {
        let gridPositionKey = gridPosition(from: position, componentPreprocessor: floor)
        let checkPositionX = clamp(gridPositionKey.x, lower: xMinMax.min, upper: xMinMax.max)
        let checkPositionY = clamp(gridPositionKey.y, lower: yMinMax.min, upper: yMinMax.max)
        
        guard
            let xMinMax = xMinMaxByY[checkPositionY],
            let yMinMax = yMinMaxByX[checkPositionX] else {
            return nil
        }
        
        let nearestMatch = UnitPosition(x: clamp(gridPositionKey.x, lower: xMinMax.min, upper: xMinMax.max),
                                        y: clamp(gridPositionKey.y, lower: yMinMax.min, upper: yMinMax.max))
        return tileLayout[nearestMatch]
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

        updateMinMaxValues(adding: gridPositionKey)
    }
    
    internal func remove(tile: GameTile) {
        let gridPositionKey = gridPosition(from: tile.position, componentPreprocessor: round)
        tiles.remove(tile)
        tileLayout.removeValue(forKey: gridPositionKey)
        
        updateMinMaxValues(removing: gridPositionKey)
    }

    internal func update(dt: Float) {
        tiles.forEach {
            // update the tile
            $0.update(dt)
            // notify the tile's world of the update event
            $0.world?.receive(event: .memberUpdate(with: .none), from: $0, payload: nil)
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
    
    private func updateMinMaxValues(adding gridPositionToAdd: UnitPosition) {
        xMinMax = (min(xMinMax.min, gridPositionToAdd.x),
                   max(xMinMax.max, gridPositionToAdd.x))
        yMinMax = (min(yMinMax.min, gridPositionToAdd.y),
                   max(yMinMax.max, gridPositionToAdd.y))
        
        let xMinMax = xMinMaxByY[gridPositionToAdd.y] ?? (gridPositionToAdd.x, gridPositionToAdd.x)
        let newXMinMax = (min(xMinMax.min, gridPositionToAdd.x), max(xMinMax.max, gridPositionToAdd.x))
        xMinMaxByY[gridPositionToAdd.y] = newXMinMax
        
        let yMinMax = yMinMaxByX[gridPositionToAdd.x] ?? (gridPositionToAdd.y, gridPositionToAdd.y)
        let newYMinMax = (min(yMinMax.min, gridPositionToAdd.y), max(yMinMax.max, gridPositionToAdd.y))
        yMinMaxByX[gridPositionToAdd.x] = newYMinMax
    }
    
    private func updateMinMaxValues(removing gridPositionToRemove: UnitPosition) {
        guard
            let oldXMinMax = xMinMaxByY[gridPositionToRemove.y],
            let oldYMinMax = yMinMaxByX[gridPositionToRemove.x] else {
            return
        }
        
        if gridPositionToRemove.x > oldXMinMax.min
        && gridPositionToRemove.x < oldXMinMax.max
        && gridPositionToRemove.y > oldYMinMax.min
        && gridPositionToRemove.y < oldYMinMax.max {
            // the position falls inside the values stored in its respective row and column
            // so there's no change needed to update the min and max values
            return
        }

        // update min and max values
        var newMinX: Int = Int.max,
            newMaxX: Int = Int.min,
            newMinY: Int = Int.max,
            newMaxY: Int = Int.min,
            newMinXByY: Int = Int.max,
            newMaxXByY: Int = Int.min,
            newMinYByX: Int = Int.max,
            newMaxYByX: Int = Int.min
        tileLayout.keys.forEach { storedPosition in
            if storedPosition.y == gridPositionToRemove.y {
                // update x min max by y
                newMinXByY = min(newMinXByY, storedPosition.x)
                newMaxXByY = max(newMaxXByY, storedPosition.x)
            }
            if storedPosition.x == gridPositionToRemove.x {
                // update y min max by x
                newMinYByX = min(newMinYByX, storedPosition.y)
                newMaxYByX = max(newMaxYByX, storedPosition.y)
            }
            // update overall min and max
            newMinX = min(newMinX, storedPosition.x)
            newMaxX = max(newMaxX, storedPosition.x)
            newMinY = min(newMinY, storedPosition.y)
            newMaxY = max(newMaxY, storedPosition.y)
        }
        
        // store min and max of this row
        if newMinXByY == Int.max {
            // the row of the removed tile is now empty
            xMinMaxByY.removeValue(forKey: gridPositionToRemove.y)
        } else {
            xMinMaxByY[gridPositionToRemove.y] = (newMinXByY, newMaxXByY)
        }
        
        // store min and max of this column
        if newMinYByX == Int.max {
            // the column of the removed tile is now empty
            yMinMaxByX.removeValue(forKey: gridPositionToRemove.x)
        }
        else {
            yMinMaxByX[gridPositionToRemove.x] = (newMinYByX, newMinYByX)
        }

        // store overall min and max
        xMinMax = (newMinX, newMaxX)
        yMinMax = (newMinY, newMaxY)
    }
}
