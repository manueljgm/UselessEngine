//
//  AABBTests.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 2/3/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import XCTest
@testable import UselessEngine

class AABBTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMinkowskiDifferenceIntersection() throws {
        let aabb1 = AABB(position: Position(x: 5, y: 5), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        let aabb2 = AABB(position: Position(x: 5, y: 10), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        var result: Bool!
        measure {
            let md = aabb1.minkowskiDifference(aabb2)
            result = md.contains(.zero)
        }
        XCTAssert(result)
    }
    
    func testMinkowskiDifferenceMiss() throws {
        let aabb1 = AABB(position: Position(x: 10, y: 10), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        let aabb2 = AABB(position: Position(x: -0.00001, y: 0), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        let aabb3 = AABB(position: Position(x: 0, y: 20.00001), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        let aabb4 = AABB(position: Position(x: 20, y: -0.00001), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        let aabb5 = AABB(position: Position(x: 20.00001, y: 20), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        XCTAssert(!aabb1.minkowskiDifference(aabb2).contains(.zero))
        XCTAssert(!aabb1.minkowskiDifference(aabb3).contains(.zero))
        XCTAssert(!aabb1.minkowskiDifference(aabb4).contains(.zero))
        XCTAssert(!aabb1.minkowskiDifference(aabb5).contains(.zero))
    }
    
    func testSATIntersection() throws {
        let aabb1 = AABB(position: Position(x: 10, y: 10), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        let aabb2 = AABB(position: Position(x: 15, y: 15), halfwidths: Vector(dx: 5, dy: 5, dz: 5))
        var result: Bool!
        measure {
            result = (aabb1.intersect(aabb2) != nil)
        }
        XCTAssert(result)
    }
    
    func testRayIntersection() throws {
        let box = AABB(position: Position(x: 0.0, y: 0.0, z: 0.0), halfwidths: Vector(dx: 10.0, dy: 10.0, dz: 10.0))
        XCTAssertTrue(box.intersect(Ray(position: Position(x: 0.0, y: 25.0, z: 0.0), direction: Vector(dx: 1.0, dy: 0.0, dz: 0.0))) == nil)
        XCTAssertTrue(box.intersect(Ray(position: Position(x: 50.0, y: 50.0, z: 0.0), direction: Vector(dx: 0.0, dy: 5.0, dz: 0.0))) == nil)
        XCTAssertTrue(box.intersect(Ray(position: Position(x: -10.0, y: -10.0, z: 0.0), direction: Vector(dx: 1.0, dy: 1.0, dz: 0.0))) != nil)
        XCTAssertTrue(box.intersect(Ray(position: Position(x: 10.0, y: 10.0, z: 0.0), direction: Vector(dx: 1.0, dy: 1.0, dz: 0.0))) != nil)
    }
    
    func testRayIntersectionIgnoringZ() throws {
        let box = AABB(position: Position(x: 6.0, y: 6.0, z: 0.0), halfwidths: Vector(dx: 5.0, dy: 5.0, dz: 5.0))
        let ray = Ray(position: Position(x: 0.0, y: 0.0, z: 6.0), direction: Vector(dx: 1.0, dy: 1.0, dz: 1.0))
        let result = box.intersect(ray, ignoringZ: true)
        XCTAssert(result != nil)
    }
    
}
 
