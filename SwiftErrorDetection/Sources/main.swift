import Foundation

// Error 1: Missing semicolon (not required in Swift, but shows syntax errors)
var name: String = "Swift Developer"
var age: Int = 25

// Error 2: Type mismatch
var numbers: [Int] = [1, 2, "three", 4]

// Error 3: Using undefined variable
print("Hello, \(username)")

// Error 4: Wrong function signature
func addNumbers(a: Int, b: Int) -> String {
    return a + b  // Type mismatch: returning Int but declared String
}

// Error 5: Missing return statement
func multiply(x: Int, y: Int) -> Int {
    let result = x * y
    // Missing return statement
}

// Error 6: Accessing non-existent property
struct Person {
    var name: String
    var age: Int
}

let person = Person(name: "John", age: 30)
print(person.email) // 'email' property doesn't exist

// Error 7: Force unwrapping nil optional
let optionalValue: String? = nil
print(optionalValue!) // Runtime crash

// Error 8: Array index out of bounds
let array = [1, 2, 3]
print(array[5]) // Runtime crash

// Error 9: Division by zero
func divide(a: Int, b: Int) -> Int {
    return a / b // Potential division by zero
}

let result = divide(a: 10, b: 0)

// Error 10: Memory leak with retain cycle
class Parent {
    var child: Child?
    
    deinit {
        print("Parent deallocated")
    }
}

class Child {
    var parent: Parent? // Should be weak to avoid retain cycle
    
    deinit {
        print("Child deallocated")
    }
}

let parent = Parent()
let child = Child()
parent.child = child
child.parent = parent // Creates retain cycle

// Error 11: Unused variables
let unusedVariable = "This is never used"
var anotherUnusedVar = 42

// Error 12: Inconsistent naming convention
var UPPERCASE_VAR = "Should be camelCase"
var snake_case_var = "Should be camelCase"

// Correct code for reference
print("This line should work fine")
print("Name: \(name), Age: \(age)")

// Correct implementation examples
func addNumbersCorrect(a: Int, b: Int) -> Int {
    return a + b
}

func multiplyCorrect(x: Int, y: Int) -> Int {
    let result = x * y
    return result
}

struct PersonCorrect {
    var name: String
    var age: Int
    var email: String?
}

let personCorrect = PersonCorrect(name: "Jane", age: 25, email: "jane@example.com")
if let email = personCorrect.email {
    print("Email: \(email)")
}

// Safe array access
if array.indices.contains(2) {
    print("Third element: \(array[2])")
}

// Safe division
func safeDivide(a: Int, b: Int) -> Int? {
    guard b != 0 else { return nil }
    return a / b
}

if let safeResult = safeDivide(a: 10, b: 2) {
    print("Safe division result: \(safeResult)")
}

// Breaking retain cycle with weak reference
class ParentCorrect {
    var child: ChildCorrect?
    
    deinit {
        print("ParentCorrect deallocated")
    }
}

class ChildCorrect {
    weak var parent: ParentCorrect? // weak reference breaks retain cycle
    
    deinit {
        print("ChildCorrect deallocated")
    }
}

do {
    let parentCorrect = ParentCorrect()
    let childCorrect = ChildCorrect()
    parentCorrect.child = childCorrect
    childCorrect.parent = parentCorrect
    // When this scope ends, both objects will be deallocated
}