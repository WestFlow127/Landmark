//
//  LandmarkTests.swift
//  LandmarkTests
//
//  Created by Weston Mitchell on 9/3/22.
//

import XCTest
import FirebaseFirestore

@testable import Landmark

class LandmarkModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInit_LandmarkEntity() {
        let id = UUID().uuidString
        
        let landmark = LandmarkEntity(
            name: "Venice Monument",
            id: id,
            location: "Ocean Front Walk",
            description: "Cool place to visit in Los Angeles.",
            imageUrlPaths: ["some path"],
            geoLocation: GeoPoint(latitude: 33.33, longitude: 118.333)
        )
       
        XCTAssertNotNil(landmark)
        XCTAssertEqual(landmark.location, "Ocean Front Walk")
        XCTAssertEqual(landmark.id, id)
    }
    
    func testInit_LandmarkEntityNameOnly() {
        let landmark = LandmarkEntity(name: "My Landmark")
        
         XCTAssertNotNil(landmark)
         XCTAssertEqual(landmark.name, "My Landmark")
    }
    
    func testLandmark_EquatableTrue() {
        let id = UUID().uuidString

        let landmark = LandmarkEntity(name: "My Landmark", id: id)
        let landmark2 = LandmarkEntity(name: "My Landmark", id: id)

        XCTAssertEqual(landmark, landmark2)
    }
    
    func testLandmark_EquatableFalse() {
        let id = UUID().uuidString
        let id2 = UUID().uuidString

        let landmark = LandmarkEntity(name: "My Landmark", id: id)
        let landmark2 = LandmarkEntity(name: "My Landmark2", id: id2)

        XCTAssertNotEqual(landmark, landmark2)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
