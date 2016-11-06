//
//  JSONTests.swift
//  JSONTests
//
//  Created by Alex Grinman on 11/3/16.
//  Copyright © 2016 KryptCo Inc. All rights reserved.
//

import XCTest
@testable import JSON

struct User:Jsonable, Equatable {
    var name:String
    var age:Int
    var email:String
    var isRegistered:Bool
    var job:Job
    var cars:[Car]
    
    init(name:String, age:Int, email:String, reg:Bool, job:Job, cars:[Car]) {
        self.name = name
        self.age = age
        self.email = email
        self.isRegistered = reg
        self.job = job
        self.cars = cars
    }
    
    init(json: Object) throws {
        name = try json ~> "name"
        age = try json ~> "age"
        email = try json ~> "email"
        isRegistered = try json ~> "is_registered"
        job = try Job(json: json ~> "job")
        cars = try [Car](json: json ~> "cars")
    }
    
    var object:Object {
        return ["name": name,
                "age": age,
                "email": email,
                "is_registered": isRegistered,
                "job": job.object,
                "cars": cars.objects]
    }
}

func ==(l:User, r:User) -> Bool {
    return  l.name == r.name &&
            l.age == r.age &&
            l.email == r.email &&
            l.isRegistered == r.isRegistered &&
            l.job.position == r.job.position &&
            Int(l.job.start.timeIntervalSince1970) == Int(r.job.start.timeIntervalSince1970) &&
            l.cars == r.cars
    
}

struct Job:Jsonable {
    var position:String
    var start:Date
    
    init(pos:String, start:Date) {
        self.position = pos
        self.start = start
    }
    
    init(json:Object) throws {
        position = try json ~> "position"
        start = try Date(timeIntervalSince1970: json ~> "start")
    }
    
    var object:Object {
        return ["position": position,
                "start": start.timeIntervalSince1970
                ]
    }
}

struct Car:Jsonable, Equatable {
    
    var make:String
    var model:String
    var year:Int
    
    init(make:String, model:String, year:Int) {
        self.make = make
        self.model = model
        self.year = year

    }

    
    init(json:Object) throws {
        make = try json ~> "make"
        model = try json ~> "model"
        year = try json ~> "year"
    }
    
    var object:Object {
        return ["make": make,
                "model": model,
                "year": year
        ]
    }
}

func ==(l:Car, r:Car) -> Bool {
    return  l.make == r.make &&
            l.model == r.model &&
            l.year == r.year
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
