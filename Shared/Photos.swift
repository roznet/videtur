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
import Photos
import CoreML
import Vision

class Photos {
    
    static let newPhotoAvailableNotification = Notification.Name("Photos.newPhotoAvailable")
    
    let assetManager = PHImageManager()
    
    private var photosRecord : [Int:PhotoLocation] = [:]
    var photos : [PhotoLocation] {
        return Array(self.photosRecord.values).sorted { $1.timestamp < $0.timestamp }
    }
    
    func fetchFromPhotos(startDate : Date, endDate : Date = Date()) {
        var idx : Int = 0
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", startDate as CVarArg, endDate as CVarArg)
        let fetchResults = PHAsset.fetchAssets(with: fetchOptions)
        
        let requestOption = PHImageRequestOptions()
        // this should be called from background thread, but then we run sync so we can notify at
        // the right time
        requestOption.isSynchronous = true
        
        fetchResults.enumerateObjects {
            asset, index, pointer in
            if asset.mediaType == .image && asset.location != nil{
                self.assetManager.requestImage(for: asset,
                                               targetSize: CGSize(width: 300,height: 300),
                                               contentMode: .aspectFit,
                                               options: requestOption){
                    image, metadata in
                    
                    if let image = image{
                        if let cgImage = image.cgImage {
                            let requestHandler = VNImageRequestHandler(cgImage: cgImage)
                            let request = VNClassifyImageRequest()
                            try? requestHandler.perform([request])
                            if let results = request.results  {
                                let top : [VNClassificationObservation] = Array(results[0..<10])
                                
                                if let photoLocation = try? PhotoLocation(asset: asset, classification: top, image: image){
                                    if let existing = self.photosRecord[photoLocation.date] {
                                        if photoLocation.isPreferred(over: existing){
                                            self.photosRecord[photoLocation.date] = photoLocation
                                        }
                                    }else{
                                        idx += 1
                                        self.photosRecord[photoLocation.date] = photoLocation
                                        // notify once in a while (every 15 new days)
                                        if idx % 15 == 0 {
                                            NotificationCenter.default.post(name: Self.newPhotoAvailableNotification, object: self)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if idx > 0 {
            // final notification if all done and some images found
            NotificationCenter.default.post(name: Self.newPhotoAvailableNotification, object: self)
        }
    }
}
