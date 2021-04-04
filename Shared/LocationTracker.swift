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

import Foundation
import CoreLocation
import FMDB
import RZUtils
import RZUtilsSwift


class LocationTracker : NSObject,CLLocationManagerDelegate {
    typealias LocationTrackerCompletionHandler = (RecordLocation?) -> Void
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    weak var model : Model? = nil
    var completion : LocationTrackerCompletionHandler? = nil
    
    
    func startTracking(completion : LocationTrackerCompletionHandler? = nil) {
        locationManager.delegate = self
        self.completion = completion
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced;
        self.locationManager.requestAlwaysAuthorization()
        RZSLog.info("Initiating request location")
        locationManager.requestLocation()
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        #if os(iOS)
        guard let device = try? RecordingDevice() else { return }
        RZSLog.info( "tracked from \(device)")
        #endif
        RZSLog.info( "updated \(first)")
        self.updateNewLocation(date: Date(), coordinate: first.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        RZSLog.error("failed to locate \(error)")
    }
    
    func updateNewLocation( date: Date, coordinate : CLLocationCoordinate2D, completion: LocationTrackerCompletionHandler? = nil) {
        if completion != nil {
            self.completion = completion
        }
        guard let model = self.model,
              let record = model.recordKeeper.add(record: RecordLocation(date: date, coordinate: coordinate) )
        else {
            if let completion = self.completion {
                completion(nil);
            }
            return
        }
        RZSLog.info( "got location \(record)")

        geoCoder.reverseGeocodeLocation(CLLocation(latitude: record.coordinate.latitude, longitude: record.coordinate.longitude)){
            (placemark, error) in
            if let placemark = placemark?.first {
                let geocodedRecord = record.geocoded(placemark : placemark)
                let savedRecord = try? model.recordKeeper.update(record: geocodedRecord)
                if let savedRecord = savedRecord {
                    RZSLog.info( "reversed location \(savedRecord)")
                }else{
                    RZSLog.info( "reversed location failed \(record)")
                }
                if let completion = self.completion {
                    completion(savedRecord);
                }
            }
        }
    }
}
