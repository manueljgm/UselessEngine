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

fileprivate class TestWorldCollisionDelegate: GameWorldCollisionDelegate {
    func resolveBoundaries(on gameObject: GameObject, in world: GameWorld) {
        // do nothing
    }
    
    func resolveCollision(on gameObject: GameObject, against otherObject: GameObject, for hit: Hit) -> (thisCorrection: Vector, otherCorrection: Vector)? {
        // do nothing
        return nil
    }
}

fileprivate class TestTileGraphicsComponent: GameWorldMemberGraphicsComponent {
    var sprite: SKSpriteNode = SKSpriteNode()
    
    func update(with owner: GameWorldMember, dt: Float) {
        // do nothing
    }
}

fileprivate class TestTileElevation: GameTileElevation {
    func getElevation(atPoint point: PlaneCoordinate) -> Float {
        return .zero
    }
}

fileprivate class TestGameWorldGraphDelegate: GameWorldGraphDelegate {
    func cost(from origin: GameWorldGraphNode, to destination: GameWorldGraphNode) -> Float {
        return 1.0
    }
    
    func heuristic(from origin: GameWorldGraphNode, to goal: GameWorldGraphNode) -> Float {
        return goal.worldPosition.x - origin.worldPosition.x + goal.worldPosition.y - goal.worldPosition.y
    }
}

class GameWorldTests: XCTestCase {

    var testWorld: GameWorld!
    
    override func setUpWithError() throws {
        
        let tileSize = Vector2d(dx: 2.0, dy: 2.0)
        
        testWorld = GameWorld(gravity: -9.8,
                              tileSize: tileSize,
                              collisionCellSize: Vector2d(dx: 1.0, dy: 1.0),
                              collisionDelegate: TestWorldCollisionDelegate())
        
        for x in 0...100 {
            for y in 0...10 {
                if Int.random(in: 0...9) != 7 {
                    let tile = GameTile(graphics: TestTileGraphicsComponent(),
                                        size: (width: tileSize.dx, height: tileSize.dy),
                                        elevation: TestTileElevation())
                    tile.position = Position(x: tileSize.dx * Float(x), y: tileSize.dy * Float(y))
                    let _ = testWorld.add(gameTile: tile)
                }
            }
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testGameWorldGraph() throws {
//        let testWorldGraph = GameWorldGraph(nodeSpacing: (dx: 0.25, dy: 0.25), graphDelegate: TestGameWorldGraphDelegate())
//        measure {
//            try? testWorldGraph.generate(for: testWorld)
//        }
//        guard let node = testWorldGraph.nodeAt(graphPosition: UnitPosition(x: 1, y: 1)) else
//        {
//            XCTAssert(false)
//            return
//        }
//        XCTAssert(node.neighbors.count > 0)
//    }

    func testGameWorldPath() throws {
        let testWorldGraph = GameWorldGraph(nodeSpacing: (dx: 1.0, dy: 1.0), graphDelegate: TestGameWorldGraphDelegate())
        try? testWorldGraph.generate(for: testWorld)
        var path: [Position] = []
        measure {
            path = testWorldGraph.path(from: Position(x: 1, y: 1), to: Position(x: 50, y: 3))
        }
        XCTAssert(path.count > 0)
    }
    
}
