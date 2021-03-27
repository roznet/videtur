//  MIT License
//
//  Created on 26/03/2021 for Videtur
//
//  Copyright (c) 2021 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
import CoreLocation
@testable import videtur

class videturTests: XCTestCase {

    var tracker : LocationTracker?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPlacemark() throws {
        let coords = [ CLLocation(latitude: 51.5074, longitude: 0.1278), // London
                       CLLocation(latitude: 40.7128, longitude: 74.0060), // New York
                       CLLocation(latitude: 48.8566, longitude: 2.3522), // Paris
                       CLLocation(latitude: 47.3769, longitude: 8.5417), // zurich
        ]
        let tracker = LocationTracker()
        self.tracker = tracker
        let expectation = XCTestExpectation(description: "geocode")
        tracker.reverseAndSave(locations: coords){
            geocoded in
            print( "\(geocoded)" )
            self.tracker = nil
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0, enforceOrder: false)
    }


}
