//
//  JSONTests.swift
//  JSONTests
//
//  Created by Alex Grinman on 11/3/16.
//  Copyright © 2016 KryptCo Inc. All rights reserved.
//

import XCTest
@testable import JSON

struct User:JsonReadable {
    var name:String
    var age:Int
    var email:String
    var isRegistered:Bool
    var job:Job
    var cars:[Car]
    
    init(json: Any) throws {
        name = try json ~> "name"
        age = try json ~> "age"
        email = try json ~> "email"
        isRegistered = try json ~> "is_registered"
        job = try Job(json: try json ~> "job")
        cars = try [Car](json: try json ~> "job")

    }
}

struct Job:JsonReadable {
    
}

struct Car:JsonReadable {
    
}

class JSONTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPrimitives() {
        // String List
        let stringListJSON = "[\"hi\", \"my\", \"name\", \"is\"]"
        
        do {
            let strs = try [String](jsonString: stringListJSON)
            assert(strs.count == 4)
        } catch {
            XCTFail("\(error)")
        }
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
