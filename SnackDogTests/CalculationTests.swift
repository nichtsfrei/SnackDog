//
//  CalculationTests.swift
//  SnackDogTests
//
//  Created by Philipp on 26.12.21.
//

import XCTest
@testable import SnackDog

class CalculationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    
    func create(_ f: (inout EDog) -> EDog) -> EDog {
        
        var base = EDog(
            id: UUID(),
            name: "",
            birthDate: Date(),
            weight: Measurement(value: 1, unit: .kilograms),
            activityHours: 1,
            size: bcd_dog_small,
            isNautered: false,
            isOld: false)
        return f(&base)
    }

    func createBirthDate(_ compontent: Calendar.Component, value: Int) -> Date{
        let calendar = Calendar.current
        let bd = calendar.date(byAdding: compontent, value: value, to: Date())
        return bd!
    }
    func testFactor() throws {
        
        let dogFactors: [(EDog, Double)] = [
            (create {return $0 }, 0.051),
            (create {
                $0.birthDate = createBirthDate(.weekOfYear, value: -16)
                return $0
            }, 0.045)
            
        ]
        for t in dogFactors {
            XCTAssertEqual(t.0.factor(), t.1)
        }
    }

    

}
