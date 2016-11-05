//
//  JSON.swift
//  JSON
//
//  Created by Alex Grinman on 11/3/16.
//  Copyright © 2016 KryptCo Inc. All rights reserved.
//

import Foundation

//MARK: Erros
enum ParseError:Error, CustomStringConvertible {
    case badFormat
    case badValue(k:String, v:Any)
    case missingKey(String)

    var description:String {
        switch self {
        case .badFormat:
            return "Invalid JSON"
        case .badValue(let (k,v)):
            return "Invalid object value: \(v) for key: \(k)"
        case .missingKey(let k):
            return "Missing dictionary key: \(k)"
        }
    }
}


//MARK: Jsonable
typealias Object = [String:Any]
protocol Jsonable:JsonReadable, JsonWritable {}

func ~><T>(object: Object, key:String) throws -> T {
    guard let value = object[key] else {
        throw ParseError.missingKey(key)
    }
    
    guard let typedValue = value as? T else {
        throw ParseError.badValue(k: key, v: value)
    }
    
    return typedValue
}

//MARK: JsonReadable
protocol JsonReadable {
    init(json:Object) throws
}

extension JsonReadable {
    init(jsonData:Data) throws {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)
        
        guard let object = jsonObject as? Object else {
            throw ParseError.badFormat
        }
        
        self = try Self(json: object)
    }
    
    init(jsonString:String) throws {
        guard let jsonData = jsonString.data(using: String.Encoding.utf8) else {
            throw ParseError.badFormat
        }
        
        try self.init(jsonData: jsonData)
    }
    
    static func List(_ list:[Object]) throws -> [Self] {
        return try list.map({ try Self(json: $0) })
    }
}

extension Array  where Element:JsonReadable {
    init(jsonData:Data) throws {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)
        
        guard let objectList = jsonObject as? [Object] else {
            throw ParseError.badFormat
        }
        
        self = try objectList.map({ try Element(json: $0) })
    }
    
    init(jsonString:String) throws {
        guard let jsonData = jsonString.data(using: String.Encoding.utf8) else {
            throw ParseError.badFormat
        }
        
        try self.init(jsonData: jsonData)
    }
}

protocol JsonPrimitive:JsonReadable {
    init(json:Object) throws

}


//MARK: JsonWritable

protocol JsonWritable {
    var object:Object { get }
}


extension JsonWritable {
    
    func jsonData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: object)
    }
    
    func jsonString() throws -> String {
        let jsonData = try self.jsonData()
        
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8)
        else {
            throw ParseError.badFormat
        }
        
        return json
    }
}



