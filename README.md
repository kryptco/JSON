<img src="https://github.com/KryptCo/JSON/raw/master/json-icon.png" width="125" height="50"/>

A simple library for parsing and serializing JSON to any Swift data structures. Complete style control with minimal changes.

> Developed at KryptCo (https://krypt.co)

## Install
We recommend managing dependencies with `git` submodules.

`git submodule add git@github.com:KryptCo/JSON.git`

## Use
This library works with all Swift data structures (i.e Structs, Classes, and Enums).


To use with your data structures:

    - JSON to Swift: implement JsonReadable.
    - Swift to JSON: implement JsonWritable.
    - Both: implement Jsonable

## Examples
To convert data structures to JSON and back we do the following.
```swift
do {
    let car = Car(make: "Toyota", model: "Rav4", year: "2004")

    // Serialize to JSON data/string
    let carJson = try car.jsonString()

    // Init object from JSON
    let parsedCar = try Car(jsonString: carJson)
} catch {
    // catch errors here
}
```
To implement a struct that can be initialized from JSON or can be serialized to JSON we do the following.

```swift
struct Car:Jsonable {
    var make:String
    var model:String
    var year:Int

    // use the `~>` operator function
    // to easily parse json into stored properties
    // type inference makes the syntax simple

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
```

> See more examples in `JSONTests/TestTypes.swift`
