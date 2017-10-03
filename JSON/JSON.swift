//
//  JSON.swift
//  JSON
//
//  Created by Alex Grinman on 11/3/16.
//  Copyright © 2016 KryptCo Inc. All rights reserved.
//

import Foundation

/**
    JSON Parsing Error Types
    - badFormat: The raw JSON data could not be cast from `Any` to the inferred type.
    - badValue: The value `v` for an expected key `k` has type mismatch.
    - missingKey: No value exists for the specified key.
 */
public enum ParseError:Error, CustomStringConvertible {
    case badFormat
    case badObjectWritable
    case badValue(k:String, v:Any)
    case missingKey(String)

    public var description:String {
        switch self {
        case .badFormat:
            return "Invalid JSON"
        case .badValue(let (k,v)):
            return "Invalid object value: \(v) for key: \(k)"
        case .missingKey(let k):
            return "Missing dictionary key: \(k)"
        case .badObjectWritable:
            return "Invalid writable object"
        }
    }
}

/** 
    A common protocol for objects that serialize to JSON
    - `JsonReadable`: An object that is initializable from JSON.
    - `JsonWritable`: An object that is serializable to JSON
 */
public protocol Jsonable:JsonReadable, JsonWritable {}


/// JSON Dictionaries are referred to as `Object`
public typealias Object = [String:Any]

/** 
 
    Syntax sugar for reading values from JSON Dictionaries.
 
    - Parameter object: The JSON Object.
    - Parameter key: The key to read from `object`.

    # Type Inference

    The generic type <T> is inferred to ensure the value is of the correct type.
 
    - Returns: The value for `key` in JSON Object `object` if it exists and is of type `T`

    **Example**
    ```
        // var object:Object
        let simple:String = try object ~> "key"
        let complex:Complex = try Complex(json: object ~> "complex")
    ```
    - Throws: `ParseError.missingKey` or `ParseError.badValue`.

 */
public func ~><T>(object: Object, key:String) throws -> T {
    guard let value = object[key] else {
        throw ParseError.missingKey(key)
    }
    
    guard let typedValue = value as? T else {
        throw ParseError.badValue(k: key, v: value)
    }
    
    return typedValue
}

/** 
    JsonReadable must implement `init(json:Object)`
    Use the `~>` operator function for simplicity.
*/
public protocol JsonReadable {
    init(json:Object) throws
}

extension JsonReadable {
    
    /**
        Init a JsonReadable object from raw JSON data bytes
        - Parameter jsonData: The JSON data.
     */
    public init(jsonData:Data) throws {
        let object:Object = try parse(data: jsonData)
        self = try Self(json: object)
    }
    
    /**
     Init a JsonReadable object from a JSON string.
     - Parameter jsonString: The JSON string.
     */
    public init(jsonString:String) throws {
        let object:Object = try parse(string: jsonString)
        self = try Self(json: object)
    }
}

extension Array where Element:JsonReadable {
    /**
     Init an array of JsonReadables with a list of objects.
     - Parameter json: The list of JSON objects.
     */
    public init(json:[Object]) throws {
        self = try json.map({ try Element(json: $0) })
    }
    
    /**
     Init an array of JsonReadables with JSON data bytes.
     - Parameter jsonData: The JSON data.
     */
    public init(jsonData:Data) throws {
        let objectList:[Object] = try parse(data: jsonData)
        try self.init(json: objectList)
    }
    
    /**
     Init an array of JsonReadables with JSON string.
     - Parameter jsonString: The JSON string.
     */
    public init(jsonString:String) throws {
        let objectList:[Object] = try parse(string: jsonString)
        try self.init(json: objectList)
    }
}


/** 
    Common protocol for JSON Primitives.
    - `String`
    - `Int`
    - `Double`
    - `Bool`
 */
public protocol JsonPrimitive {}
extension String:JsonPrimitive {}
extension Int:JsonPrimitive {}
extension Double:JsonPrimitive {}
extension Int64:JsonPrimitive {}
extension UInt64:JsonPrimitive {}
extension Bool:JsonPrimitive {}

/// Array Extension for `JsonPrimitive`
extension Array where Element:JsonPrimitive {
    
    /**
     Init an array of JsonPrimitive with a list of Anys.
     - Parameter json: The list of JSON objects.
     */
    public init(json:[Any]) throws {
        self = []
        for val in json {
            guard let typedVal = val as? Element else {
                throw ParseError.badFormat
            }
            self.append(typedVal)
        }
    }
    
    /**
     Init an array of JsonReadables with JSON data bytes.
     - Parameter jsonData: The JSON data.
     */
    public init(jsonData:Data) throws {
        let anyList:[Any] = try parse(data: jsonData)
        try self.init(json: anyList)
    }
    
    /**
     Init an array of JsonReadables with JSON string.
     - Parameter jsonString: The JSON string.
     */
    public init(jsonString:String) throws {
        let anyList:[Any] = try parse(string: jsonString)
        try self.init(json: anyList)
    }
}


/**
 JsonWritable must implement propertiy `object:Object { get }`.
 Map a `JsonWritable` to a JSON Object.
*/
public protocol JsonWritable {
    var object:Object { get }
}

extension JsonWritable {
    
    /**
         Convenience toJSON functions
     */
    public func jsonData(prettyPrinted:Bool = false) throws -> Data {
        return try JSON.jsonData(for: object, prettyPrinted: prettyPrinted)
    }

    public func jsonString(prettyPrinted:Bool = false) throws -> String {
        return try JSON.jsonString(for: object, prettyPrinted: prettyPrinted)
    }
}

extension Array where Element:JsonWritable {
    
    /**
     Map an array of `JsonWriteable` to an array of JSON objects.
     */
    public var objects:[Object] {
        return self.map({ $0.object })
    }
}

/**
 Transform a `JsonWriteable` to JSON data bytes.
 - Returns: JSON as Data bytes.
 */
public func jsonData(for object:Object, prettyPrinted:Bool = false) throws -> Data {
    
    guard JSONSerialization.isValidJSONObject(object) else {
        throw ParseError.badObjectWritable
    }
    
    if prettyPrinted {
        return try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
    }
    
    return try JSONSerialization.data(withJSONObject: object)
}

/**
 Transform a `JsonWriteable` to a JSON string.
 - Returns: JSON as Data bytes.
 */
public func jsonString(for object:Object, prettyPrinted:Bool = false) throws -> String {
    let data = try jsonData(for: object, prettyPrinted: prettyPrinted)
    
    guard let json = String(data: data, encoding: String.Encoding.utf8)
        else {
            throw ParseError.badFormat
    }
    
    return json
}

/**
    Use std lib to parse JSON data and attempt cast to inferred type `T`.
    - Parameter data: The raw JSON data.
    - Returns: parsed JSON as type `T`.
    - Throws: `ParseError.badFormat` or `JSONSerialization` error
 */
public func parse<T>(data:Data) throws -> T {
    let jsonAny = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
    
    guard let jsonTyped = jsonAny as? T else {
        throw ParseError.badFormat
    }
    
    return jsonTyped
}

/**
 Use std lib to parse a JSON string and attempt cast to inferred type `T`.
 - Parameter data: The raw JSON string.
 - Returns: parsed JSON as type `T`.
 - Throws: `ParseError.badFormat` or `JSONSerialization` error
 */
public func parse<T>(string:String) throws -> T {
    guard let data = string.data(using: String.Encoding.utf8) else {
        throw ParseError.badFormat
    }
    
    return try parse(data: data)
}
