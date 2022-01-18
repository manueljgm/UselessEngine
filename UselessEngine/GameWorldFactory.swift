//
//  GameWorldFactory.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/13/22.
//  Copyright © 2022 Useless Robot. All rights reserved.
//

public protocol GameWorldFactory {
    associatedtype RawMaterial
    func makeTiles(from rawMaterial: RawMaterial) throws -> [GameTile]
    func makeMembers(from rawMaterial: RawMaterial) throws -> [GameObject]
}
