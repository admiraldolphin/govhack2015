//
//  QuestionTimeTests.swift
//  QuestionTimeTests
//
//  Created by Jon Manning on 3/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit
import XCTest

class QuestionTimeTests: XCTestCase {
    
    let host = "localhost"
    let port = 1234
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConnecting() {
        
        let expectation = self.expectationWithDescription("Connected")
        
        var net = Network(host: host, port: 1234) { (newState) in
            
            XCTAssert(newState == .Connected)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
        
        
    }
    
}
