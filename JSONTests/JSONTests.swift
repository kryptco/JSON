//
//  JSONTests.swift
//  JSONTests
//
//  Created by Alex Grinman on 11/3/16.
//  Copyright © 2016 KryptCo Inc. All rights reserved.
//

import XCTest
@testable import JSON


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
        let numListJSON = "[1, 2, 3, 4]"

        do {
            let strs = try [String](jsonString: stringListJSON)
            assert(strs.count == 4)
            
            let nums = try [Int](jsonString: numListJSON)
            assert(nums.count == 4)

        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testWritableThenReadable() {
        
        let user = User(
            name: "Alex",
            age: 25,
            email: "alex@krypt.co",
            ut: .member(id: "1234567890"),
            reg: true,
            job: Job(pos: "Founder", start: Date()),
            cars: [
                Car(make: "Toyota", model: "Rav4", year:2004),
                Car(make: "BMW", model: "x3", year:2012)
            ])
        
        
        do {
            let data = try user.jsonData()
            print("User (JSON Data): \(data)")
            
            let string = try user.jsonString()
            print("User (JSON string): \(string)")
            
            let userFromData = try User(jsonData: data)
            assert(userFromData == user)

            let userFromString = try User(jsonString: string)
            assert(userFromString == user)

        } catch {
            XCTFail("\(error)")
        }
    }
    
}
