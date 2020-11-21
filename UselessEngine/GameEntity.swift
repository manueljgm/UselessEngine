//
//  GameEntity.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public struct GameEntityChanges: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let position = GameEntityChanges(rawValue: 1 << 0)
    public static let velocity = GameEntityChanges(rawValue: 1 << 1)
}

public protocol GameEntity: class {
    var graphics: GameEntityGraphicsComponent? { get }
    var position: Position { get set }
    func update(_ dt: Float) -> GameEntityChanges
}

