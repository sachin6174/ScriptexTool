import SwiftUI

enum SyntaxCategory: String, CaseIterable {
    case basics = "Basics"
    case variables = "Variables & Constants"
    case dataTypes = "Data Types"
    case operators = "Operators"
    case collections = "Collections"
    case controlFlow = "Control Flow"
    case functions = "Functions"
    case closures = "Closures"
    case classes = "Classes & Structs"
    case protocols = "Protocols"
    case enums = "Enumerations"
    case extensions = "Extensions"
    case generics = "Generics"
    case errorHandling = "Error Handling"
    case memory = "Memory Management"
    case concurrency = "Concurrency"
    case propertyWrappers = "Property Wrappers"
    case advanced = "Advanced"
    
    var icon: String {
        switch self {
        case .basics: return "book.fill"
        case .variables: return "textformat.123"
        case .dataTypes: return "square.stack.3d.up"
        case .operators: return "plus.forwardslash.minus"
        case .collections: return "list.bullet"
        case .controlFlow: return "arrow.triangle.branch"
        case .functions: return "function"
        case .closures: return "curlybraces"
        case .classes: return "building.2"
        case .protocols: return "doc.text"
        case .enums: return "list.number"
        case .extensions: return "plus.rectangle.on.folder"
        case .generics: return "diamond"
        case .errorHandling: return "exclamationmark.triangle"
        case .memory: return "memorychip"
        case .concurrency: return "timer"
        case .propertyWrappers: return "wrapper.top"
        case .advanced: return "brain"
        }
    }
    
    var color: Color {
        switch self {
        case .basics: return .blue
        case .variables: return .green
        case .dataTypes: return .orange
        case .operators: return .red
        case .collections: return .purple
        case .controlFlow: return Color(red: 0.0, green: 0.8, blue: 1.0)
        case .functions: return .yellow
        case .closures: return .pink
        case .classes: return Color(red: 0.6, green: 0.4, blue: 0.2)
        case .protocols: return Color(red: 0.294, green: 0.0, blue: 0.510)
        case .enums: return Color(red: 0.0, green: 1.0, blue: 0.8)
        case .extensions: return Color(red: 0.0, green: 0.502, blue: 0.502)
        case .generics: return Color(red: 0.5, green: 0.0, blue: 0.5)
        case .errorHandling: return .red
        case .memory: return .gray
        case .concurrency: return Color(red: 0.0, green: 0.5, blue: 0.0)
        case .propertyWrappers: return Color(red: 1.0, green: 0.5, blue: 0.0)
        case .advanced: return Color(red: 0.3, green: 0.3, blue: 0.7)
        }
    }
}

struct SwiftSyntaxItem: Identifiable {
    let id = UUID()
    let title: String
    let code: String
    let explanation: String
    let category: SyntaxCategory
    
    init(_ title: String, code: String, explanation: String, category: SyntaxCategory) {
        self.title = title
        self.code = code
        self.explanation = explanation
        self.category = category
    }
    
