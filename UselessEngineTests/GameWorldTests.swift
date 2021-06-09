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
    func resolveBoundaries(on gameObject: GameObject, in world: GameWorld) {
        // do nothing
    }
    
    func resolveCollision(on gameObject: GameObject, against otherObject: GameObject, for hit: Hit) -> (thisCorrection: Vector, otherCorrection: Vector)? {
        // do nothing
        return nil
    }
}

fileprivate class TestObjectGraphicsComponent: GameWorldMemberGraphicsComponent {
    var sprite: SKSpriteNode = SKSpriteNode()
    
    func update(with owner: GameWorldMember, dt: Float) {
        // do nothing
    }
}

fileprivate class TestObjectPhysicsCollision: PhysicsCollisionDelegate {
    var categoryBitmask: PhysicsCollisionCategories = .All
    var contactBitmask: PhysicsCollisionCategories = .All
    var collisionBitmask: PhysicsCollisionCategories = .All
    var contactAABB: AABB
    var contactWithConsequences: Bool = false
    init(aabb: AABB) {
        contactAABB = aabb
    }
}

fileprivate class TestObjectPhysicsComponent: GameObjectPhysicsComponent {
    var id: UUID = UUID()
    var mass: Float = 1.0
    var thrust: Vector = .zero
    var boost: Boost? =  nil
    var addDrag: Bool = false
    
    var collisionDelegate: PhysicsCollisionDelegate?
    
    init(aabb: AABB) {
        collisionDelegate = TestObjectPhysicsCollision(aabb: aabb)
    }
    
    func update(with owner: GameObject, in world: GameWorld, dt: Float) {
        // do nothing
    }
    
    func receive(event: GameWorldMemberEvent, from sender: GameObject, payload: Any?) {
        switch event {
        case .memberChange(let changes):
            if changes.contains(.position) {
                collisionDelegate?.contactAABB.position = sender.position
            }
        default:
            break
        }
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

// MARK: - Tests

class GameWorldTests: XCTestCase {

    var testWorld: GameWorld!
    
    override func setUpWithError() throws {
        
        let tileSize = Vector2d(dx: 2.0, dy: 2.0)
        
        testWorld = GameWorld(gravity: -9.8,
                              tileSize: tileSize,
                              collisionCellSize: Vector2d(dx: 1.0, dy: 1.0),
                              collisionDelegate: TestWorldCollisionDelegate(),
                              pathGraphDelegate: TestGameWorldGraphDelegate())
        
        for x in 0...100 {
            for y in 0...10 {
                if Int.random(in: 0...9) != 7 {
                    let tile = GameTile(graphics: TestObjectGraphicsComponent(),
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

    
    func testGameWorldCollisionRayCheck() throws {
        let testObject1 = GameObject(graphics: TestObjectGraphicsComponent(),
                                    physics: TestObjectPhysicsComponent(aabb: AABB(halfwidths: Vector(dx: 0.55, dy: 0.55, dz: 0.55))),
                                    input: nil)
        testObject1.position = Position(x: 3, y: 3)
        let testObject2 = GameObject(graphics: TestObjectGraphicsComponent(),
                                     physics: TestObjectPhysicsComponent(aabb: AABB(halfwidths: Vector(dx: 0.5, dy: 0.5, dz: 0.5))),
                                     input: nil)
        testObject2.position = Position(x: 3, y: 3)
        testWorld.add(member: testObject2)
        testWorld.add(member: testObject1)
        var result: (object: GameObject, distance: Vector)? = nil
        measure {
            result = testWorld.collisionGrid.nextObject(between: Position(x: 0.0, y: 0.0), and: Position(x: 20.0, y: 20.0))
        }
        XCTAssert(result != nil)
    }
    
    func testGameWorldGraph() throws {
        let testWorldGraph = GameWorldGraph(graphDelegate: TestGameWorldGraphDelegate())
        try? testWorldGraph.generate(for: testWorld, nodeSpacing: (dx: 0.25, dy: 0.25))
        guard let node = testWorldGraph.node(at: UnitPosition(x: 1, y: 1)) else
        {
            XCTAssert(false)
            return
        }
        XCTAssert(node.neighbors.count > 0)
    }

    func testGameWorldPath() throws {
        let testWorldGraph = GameWorldGraph(graphDelegate: TestGameWorldGraphDelegate())
        try? testWorldGraph.generate(for: testWorld, nodeSpacing: (dx: 1.0, dy: 1.0))
        var path: [Position] = []
        path = testWorldGraph.path(from: Position(x: 1, y: 1), to: Position(x: 50, y: 3))
        XCTAssert(path.count > 0)
    }
    
}
