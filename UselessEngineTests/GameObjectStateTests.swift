//
//  GameObjectStateTests.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 6/8/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import XCTest
@testable import UselessEngine

// MARK: - Test Types

fileprivate class TestGameObjectState: GameObjectState {
    
    var id: UUID
    var isOutOfAction: Bool = false
    var fallbackState: GameObjectState?

    init(id: UUID) {
        self.id = id
    }
    
    func enter(with gameObject: GameObject) {

    }
    
}


// MARK: - Tests

class GameObjectStateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquality() throws {
        let id = UUID()
        let state = TestGameObjectState(id: id)
        XCTAssert(state.id == id)
    }

}
