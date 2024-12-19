//
//  GameObjectTests.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 12/13/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import XCTest
@testable import UselessEngine

class GameObjectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParentChildRelationship() throws {
        let parent = GameObject(graphics: TestObjectGraphicsComponent())
        let child = GameObject(graphics: TestObjectGraphicsComponent(),
                               physics: TestObjectPhysicsComponent(mass: 1.0,
                                                                   collision: GameObjectCollisionComponent(categoryBitmask: .none,
                                                                                                           contactBitmask: .none,
                                                                                                           collisionBitmask: .none,
                                                                                                           contactAABB: AABB(halfwidths: Vector(dx: 1.0, dy: 1.0, dz: 1.0))),
                                                                   gravityScale: 1.0,
                                                                   thrust: nil,
                                                                   distanceTraveled: 0.0))
        let grandchild = GameObject(graphics: TestObjectGraphicsComponent(),
                                    physics: TestObjectPhysicsComponent(mass: 1.0,
                                                                        collision: GameObjectCollisionComponent(categoryBitmask: .none,
                                                                                                                contactBitmask: .none,
                                                                                                                collisionBitmask: .none,
                                                                                                                contactAABB: AABB(halfwidths: Vector(dx: 1.0, dy: 1.0, dz: 1.0))),
                                                                        gravityScale: 1.0,
                                                                        thrust: nil,
                                                                        distanceTraveled: 0.0))
        
        // assert that the parent's positions is zero
        XCTAssert(parent.position == .zero)
        // assert that the child's positions is zero
        XCTAssert(child.position == .zero)
        // assert that the grandchild's positions is zero
        XCTAssert(grandchild.position == .zero)
        
        var parentPosition = Position(x: 1.0, y: 2.0, z: 3.0)
        parent.position = parentPosition
        // assert that the parent's position is updated
        XCTAssert(parent.position == parentPosition)

        parent.add(child: child)
        // assert that the parent has one child
        XCTAssert(parent.children.count == 1)
        // assert that the child's parent is the parent object
        XCTAssert(child.parent == parent)
        // assert that the child's position is the parent's position since its relative position is zero
        XCTAssert(child.position == parentPosition)
        
        child.add(child: grandchild)
        // assert that the child has one child
        XCTAssert(child.children.count == 1)
        // assert that grandchild's parent is the child object
        XCTAssert(grandchild.parent == child)
        // assert that the grandchild's position is the grandparent's position since its relative position is zero
        XCTAssert(grandchild.position == parentPosition)
        
        let childOffset = Position(x: -1.0, y: -2.0, z: -3.0)
        child.relativePosition = childOffset
        // assert that the parent position did not change
        XCTAssert(parent.position == parentPosition)
        // assert that the child position is the parent's position + offset
        XCTAssert(child.position == Position(x: parent.position.x + childOffset.x,
                                             y: parent.position.y + childOffset.y,
                                             z: parent.position.z + childOffset.z))
        // assert that the grandchild's position no longer matches its grandparent's position
        XCTAssert(grandchild.position != parent.position)
        // assert that the grandchild's position should still match the child object's position since relative position is zero
        XCTAssert(grandchild.position == child.position)
        
        let grandchildOffset = Position(x: 2.0, y: 4.0, z: 6.0)
        grandchild.relativePosition = grandchildOffset
        // assert that the parent position did not change
        XCTAssert(parent.position == parentPosition)
        // assert that the child position is the parent's position + offset
        XCTAssert(child.position == Position(x: parent.position.x + childOffset.x,
                                             y: parent.position.y + childOffset.y,
                                             z: parent.position.z + childOffset.z))
        // assert that the child position is the child object's position + offset
        XCTAssert(grandchild.position == Position(x: child.position.x + grandchildOffset.x,
                                                  y: child.position.y + grandchildOffset.y,
                                                  z: child.position.z + grandchildOffset.z))
        
        parentPosition.x += 5.0
        parentPosition.y += 10.0
        parentPosition.z += 15.0
        parent.position = parentPosition
        // assert that the parent position is updated
        XCTAssert(parent.position == parentPosition)
        // assert that the child position is still the parent's position + offset
        XCTAssert(child.position == Position(x: parent.position.x + childOffset.x,
                                             y: parent.position.y + childOffset.y,
                                             z: parent.position.z + childOffset.z))
        // assert that the child position is still the child object's position + offset
        XCTAssert(grandchild.position == Position(x: child.position.x + grandchildOffset.x,
                                                  y: child.position.y + grandchildOffset.y,
                                                  z: child.position.z + grandchildOffset.z))
        
        child.removeFromParent()
        // assert that the parent has no children
        XCTAssert(parent.children.isEmpty)
        // assert that the child has no parent
        XCTAssert(child.parent == nil)
        // assert that the parent's position did not change
        XCTAssert(parent.position == parentPosition)
        // assert that the child's position did not change
        XCTAssert(child.position == Position(x: parent.position.x + childOffset.x,
                                             y: parent.position.y + childOffset.y,
                                             z: parent.position.z + childOffset.z))
        // assert that the child's relative position updated to an anchor of .zero
        XCTAssert(child.relativePosition == child.position)
        // assert that the grandchild's position did not change
        XCTAssert(grandchild.position == Position(x: child.position.x + grandchildOffset.x,
                                                  y: child.position.y + grandchildOffset.y,
                                                  z: child.position.z + grandchildOffset.z))
        
        grandchild.position = child.position
        // assert that the grandchild's relative position updated to zero
        XCTAssert(grandchild.relativePosition == .zero)
        // assert that the grandchild's position is the child object's position
        XCTAssert(grandchild.position == child.position)
        
        grandchild.removeFromParent()
        // assert that the child has no children
        XCTAssert(child.children.isEmpty)
        // assert that the grandchild has no parent
        XCTAssert(grandchild.parent == nil)
        // assert that the grandchild's position is still the child object's position
        XCTAssert(grandchild.position == child.position)
    }

}
