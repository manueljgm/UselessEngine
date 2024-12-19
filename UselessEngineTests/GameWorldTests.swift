//
//  GameWorldTests.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 2/16/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import XCTest
import SpriteKit
@testable import UselessEngine

// MARK: - Test Types

fileprivate class TestWorldCollisionDelegate: GameWorldCollisionDelegate {
    func intersect(_ gameObject: GameObject, with otherObject: GameObject) -> Hit? {
        return nil
    }
    
    func isGameObject(_ gameObject: GameObject, contactableWith otherObject: GameObject) -> Bool {
        return false
    }
    
    func isGameObject(_ gameObject: GameObject, collidableWith otherObject: GameObject) -> Bool {
        return false
    }
    
    func resolveCollision(on gameObject: GameObject, against otherObject: GameObject, for hit: Hit) -> (thisCorrection: Vector, otherCorrection: Vector) {
        return (.zero, .zero)
    }
}

fileprivate class TestTileElevation: GameTileElevation {
    func getElevation(atPoint point: PlaneCoordinate) -> Float {
        return .zero
    }
}

// MARK: - Tests

class GameWorldTests: XCTestCase {

    var testWorld: GameWorld!
    
    override func setUpWithError() throws {
        
        let tileSize = GameTileSize(width: 2.0, height: 2.0)
        
        testWorld = try! GameWorld(tileSize: tileSize,
                                   collisionCellSize: Vector2d(dx: 1.0, dy: 1.0),
                                   collisionDelegate: TestWorldCollisionDelegate())
        
        for x in 0...100 {
            for y in 0...10 {
                if Int.random(in: 0...9) != 7 {
                    let tile = GameTile(graphics: TestTileGraphicsComponent(),
                                        size: (width: tileSize.width, height: tileSize.height),
                                        elevation: TestTileElevation())
                    tile.position = Position(x: tileSize.width * Float(x), y: tileSize.height * Float(y))
                    testWorld.add(tile)
                }
            }
        }
        
        testWorld.update(0.0)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testGameWorldCollisionRayCheck() throws {
        let testObject1 = GameObject(graphics: TestObjectGraphicsComponent(),
                                     physics: TestObjectPhysicsComponent(mass: 1.0,
                                                                         collision: GameObjectCollisionComponent(categoryBitmask: .all,
                                                                                                                 contactBitmask: .all,
                                                                                                                 collisionBitmask: .all,
                                                                                                                 contactAABB: AABB(halfwidths: Vector(dx: 0.55, dy: 0.55, dz: 0.55))),
                                                                         gravityScale: 1.0,
                                                                         thrust: nil,
                                                                         distanceTraveled: 0.0),
                                     input: nil)
        testObject1.position = Position(x: 3, y: 3)
        testWorld.stageEntry(of: testObject1)
        
        let testObject2 = GameObject(graphics: TestObjectGraphicsComponent(),
                                     physics: TestObjectPhysicsComponent(mass: 1.0,
                                                                         collision: GameObjectCollisionComponent(categoryBitmask: .all,
                                                                                                                 contactBitmask: .all,
                                                                                                                 collisionBitmask: .all,
                                                                                                                 contactAABB: AABB(halfwidths: Vector(dx: 0.5, dy: 0.5, dz: 0.5))),
                                                                         gravityScale: 1.0,
                                                                         thrust: nil,
                                                                         distanceTraveled: 0.0),
                                     input: nil)
        testObject2.position = Position(x: 6, y: 6)
        testWorld.stageEntry(of: testObject2)

        testWorld.update(0.0)
        
        var result: (object: GameObject, distance: Vector)? = nil
        measure {
            result = testWorld.collisionGrid.nextObject(between: Position(x: 0.0, y: 0.0), and: Position(x: 20.0, y: 20.0))
        }
        
        XCTAssert(result != nil)
    }

}
