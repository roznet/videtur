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
   
    let db : FMDatabase

    init(db : FMDatabase) {
        self.db = db
    }
    
    static var sqlCreationStatement = "CREATE TABLE location_tracker (recordTrackerId INTEGER PRIMARY KEY, timestamp REAL NONNULL, latitude REAL,longitude REAL, deviceId TEXT)"

    static func ensureDbStructure(db : FMDatabase){
        if !db.tableExists("location_tracker") {
            db.executeUpdate(RecordLocation.sqlCreationStatement, withArgumentsIn: [])
        }
    }

    func startTracking(completion : LocationTrackerCompletionHandler? = nil) {
        locationManager.delegate = self
        self.completion = completion
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced;
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.requestAlwaysAuthorization()
        RZSLog.info("Initiating request location")
        locationManager.requestLocation()
        //locationManager.startUpdatingLocation()
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        RZSLog.info("new location \(locations)")
        //locationManager.stopUpdatingLocation()
        guard let first = locations.first else { return }
        self.updateNewLocation(date: Date(), coordinate: first.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        RZSLog.error("failed to locate \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            RZSLog.info("Authorization always")
        case .authorizedWhenInUse:
            RZSLog.info("Authorization wheninused")
        case .denied, .restricted:
            RZSLog.error("Authorization changed denied/restricted")
        case .notDetermined:
            RZSLog.warning("Authorization changed notDetermined")
        default:
            RZSLog.warning("Authorization changed default")
        }
        
    }
    
    func updateNewLocation( date: Date, coordinate : CLLocationCoordinate2D, completion: LocationTrackerCompletionHandler? = nil) {
        if completion != nil {
            self.completion = completion
        }
        
        guard let device = try? RecordingDevice() else { return }

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
