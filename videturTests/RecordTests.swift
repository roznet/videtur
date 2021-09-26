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

class RecordTests: XCTestCase {

    var remaining : [CLLocationCoordinate2D] = []
    var currentDate : Date? = nil
    var expectation : XCTestExpectation? = nil
    var model : Model? = nil
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // clear and reset model from scratch
        self.model = nil
        RZFileOrganizer.removeEditableFile("test.db")
        self.model = Model(dbpath: RZFileOrganizer.writeableFilePath("test.db"))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func loadSample() -> [LocationRecord]{
        let decoder = JSONDecoder()
        
        guard let url = Bundle(for: type(of: self)).url( forResource: "samplerecords", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let array = try? decoder.decode([LocationRecord].self, from: data)
        else {
            XCTAssertTrue(false, "Can't load bundle")
            return []
        }
        XCTAssertNotNil(array)
        return array
    }
    
    func testPlacemark() throws {
        let coords = self.loadSample().map { $0.coordinate }
        self.remaining = coords
        let component = DateComponents(year: 2021, month: 3, day: 10, hour: 11)
        self.currentDate = Calendar.current.date(from: component)
        let expectation = XCTestExpectation(description: "Geocode")
        self.expectation = expectation
        
        self.updateNext()
        
        wait(for: [expectation], timeout: 5.0, enforceOrder: false)

        let reloadedModel = Model(dbpath: RZFileOrganizer.writeableFilePath("test.db"))
        
        reloadedModel.recordKeeper.load()
        
        XCTAssertEqual(reloadedModel.recordKeeper.locations, self.model?.recordKeeper.locations)
    }
    
    func updateNext() {
        if self.remaining.count == 0 {
            let records = self.model?.recordKeeper.records
            do {
                let encoded = try JSONEncoder().encode(records)
                
                try? encoded.write(to: URL(fileURLWithPath: RZFileOrganizer.writeableFilePath("testdata.json")))
                
            }catch{
                print( error)
            }

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
