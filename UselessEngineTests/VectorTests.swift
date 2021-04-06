//
//  VectorTests.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 4/1/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import XCTest
@testable import UselessEngine

class VectorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDotProduct() throws {
        let a = Vector(dx: 9, dy: 2, dz: 7)
        let result = a.dot(b: Vector(dx: 4, dy: 8, dz: 10))
        XCTAssert(result == 122)
    }
    
    func testDotProductDirection() throws {
        let a = Vector(dx: 1, dy: 1, dz: 0)
        let result = a.dot(b: Vector(dx: -1, dy: -1, dz: 0))
        XCTAssert(result < 0)
    }
    
    func testCrossProduct() throws {
        let a = Vector(dx: 0, dy: 1, dz: 0)
        let result = a.cross(b: Vector(dx: 1, dy: 0, dz: 0))
        XCTAssert(result.dx == 0 && result.dy == 0 && result.dz == -1)
    }
    
    func testTheta() throws {
        let a = Vector(dx: 1, dy: 0)
        let result = a.theta(b: Vector(dx: 1, dy: 1))
        XCTAssert(result - 45 < 1e-4)
    }

}
