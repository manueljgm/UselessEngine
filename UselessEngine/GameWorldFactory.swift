//
//  GameWorldFactory.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/17/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public protocol GameWorldFactory {
    func getWorldProperties() throws -> (gravity: Float, gridDimensions: (width: Int, height: Int), gridSpacing: Vector2d)
    func getWorldCollisionHandler() throws -> GameWorldCollisionHandler
    func getStageTiles() throws -> [GameTile]
    func getStageObjects() throws -> [GameEntity]
}
