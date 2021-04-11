//  MIT License
//
//  Created on 11/04/2021 for videtur (macOS)
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

struct RecordingDevice {
    let uuid : String

    var name :String {
        let rv = Host.current().name
            
        return rv ?? "Unknown"
    }
    
    var model : String {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                  IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?
        
        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            if let modelIdentifierCString = String(data: modelData, encoding: .utf8)?.cString(using: .utf8) {
                modelIdentifier = String(cString: modelIdentifierCString)
            }
        }
        
        IOObjectRelease(service)
        return modelIdentifier ?? "Unknown"
    }
    
    init() throws {
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice") )
        
        guard platformExpert > 0 else {
            self.uuid = UUID().uuidString
            return
        }
        
        guard let serialNumber = (IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            self.uuid = UUID().uuidString
            return
        }
        
        IOObjectRelease(platformExpert)

        self.uuid = serialNumber
    }

}
