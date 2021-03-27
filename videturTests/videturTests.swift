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
import RZUtils
@testable import videtur

class videturTests: XCTestCase {

    var remaining : [CLLocationCoordinate2D] = []
    var currentDate : Date? = nil
    var expectation : XCTestExpectation? = nil
    var model : Model? = nil
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // clear and reset model from scratch
        self.model = nil
        RZFileOrganizer.removeEditableFile("test.db")
        self.model = Model(dbname: "test.db")
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPlacemark() throws {
        let coords = [
            CLLocationCoordinate2D(latitude: 51.5074, longitude: 0.1278), // London
            CLLocationCoordinate2D(latitude: 51.5074, longitude: 0.1278), // London
            CLLocationCoordinate2D(latitude: 51.5074, longitude: 0.1278), // London
            CLLocationCoordinate2D(latitude: 51.5074, longitude: 0.1278), // London
            CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), // Paris
            CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), // Paris
            CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), // Paris
            CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), // Paris
            CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417), // zurich
            CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417), // zurich
            CLLocationCoordinate2D(latitude: 47.1748, longitude: 8.7128), // schindellegi
            CLLocationCoordinate2D(latitude: 47.1748, longitude: 8.7128), // schindellegi
            CLLocationCoordinate2D(latitude: 47.1748, longitude: 8.7128), // schindellegi
            CLLocationCoordinate2D(latitude: 46.2941, longitude: 7.5335), // schindellegi
            CLLocationCoordinate2D(latitude: 46.2044, longitude: 6.1432), // geneva
            CLLocationCoordinate2D(latitude: 46.2044, longitude: 6.1432), // geneva
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // New York, NY
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // New York, NY
            CLLocationCoordinate2D(latitude: 41.0534, longitude: -73.5387), // Stamford, CO
            CLLocationCoordinate2D(latitude: 41.0534, longitude: -73.5387), // Stamford, CO
        ]
        self.remaining = coords
        let component = DateComponents(year: 2021, month: 3, day: 10, hour: 11)
        self.currentDate = Calendar.current.date(from: component)
        let expectation = XCTestExpectation(description: "Geocode")
        self.expectation = expectation
        
        self.updateNext()
        
        wait(for: [expectation], timeout: 5.0, enforceOrder: false)
        
        let days = self.model?.recordKeeper.days
        print( "\(days)")
    }
    
    func updateNext() {
        if self.remaining.count == 0 {
            self.expectation?.fulfill()
            self.currentDate = nil
            return
        }
        
        let coord = self.remaining.removeLast()
        if let date = self.currentDate, let model = self.model {
            model.locationTracker.updateNewLocation(date: date, coordinate: coord){
                record in
                if let record = record {
                    print( "\(record)")
                }
                self.currentDate = Calendar.current.date(byAdding: .hour, value: 12, to: date)
                self.updateNext()
            }
        }
    }
}
