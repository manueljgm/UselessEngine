//
//  GameWorldMember.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public class GameWorldMember: NSObject, GameWorldPositionable {

    public internal(set) weak var world: GameWorld?

    public var graphics: GameWorldMemberGraphicsComponent
    
    public var position: Position {
        didSet {
            graphics.receive(event: .memberChange(with: .position), from: self, payload: oldValue)
        }
    }
    
    public init(graphics: GameWorldMemberGraphicsComponent, position: Position = .zero) {
        self.graphics = graphics
        self.position = .zero
        super.init()
        defer {
            // deferring setting this value will result in call to position's didSet
            self.position = position
        }
    }
    
    public func update(_ dt: Float, in world: GameWorld) -> GameWorldMemberChanges {
        graphics.update(with: self, in: world, dt: dt)
        return .none
    }

}
