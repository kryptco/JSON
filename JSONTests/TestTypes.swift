//
//  TestTypes.swift
//  JSON
//
//  Created by Alex Grinman on 11/6/16.
//  Copyright © 2016 KryptCo Inc. All rights reserved.
//

import Foundation
@testable import JSON

enum UserType:Jsonable, Equatable {
    case member(id:String)
    case guest(id:String)
    
    init(json: Object) throws {
        if let memberID:String = try? json ~> "member" {
            self = .member(id: memberID)
            return
        }
        
        self = try .guest(id: json ~> "guest")
    }
    
    var object: Object {
        switch self {
        case .member(let id):
            return ["member": id]
        case .guest(let id):
            return ["guest": id]
        }
    }
}
func ==(l:UserType, r:UserType) -> Bool {
    switch (l,r) {
    case (let .member(idA), let.member(idB)):
        return idA == idB
    case (let .guest(idA), let.guest(idB)):
        return idA == idB
    default:
        return false
    }
}

struct User:Jsonable, Equatable {
    var name:String
    var age:Int
    var email:String
    var userType:UserType
    var isRegistered:Bool
    var job:Job
    var cars:[Car]
    
    init(name:String, age:Int, email:String, ut:UserType, reg:Bool, job:Job, cars:[Car]) {
        self.name = name
        self.age = age
        self.email = email
        self.userType = ut
        self.isRegistered = reg
        self.job = job
        self.cars = cars
    }
    
    init(json: Object) throws {
        name = try json ~> "name"
        age = try json ~> "age"
        email = try json ~> "email"
        userType = try UserType(json: json ~> "type")
        isRegistered = try json ~> "is_registered"
        job = try Job(json: json ~> "job")
        cars = try [Car](json: json ~> "cars")
    }
    
    var object:Object {
        return ["name": name,
                "age": age,
                "email": email,
                "type": userType.object,
                "is_registered": isRegistered,
                "job": job.object,
                "cars": cars.objects]
    }
}

func ==(l:User, r:User) -> Bool {
    return  l.name == r.name &&
        l.age == r.age &&
        l.email == r.email &&
        l.userType == r.userType &&
        l.isRegistered == r.isRegistered &&
        l.job.position == r.job.position &&
        Int(l.job.start.timeIntervalSince1970) == Int(r.job.start.timeIntervalSince1970) &&
        l.cars == r.cars
    
}

class Job:Jsonable {
    var position:String
    var start:Date
    
    init(pos:String, start:Date) {
        self.position = pos
        self.start = start
    }
    
    required init(json:Object) throws {
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


//MARK: Invalid implementation of jsonable
struct Improper:Jsonable {
    var user:User
    var job:Job
    
    init(user:User, job:Job) {
        self.user = user
        self.job  = job
    }
    
    
    
    init(json:Object) throws {
        user = try json ~> "user"
        job = try json ~> "job"
    }
    
    var object:Object {
        return ["user": user,
                "job": job]
    }
}

