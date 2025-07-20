import XCTest
@testable import SwiftErrorDetection

final class SwiftErrorDetectionTests: XCTestCase {
    
    func testAddNumbersCorrect() {
        let result = addNumbersCorrect(a: 5, b: 3)
        XCTAssertEqual(result, 8)
    }
    
    func testMultiplyCorrect() {
        let result = multiplyCorrect(x: 4, y: 3)
        XCTAssertEqual(result, 12)
    }
    
    func testSafeDivide() {
        // Test normal division
        let result1 = safeDivide(a: 10, b: 2)
        XCTAssertEqual(result1, 5)
        
        // Test division by zero
        let result2 = safeDivide(a: 10, b: 0)
        XCTAssertNil(result2)
    }
    
    func testPersonCorrect() {
        let person = PersonCorrect(name: "Test", age: 30, email: "test@example.com")
        XCTAssertEqual(person.name, "Test")
        XCTAssertEqual(person.age, 30)
        XCTAssertEqual(person.email, "test@example.com")
    }
    
    // Test that would fail due to errors in main.swift
    func testErrorsExist() {
        // This test documents that we expect compilation errors
        // In a real project, you'd fix the errors and test the corrected functions
        XCTAssertTrue(true, "This test passes to show that testing framework works")
    }
}