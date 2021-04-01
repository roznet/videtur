//  MIT License
//
//  Created on 31/03/2021 for videtur
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



import SwiftUI
import CoreLocation
import Foundation

struct SingleRecordView: View {
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    @State var record : RecordLocation
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                HStack{
                    Text(self.record.isoCountryCode ?? "")
                    Text(self.record.country?.flag ?? "")
                }
                HStack{
                    Text(self.record.administrativeArea ?? "")
                    Text(self.record.locality ?? "")
                }
            }
            HStack {
                Text( Self.dateFormatter.string(from: self.record.timestamp) )
            }
        }
    }
}

struct LastRecordView_Previews: PreviewProvider {
    static var previews: some View {
        let jsonData = "{\"location\":{\"timeZone\":{\"identifier\":\"America\\/New_York\"},\"administrativeArea\":\"CT\",\"locality\":\"Stamford\",\"isoCountryCode\":\"US\"},\"timestamp\":637066800,\"coordinate\":[-73.538700000000006,41.053400000000003],\"recordId\":1,\"date\":20210310}".data(using: .utf8)
        
        let sample = try! JSONDecoder().decode(RecordLocation.self, from: jsonData!)
        SingleRecordView(record: sample)
    }
}
