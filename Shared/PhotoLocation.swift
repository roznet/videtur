//  MIT License
//
//  Created on 01/04/2021 for videtur
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
import Vision
import Photos
#if os(iOS)
import UIKit
#endif

struct PhotoLocation {
    
    enum Status : Error{
        case ok
        case assetMissingDate
        case assetMissingLocation
    }
    
    let localIdentifier : String
    let coordinate : CLLocationCoordinate2D
    let tags : [String]
    let date : Int
    let timestamp : Date
    
    var image : UIImage?

    
    init(asset : PHAsset, classification : [VNClassificationObservation], image : UIImage? = nil ) throws{
        guard let date = asset.creationDate else { throw Status.assetMissingDate }
        guard let coord = asset.location?.coordinate else { throw Status.assetMissingLocation }
        
        self.localIdentifier = asset.localIdentifier
        self.timestamp = date
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        if let day = Int(formatter.string(from: self.timestamp)) {
            self.date = day
        }else{
            self.date = 0
        }
        self.coordinate = coord
        self.tags = classification.map { $0.identifier }
        self.image = image
    }
    
    func isPreferred(over: PhotoLocation) -> Bool {
        // prefers outdoor photos
        return self.tags.contains("outdoor") && !over.tags.contains("outdoor")
    }
}
