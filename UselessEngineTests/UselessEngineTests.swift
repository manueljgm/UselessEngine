//
//  UselessEngineTests.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 1/18/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import XCTest
import simd
@testable import UselessEngine

class UselessEngineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVectorPerformance() throws {
        measure {
            for _ in 0...9999 {
                
                let p1 = Position(x: 1.0, y: 2.0, z: 3.0)
                let p2 = Position(x: 4.0, y: 5.0, z: 6.0)
                let dist = Vector(dx: p2.x-p1.x, dy: p2.y-p1.y, dz: p2.z-p1.z).magnitude
                XCTAssert(dist > .zero)
                
            }
        }
    }
    
    func testSIMD3Performance() throws {
        measure {
            for _ in 0...9999 {
                
                let p1 = SIMD3<Float>(1.0, 2.0, 3.0)
                let p2 = SIMD3<Float>(4.0, 5.0, 6.0)
                let dist = simd_distance(p1, p2)
                XCTAssert(dist > .zero)
                
            }
        }
    }

}