    static let allSyntaxItems: [SwiftSyntaxItem] = [
        // MARK: - Basics
        SwiftSyntaxItem("Hello World", 
            code: """
            print("Hello, World!")
            """,
            explanation: "Basic print statement to output text to console",
            category: .basics),
            
        SwiftSyntaxItem("Comments", 
            code: """
            // Single line comment
            
            /*
             Multi-line comment
             Can span multiple lines
             */
            
            /// Documentation comment
            /// Used for API documentation
            """,
            explanation: "Different types of comments in Swift",
            category: .basics),
            
        SwiftSyntaxItem("Import Statements", 
            code: """
            import Foundation
            import UIKit
            import SwiftUI
            """,
            explanation: "Import frameworks and modules",
            category: .basics),
            
        // MARK: - Variables & Constants
        SwiftSyntaxItem("Variables and Constants", 
            code: """
            let constant = "Cannot change"
            var variable = "Can change"
            variable = "Changed!"
            
            let implicitInt = 42
            let explicitInt: Int = 42
            """,
            explanation: "Declare constants with 'let' and variables with 'var'",
            category: .variables),
            
        SwiftSyntaxItem("Multiple Assignment", 
            code: """
            let (x, y) = (1, 2)
            var a = 10, b = 20, c = 30
            """,
            explanation: "Assign multiple values at once",
            category: .variables),
            
        // MARK: - Data Types
        SwiftSyntaxItem("Basic Types", 
            code: """
            let integer: Int = 42
            let double: Double = 3.14159
            let float: Float = 3.14
            let boolean: Bool = true
            let character: Character = "A"
            let string: String = "Hello"
            """,
            explanation: "Swift's fundamental data types",
            category: .dataTypes),
            
        SwiftSyntaxItem("Type Inference", 
            code: """
            let inferredInt = 42        // Int
            let inferredDouble = 3.14   // Double
            let inferredString = "Hi"   // String
            let inferredBool = true     // Bool
            """,
            explanation: "Swift can infer types automatically",
            category: .dataTypes),
            
        SwiftSyntaxItem("Optionals", 
            code: """
            var optionalString: String? = "Hello"
            optionalString = nil
            
            let number: Int? = Int("123")
            
            // Optional binding
            if let value = optionalString {
                print("Value: \\(value)")
            }
            
            // Force unwrapping (dangerous!)
            let forced = optionalString!
            """,
            explanation: "Handle values that might be nil",
            category: .dataTypes),
            
        SwiftSyntaxItem("Type Casting", 
            code: """
            let someDouble = 3.14159
            let someInt = Int(someDouble)
            
            class Animal {}
            class Dog: Animal {}
            
            let animal: Animal = Dog()
            
            // Type checking
            if animal is Dog {
                print("It's a dog!")
            }
            
            // Downcasting
            if let dog = animal as? Dog {
                print("Successfully cast to Dog")
            }
            """,
            explanation: "Convert between types and check types",
            category: .dataTypes),
            
        // MARK: - Operators
        SwiftSyntaxItem("Arithmetic Operators", 
            code: """
            let sum = 5 + 3         // Addition
            let diff = 10 - 4       // Subtraction
            let product = 6 * 7     // Multiplication
            let quotient = 15 / 3   // Division
            let remainder = 17 % 5  // Modulo
            
            var counter = 0
            counter += 1            // Compound assignment
            counter -= 1
            counter *= 2
            counter /= 2
            """,
            explanation: "Basic mathematical operations",
            category: .operators),
            
        SwiftSyntaxItem("Comparison Operators", 
            code: """
            let a = 5, b = 10
            
            let equal = (a == b)        // false
            let notEqual = (a != b)     // true
            let greater = (a > b)       // false
            let less = (a < b)          // true
            let greaterEqual = (a >= b) // false
            let lessEqual = (a <= b)    // true
            """,
            explanation: "Compare values",
            category: .operators),
            
        SwiftSyntaxItem("Logical Operators", 
            code: """
            let p = true
            let q = false
            
            let and = p && q        // Logical AND
            let or = p || q         // Logical OR
            let not = !p            // Logical NOT
            
            // Short-circuit evaluation
            if p && someFunction() {
                // someFunction() only called if p is true
            }
            """,
            explanation: "Boolean logic operations",
            category: .operators),
            
        SwiftSyntaxItem("Range Operators", 
            code: """
            // Closed range
            for i in 1...5 {
                print(i) // 1, 2, 3, 4, 5
            }
            
            // Half-open range
            for i in 1..<5 {
                print(i) // 1, 2, 3, 4
            }
            
            // One-sided ranges
            let numbers = [1, 2, 3, 4, 5]
            numbers[2...]  // [3, 4, 5]
            numbers[...2]  // [1, 2, 3]
            numbers[..<2]  // [1, 2]
            """,
            explanation: "Create ranges of values",
            category: .operators),
            
        // MARK: - Collections
        SwiftSyntaxItem("Arrays", 
            code: """
            // Creating arrays
            var fruits = ["Apple", "Banana", "Orange"]
            var numbers: [Int] = [1, 2, 3, 4, 5]
            var emptyArray: [String] = []
            var anotherEmpty = [String]()
            
            // Array operations
            fruits.append("Grape")
            fruits.insert("Mango", at: 0)
            fruits.remove(at: 1)
            
            // Accessing elements
            let first = fruits[0]
            let count = fruits.count
            let isEmpty = fruits.isEmpty
            """,
            explanation: "Ordered collections of elements",
            category: .collections),
            
        SwiftSyntaxItem("Dictionaries", 
            code: """
            // Creating dictionaries
            var capitals = ["France": "Paris", "Japan": "Tokyo"]
            var scores: [String: Int] = [:]
            var empty = [String: Int]()
            
            // Dictionary operations
            capitals["Italy"] = "Rome"
            capitals.updateValue("London", forKey: "UK")
            
            // Accessing values
            if let capital = capitals["France"] {
                print("Capital of France is \\(capital)")
            }
            
            // Iteration
            for (country, capital) in capitals {
                print("\\(country): \\(capital)")
            }
            """,
            explanation: "Key-value pair collections",
            category: .collections),
            
        SwiftSyntaxItem("Sets", 
            code: """
            // Creating sets
            var colors: Set<String> = ["Red", "Green", "Blue"]
            var numbers = Set([1, 2, 3, 4, 5])
            
            // Set operations
            colors.insert("Yellow")
            colors.remove("Red")
            
            let containsBlue = colors.contains("Blue")
            
            // Set algebra
            let set1: Set = [1, 2, 3, 4]
            let set2: Set = [3, 4, 5, 6]
            
            let union = set1.union(set2)           // [1, 2, 3, 4, 5, 6]
            let intersection = set1.intersection(set2) // [3, 4]
            let difference = set1.subtracting(set2)    // [1, 2]
            """,
            explanation: "Unordered collections of unique elements",
            category: .collections),
            
        // MARK: - Control Flow
        SwiftSyntaxItem("If Statements", 
            code: """
            let temperature = 25
            
            if temperature > 30 {
                print("It's hot!")
            } else if temperature > 20 {
                print("It's warm")
            } else {
                print("It's cool")
            }
            
            // Ternary operator
            let message = temperature > 25 ? "Warm" : "Cool"
            """,
            explanation: "Conditional execution of code",
            category: .controlFlow),
            
        SwiftSyntaxItem("Switch Statements", 
            code: """
            let grade = "B"
            
            switch grade {
            case "A":
                print("Excellent!")
            case "B", "C":
                print("Good job")
            case "D":
                print("You can do better")
            default:
                print("Invalid grade")
            }
            
            // Switch with ranges
            let score = 85
            switch score {
            case 90...100:
                print("A")
            case 80..<90:
                print("B")
            case 70..<80:
                print("C")
            default:
                print("F")
            }
            """,
            explanation: "Multi-way conditional branching",
            category: .controlFlow),
            
        SwiftSyntaxItem("Loops", 
            code: """
            // For-in loop
            for i in 1...5 {
                print(i)
            }
            
            let names = ["Alice", "Bob", "Charlie"]
            for name in names {
                print("Hello, \\(name)!")
            }
            
            // While loop
            var count = 0
            while count < 3 {
                print(count)
                count += 1
            }
            
            // Repeat-while loop
            repeat {
                print("This runs at least once")
                count -= 1
            } while count > 0
            """,
            explanation: "Iterate over sequences or repeat code",
            category: .controlFlow),
            
        SwiftSyntaxItem("Control Transfer", 
            code: """
            for i in 1...10 {
                if i == 3 {
                    continue  // Skip this iteration
                }
                if i == 8 {
                    break     // Exit the loop
                }
                print(i)
            }
            
            // Labeled statements
            outerLoop: for i in 1...3 {
                innerLoop: for j in 1...3 {
                    if i == 2 && j == 2 {
                        break outerLoop  // Break out of outer loop
                    }
                    print("\\(i), \\(j)")
                }
            }
            
            // Guard statements
            func processAge(_ age: Int?) {
                guard let age = age, age >= 0 else {
                    print("Invalid age")
                    return
                }
                print("Age is \\(age)")
            }
            """,
            explanation: "Control the flow of execution",
            category: .controlFlow),
            
        // MARK: - Functions
        SwiftSyntaxItem("Basic Functions", 
            code: """
            // Simple function
            func greet() {
                print("Hello!")
            }
            greet()
            
            // Function with parameters
            func greet(name: String) {
                print("Hello, \\(name)!")
            }
            greet(name: "Alice")
            
            // Function with return value
            func add(a: Int, b: Int) -> Int {
                return a + b
            }
            let sum = add(a: 5, b: 3)
            """,
            explanation: "Reusable blocks of code",
            category: .functions),
            
        SwiftSyntaxItem("Function Parameters", 
            code: """
            // External and internal parameter names
            func greet(person name: String, from city: String) {
                print("Hello \\(name) from \\(city)!")
            }
            greet(person: "Alice", from: "Paris")
            
            // Default parameters
            func greet(name: String, loudly: Bool = false) {
                let message = "Hello, \\(name)!"
                print(loudly ? message.uppercased() : message)
            }
            greet(name: "Bob")          // Uses default
            greet(name: "Bob", loudly: true)
            
            // Variadic parameters
            func average(numbers: Double...) -> Double {
                let total = numbers.reduce(0, +)
                return total / Double(numbers.count)
            }
            let avg = average(numbers: 1, 2, 3, 4, 5)
            """,
            explanation: "Different types of function parameters",
            category: .functions),
            
        SwiftSyntaxItem("inout Parameters", 
            code: """
            func swapTwoInts(_ a: inout Int, _ b: inout Int) {
                let temp = a
                a = b
                b = temp
            }
            
            var x = 10
            var y = 20
            swapTwoInts(&x, &y)
            print("x: \\(x), y: \\(y)") // x: 20, y: 10
            """,
            explanation: "Modify parameters passed to functions",
            category: .functions),
            
        // MARK: - Closures
        SwiftSyntaxItem("Basic Closures", 
            code: """
            // Full closure syntax
            let multiply = { (a: Int, b: Int) -> Int in
                return a * b
            }
            let result = multiply(4, 5)
            
            // Simplified closure
            let add = { (a: Int, b: Int) in a + b }
            
            // Closure with no parameters
            let sayHello = { () -> Void in
                print("Hello!")
            }
            sayHello()
            """,
            explanation: "Self-contained blocks of functionality",
            category: .closures),
            
        SwiftSyntaxItem("Closures with Arrays", 
            code: """
            let numbers = [1, 2, 3, 4, 5]
            
            // Using map
            let doubled = numbers.map { $0 * 2 }
            
            // Using filter
            let evens = numbers.filter { $0 % 2 == 0 }
            
            // Using reduce
            let sum = numbers.reduce(0) { $0 + $1 }
            
            // Using sort
            let names = ["Charlie", "Alice", "Bob"]
            let sorted = names.sorted { $0 < $1 }
            
            // Trailing closure syntax
            let transformed = numbers.map { number in
                return number * number
            }
            """,
            explanation: "Using closures with collection methods",
            category: .closures),
            
        SwiftSyntaxItem("Escaping Closures", 
            code: """
            var completionHandlers: [() -> Void] = []
            
            func doSomethingAsync(completion: @escaping () -> Void) {
                completionHandlers.append(completion)
            }
            
            // Autoclosures
            func assert(_ condition: @autoclosure () -> Bool, 
                       message: @autoclosure () -> String) {
                if !condition() {
                    print("Assertion failed: \\(message())")
                }
            }
            
            let x = 5
            assert(x > 10, message: "x should be greater than 10")
            """,
            explanation: "Closures that outlive the function call",
            category: .closures),
            
        // MARK: - Classes & Structs
        SwiftSyntaxItem("Structs", 
            code: """
            struct Point {
                var x: Double
                var y: Double
                
                // Computed property
                var magnitude: Double {
                    return sqrt(x * x + y * y)
                }
                
                // Method
                mutating func moveBy(dx: Double, dy: Double) {
                    x += dx
                    y += dy
                }
                
                // Static method
                static func origin() -> Point {
                    return Point(x: 0, y: 0)
                }
            }
            
            var point = Point(x: 3, y: 4)
            print(point.magnitude)  // 5.0
            point.moveBy(dx: 1, dy: 1)
            """,
            explanation: "Value types that group related data and functionality",
            category: .classes),
            
        SwiftSyntaxItem("Classes", 
            code: """
            class Vehicle {
                var speed: Double = 0.0
                let maxSpeed: Double
                
                init(maxSpeed: Double) {
                    self.maxSpeed = maxSpeed
                }
                
                func accelerate() {
                    speed = min(speed + 10, maxSpeed)
                }
                
                deinit {
                    print("Vehicle deallocated")
                }
            }
            
            class Car: Vehicle {
                let brand: String
                
                init(brand: String, maxSpeed: Double) {
                    self.brand = brand
                    super.init(maxSpeed: maxSpeed)
                }
                
                override func accelerate() {
                    super.accelerate()
                    print("\\(brand) accelerating")
                }
            }
            
            let car = Car(brand: "Toyota", maxSpeed: 180)
            car.accelerate()
            """,
            explanation: "Reference types that support inheritance",
            category: .classes),
            
        SwiftSyntaxItem("Properties", 
            code: """
            class Circle {
                var radius: Double
                
                // Computed properties
                var area: Double {
                    get {
                        return Double.pi * radius * radius
                    }
                }
                
                var diameter: Double {
                    get {
                        return radius * 2
                    }
                    set {
                        radius = newValue / 2
                    }
                }
                
                // Property observers
                var name: String = "Circle" {
                    willSet {
                        print("About to set name to \\(newValue)")
                    }
                    didSet {
                        print("Name changed from \\(oldValue) to \\(name)")
                    }
                }
                
                init(radius: Double) {
                    self.radius = radius
                }
            }
            """,
            explanation: "Different types of properties in classes and structs",
            category: .classes),
            
        // MARK: - Protocols
        SwiftSyntaxItem("Basic Protocols", 
            code: """
            protocol Drawable {
                func draw()
                var area: Double { get }
                var perimeter: Double { get set }
            }
            
            struct Rectangle: Drawable {
                var width: Double
                var height: Double
                
                var area: Double {
                    return width * height
                }
                
                var perimeter: Double {
                    get { return 2 * (width + height) }
                    set { 
                        // Assuming square for simplicity
                        let side = newValue / 4
                        width = side
                        height = side
                    }
                }
                
                func draw() {
                    print("Drawing rectangle \\(width)x\\(height)")
                }
            }
            
            let rect: Drawable = Rectangle(width: 10, height: 5)
            rect.draw()
            """,
            explanation: "Define a blueprint of methods and properties",
            category: .protocols),
            
        SwiftSyntaxItem("Protocol Extensions", 
            code: """
            protocol Identifiable {
                var id: String { get }
            }
            
            extension Identifiable {
                func identify() {
                    print("My ID is \\(id)")
                }
            }
            
            struct User: Identifiable {
                let id: String
                let name: String
            }
            
            let user = User(id: "123", name: "Alice")
            user.identify()  // Uses default implementation
            
            // Protocol composition
            protocol Named {
                var name: String { get }
            }
            
            func greetUser(_ user: User & Named & Identifiable) {
                print("Hello \\(user.name) with ID \\(user.id)")
            }
            """,
            explanation: "Add default implementations and combine protocols",
            category: .protocols),
            
        // MARK: - Enumerations
        SwiftSyntaxItem("Basic Enums", 
            code: """
            enum Direction {
                case north
                case south
                case east
                case west
            }
            
            // Shorter syntax
            enum Planet {
                case mercury, venus, earth, mars
            }
            
            var direction = Direction.north
            direction = .south  // Type can be inferred
            
            switch direction {
            case .north:
                print("Going north")
            case .south:
                print("Going south")
            case .east:
                print("Going east")
            case .west:
                print("Going west")
            }
            """,
            explanation: "Define a group of related values",
            category: .enums),
            
        SwiftSyntaxItem("Enums with Values", 
            code: """
            enum NetworkResponse {
                case success(String)
                case failure(Int, String)
            }
            
            let response = NetworkResponse.success("Data received")
            
            switch response {
            case .success(let data):
                print("Success: \\(data)")
            case .failure(let code, let message):
                print("Error \\(code): \\(message)")
            }
            
            // Raw values
            enum HTTPStatusCode: Int {
                case ok = 200
                case notFound = 404
                case serverError = 500
            }
            
            if let status = HTTPStatusCode(rawValue: 200) {
                print("Status: \\(status)")
            }
            """,
            explanation: "Enums can store associated values or raw values",
            category: .enums),
            
        SwiftSyntaxItem("Enum Methods", 
            code: """
            enum TrafficLight {
                case red, yellow, green
                
                func duration() -> TimeInterval {
                    switch self {
                    case .red:
                        return 30
                    case .yellow:
                        return 5
                    case .green:
                        return 25
                    }
                }
                
                mutating func next() {
                    switch self {
                    case .red:
                        self = .green
                    case .yellow:
                        self = .red
                    case .green:
                        self = .yellow
                    }
                }
            }
            
            var light = TrafficLight.red
            print("Duration: \\(light.duration())")
            light.next()
            """,
            explanation: "Enums can have methods and computed properties",
            category: .enums),
            
        // MARK: - Extensions
        SwiftSyntaxItem("Basic Extensions", 
            code: """
            extension String {
                func reversed() -> String {
                    return String(self.reversed())
                }
                
                var wordCount: Int {
                    return self.components(separatedBy: .whitespacesAndNewlines)
                              .filter { !$0.isEmpty }.count
                }
            }
            
            let text = "Hello World"
            print(text.reversed())    // "dlroW olleH"
            print(text.wordCount)     // 2
            
            extension Int {
                func squared() -> Int {
                    return self * self
                }
                
                var isEven: Bool {
                    return self % 2 == 0
                }
            }
            
            print(5.squared())  // 25
            print(4.isEven)     // true
            """,
            explanation: "Add new functionality to existing types",
            category: .extensions),
            
        SwiftSyntaxItem("Protocol Conformance Extensions", 
            code: """
            protocol Describable {
                func describe() -> String
            }
            
            extension Int: Describable {
                func describe() -> String {
                    return "The number \\(self)"
                }
            }
            
            extension Array: Describable {
                func describe() -> String {
                    return "Array with \\(count) elements"
                }
            }
            
            let numbers = [1, 2, 3]
            print(numbers.describe())  // "Array with 3 elements"
            print(42.describe())       // "The number 42"
            """,
            explanation: "Make existing types conform to protocols",
            category: .extensions),
            
        // MARK: - Generics
        SwiftSyntaxItem("Generic Functions", 
            code: """
            func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
                let temp = a
                a = b
                b = temp
            }
            
            var x = 10, y = 20
            swapTwoValues(&x, &y)
            
            var str1 = "Hello", str2 = "World"
            swapTwoValues(&str1, &str2)
            
            func findIndex<T: Equatable>(of valueToFind: T, in array: [T]) -> Int? {
                for (index, value) in array.enumerated() {
                    if value == valueToFind {
                        return index
                    }
                }
                return nil
            }
            
            let index = findIndex(of: "World", in: ["Hello", "World", "Swift"])
            """,
            explanation: "Write flexible, reusable functions",
            category: .generics),
            
        SwiftSyntaxItem("Generic Types", 
            code: """
            struct Stack<Element> {
                private var items: [Element] = []
                
                mutating func push(_ item: Element) {
                    items.append(item)
                }
                
                mutating func pop() -> Element? {
                    return items.popLast()
                }
                
                func peek() -> Element? {
                    return items.last
                }
                
                var isEmpty: Bool {
                    return items.isEmpty
                }
                
                var count: Int {
                    return items.count
                }
            }
            
            var stringStack = Stack<String>()
            stringStack.push("Hello")
            stringStack.push("World")
            
            var intStack = Stack<Int>()
            intStack.push(42)
            intStack.push(100)
            """,
            explanation: "Create generic data structures",
            category: .generics),
            
        SwiftSyntaxItem("Generic Constraints", 
            code: """
            // Where clause
            func allItemsMatch<C1: Collection, C2: Collection>
                (_ someContainer: C1, _ anotherContainer: C2) -> Bool
                where C1.Element == C2.Element, C1.Element: Equatable {
                
                if someContainer.count != anotherContainer.count {
                    return false
                }
                
                for (item1, item2) in zip(someContainer, anotherContainer) {
                    if item1 != item2 {
                        return false
                    }
                }
                return true
            }
            
            let array1 = [1, 2, 3]
            let array2 = [1, 2, 3]
            print(allItemsMatch(array1, array2))  // true
            
            // Associated types in protocols
            protocol Container {
                associatedtype Item
                mutating func append(_ item: Item)
                var count: Int { get }
            }
            """,
            explanation: "Constrain generic types with requirements",
            category: .generics),
            
        // MARK: - Error Handling
        SwiftSyntaxItem("Error Types", 
            code: """
            enum NetworkError: Error {
                case noConnection
                case timeout
                case serverError(Int)
                case invalidData
            }
            
            enum ValidationError: Error, LocalizedError {
                case tooShort
                case tooLong
                case invalidFormat
                
                var errorDescription: String? {
                    switch self {
                    case .tooShort:
                        return "Input is too short"
                    case .tooLong:
                        return "Input is too long"
                    case .invalidFormat:
                        return "Invalid format"
                    }
                }
            }
            """,
            explanation: "Define custom error types",
            category: .errorHandling),
            
        SwiftSyntaxItem("Throwing Functions", 
            code: """
            func validatePassword(_ password: String) throws {
                if password.count < 8 {
                    throw ValidationError.tooShort
                }
                if password.count > 50 {
                    throw ValidationError.tooLong
                }
                if !password.contains(where: { $0.isNumber }) {
                    throw ValidationError.invalidFormat
                }
            }
            
            // Using throwing functions
            do {
                try validatePassword("abc")
            } catch ValidationError.tooShort {
                print("Password is too short")
            } catch ValidationError.tooLong {
                print("Password is too long")  
            } catch {
                print("Other error: \\(error)")
            }
            
            // Try? and try!
            let result = try? validatePassword("password123")  // nil if throws
            // let forced = try! validatePassword("validpass123")  // Crashes if throws
            """,
            explanation: "Handle errors with do-catch blocks",
            category: .errorHandling),
            
        SwiftSyntaxItem("Result Type", 
            code: """
            func fetchData() -> Result<String, NetworkError> {
                let success = Bool.random()
                
                if success {
                    return .success("Data loaded successfully")
                } else {
                    return .failure(.noConnection)
                }
            }
            
            let result = fetchData()
            switch result {
            case .success(let data):
                print("Success: \\(data)")
            case .failure(let error):
                print("Error: \\(error)")
            }
            
            // Using Result with map and flatMap
            let mappedResult = result.map { data in
                data.uppercased()
            }
            """,
            explanation: "Use Result type for success/failure operations",
            category: .errorHandling),
            
        // MARK: - Memory Management
        SwiftSyntaxItem("ARC and References", 
            code: """
            class Person {
                let name: String
                var apartment: Apartment?
                
                init(name: String) {
                    self.name = name
                    print("\\(name) is initialized")
                }
                
                deinit {
                    print("\\(name) is deinitialized")
                }
            }
            
            class Apartment {
                let unit: String
                weak var tenant: Person?  // Weak reference to avoid retain cycle
                
                init(unit: String) {
                    self.unit = unit
                }
                
                deinit {
                    print("Apartment \\(unit) is deinitialized")
                }
            }
            
            var john: Person? = Person(name: "John")
            var apartment: Apartment? = Apartment(unit: "4A")
            
            john?.apartment = apartment
            apartment?.tenant = john
            
            john = nil      // Person can be deallocated due to weak reference
            apartment = nil
            """,
            explanation: "Automatic Reference Counting and memory management",
            category: .memory),
            
        SwiftSyntaxItem("Unowned References", 
            code: """
            class Customer {
                let name: String
                var creditCard: CreditCard?
                
                init(name: String) {
                    self.name = name
                }
                
                deinit {
                    print("Customer \\(name) is deinitialized")
                }
            }
            
            class CreditCard {
                let number: UInt64
                unowned let customer: Customer  // Unowned reference
                
                init(number: UInt64, customer: Customer) {
                    self.number = number
                    self.customer = customer
                }
                
                deinit {
                    print("Card #\\(number) is deinitialized")
                }
            }
            
            var alice: Customer? = Customer(name: "Alice")
            alice?.creditCard = CreditCard(number: 1234, customer: alice!)
            alice = nil  // Both objects are deallocated
            """,
            explanation: "Use unowned references for non-optional relationships",
            category: .memory),
            
        // MARK: - Concurrency
        SwiftSyntaxItem("Async/Await", 
            code: """
            // Async function
            func fetchUserData(id: Int) async throws -> String {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
                return "User data for ID \\(id)"
            }
            
            // Calling async functions
            func loadUserProfile() async {
                do {
                    let userData = try await fetchUserData(id: 123)
                    print("Loaded: \\(userData)")
                } catch {
                    print("Failed to load user data: \\(error)")
                }
            }
            
            // Multiple concurrent operations
            func fetchMultipleUsers() async throws {
                async let user1 = fetchUserData(id: 1)
                async let user2 = fetchUserData(id: 2)
                async let user3 = fetchUserData(id: 3)
                
                let users = try await [user1, user2, user3]
                print("All users loaded: \\(users)")
            }
            """,
            explanation: "Modern asynchronous programming with async/await",
            category: .concurrency),
            
        SwiftSyntaxItem("Tasks and TaskGroups", 
            code: """
            import Foundation
            
            // Creating tasks
            func performBackgroundWork() {
                Task {
                    print("Background work started")
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    print("Background work completed")
                }
            }
            
            // Task groups for structured concurrency
            func processImages(_ imageURLs: [String]) async throws {
                try await withTaskGroup(of: String.self) { group in
                    for url in imageURLs {
                        group.addTask {
                            // Simulate image processing
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            return "Processed \\(url)"
                        }
                    }
                    
                    for try await result in group {
                        print("Completed: \\(result)")
                    }
                }
            }
            
            // Cancellation
            let task = Task {
                for i in 1...10 {
                    try Task.checkCancellation()
                    print("Working on step \\(i)")
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
            }
            
            // Cancel the task after 2 seconds
            Task {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                task.cancel()
            }
            """,
            explanation: "Structured concurrency with Tasks and TaskGroups",
            category: .concurrency),
            
        SwiftSyntaxItem("Actors", 
            code: """
            actor BankAccount {
                private var balance: Double = 0
                
                func deposit(amount: Double) {
                    balance += amount
                    print("Deposited \\(amount). New balance: \\(balance)")
                }
                
                func withdraw(amount: Double) -> Bool {
                    if balance >= amount {
                        balance -= amount
                        print("Withdrew \\(amount). New balance: \\(balance)")
                        return true
                    } else {
                        print("Insufficient funds")
                        return false
                    }
                }
                
                func getBalance() -> Double {
                    return balance
                }
            }
            
            // Using actors
            func bankOperations() async {
                let account = BankAccount()
                
                await account.deposit(amount: 100)
                await account.deposit(amount: 50)
                
                let success = await account.withdraw(amount: 75)
                let currentBalance = await account.getBalance()
                print("Current balance: \\(currentBalance)")
            }
            """,
            explanation: "Thread-safe reference types with actors",
            category: .concurrency),
            
        // MARK: - Property Wrappers
        SwiftSyntaxItem("Basic Property Wrapper", 
            code: """
            @propertyWrapper
            struct Capitalized {
                private var value = ""
                
                var wrappedValue: String {
                    get { value }
                    set { value = newValue.capitalized }
                }
            }
            
            struct User {
                @Capitalized var firstName: String
                @Capitalized var lastName: String
            }
            
            var user = User()
            user.firstName = "john"     // Automatically capitalized
            user.lastName = "doe"       // Automatically capitalized
            print("\\(user.firstName) \\(user.lastName)")  // "John Doe"
            
            // Property wrapper with parameters
            @propertyWrapper
            struct Clamped<Value: Comparable> {
                var value: Value
                let range: ClosedRange<Value>
                
                init(wrappedValue: Value, _ range: ClosedRange<Value>) {
                    self.range = range
                    self.value = max(range.lowerBound, min(range.upperBound, wrappedValue))
                }
                
                var wrappedValue: Value {
                    get { value }
                    set { value = max(range.lowerBound, min(range.upperBound, newValue)) }
                }
            }
            
            struct Game {
                @Clamped(0...100) var health = 100
            }
            """,
            explanation: "Encapsulate property access patterns",
            category: .propertyWrappers),
            
        SwiftSyntaxItem("SwiftUI Property Wrappers", 
            code: """
            // Common SwiftUI property wrappers
            struct ContentView: View {
                @State private var count = 0
                @Binding var isPresented: Bool
                @ObservedObject var userData: UserData
                @EnvironmentObject var settings: Settings
                @Environment(\\.colorScheme) var colorScheme
                
                var body: some View {
                    VStack {
                        Text("Count: \\(count)")
                        Button("Increment") {
                            count += 1
                        }
                        
                        Text("Color scheme: \\(colorScheme == .dark ? "Dark" : "Light")")
                    }
                }
            }
            
            // Custom UserDefaults property wrapper
            @propertyWrapper
            struct UserDefault<T> {
                let key: String
                let defaultValue: T
                
                var wrappedValue: T {
                    get {
                        UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
                    }
                    set {
                        UserDefaults.standard.set(newValue, forKey: key)
                    }
                }
            }
            
            struct AppSettings {
                @UserDefault(key: "username", defaultValue: "")
                static var username: String
                
                @UserDefault(key: "isFirstLaunch", defaultValue: true)
                static var isFirstLaunch: Bool
            }
            """,
            explanation: "Property wrappers in SwiftUI and custom implementations",
            category: .propertyWrappers),
            
        // MARK: - Advanced
        SwiftSyntaxItem("Key Paths", 
            code: """
            struct Person {
                var name: String
                var age: Int
                var address: Address
            }
            
            struct Address {
                var street: String
                var city: String
            }
            
            let person = Person(
                name: "Alice", 
                age: 30, 
                address: Address(street: "Main St", city: "NYC")
            )
            
            // Key paths
            let nameKeyPath = \\Person.name
            let ageKeyPath = \\Person.age
            let cityKeyPath = \\Person.address.city
            
            let name = person[keyPath: nameKeyPath]  // "Alice"
            let city = person[keyPath: cityKeyPath]  // "NYC"
            
            // Using key paths with collections
            let people = [
                Person(name: "Alice", age: 30, address: Address(street: "Main St", city: "NYC")),
                Person(name: "Bob", age: 25, address: Address(street: "Oak Ave", city: "LA"))
            ]
            
            let names = people.map(\\.name)        // ["Alice", "Bob"]
            let ages = people.map(\\.age)          // [30, 25]
            let sortedByAge = people.sorted(by: { $0[keyPath: \\.age] < $1[keyPath: \\.age] })
            """,
            explanation: "Reference properties and methods as values",
            category: .advanced),
            
        SwiftSyntaxItem("Dynamic Member Lookup", 
            code: """
            @dynamicMemberLookup
            struct JSON {
                private let dictionary: [String: Any]
                
                init(_ dictionary: [String: Any]) {
                    self.dictionary = dictionary
                }
                
                subscript(dynamicMember key: String) -> Any? {
                    return dictionary[key]
                }
                
                subscript<T>(dynamicMember key: String) -> T? {
                    return dictionary[key] as? T
                }
            }
            
            let json = JSON([
                "name": "Alice",
                "age": 30,
                "isActive": true
            ])
            
            let name: String? = json.name       // "Alice"
            let age: Int? = json.age           // 30
            let isActive: Bool? = json.isActive // true
            let unknown = json.unknown         // nil
            
            // @dynamicCallable
            @dynamicCallable
            struct Calculator {
                func dynamicallyCall(withArguments args: [Int]) -> Int {
                    return args.reduce(0, +)
                }
                
                func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Int {
                    return args.reduce(0) { $0 + $1.value }
                }
            }
            
            let calc = Calculator()
            let sum1 = calc(1, 2, 3, 4, 5)  // 15
            let sum2 = calc(a: 1, b: 2, c: 3)  // 6
            """,
            explanation: "Dynamic member lookup and callable syntax",
            category: .advanced),
            
        SwiftSyntaxItem("Result Builders", 
            code: """
            @resultBuilder
            struct HTMLBuilder {
                static func buildBlock(_ components: String...) -> String {
                    return components.joined()
                }
                
                static func buildEither(first component: String) -> String {
                    return component
                }
                
                static func buildEither(second component: String) -> String {
                    return component
                }
                
                static func buildOptional(_ component: String?) -> String {
                    return component ?? ""
                }
                
                static func buildArray(_ components: [String]) -> String {
                    return components.joined()
                }
            }
            
            func html(@HTMLBuilder content: () -> String) -> String {
                return "<html><body>\\(content())</body></html>"
            }
            
            func div(@HTMLBuilder content: () -> String) -> String {
                return "<div>\\(content())</div>"
            }
            
            func p(_ text: String) -> String {
                return "<p>\\(text)</p>"
            }
            
            let webpage = html {
                div {
                    p("Hello, World!")
                    p("This is built with Result Builders!")
                }
            }
            
            print(webpage)
            """,
            explanation: "Build domain-specific languages with result builders",
            category: .advanced)
    ]
}