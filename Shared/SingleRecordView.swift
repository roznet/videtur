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
                HStack(){
                    Text(self.record.isoCountryCode ?? "")
                    Text(self.record.country?.flag ?? "")
                }
            }
            HStack {
                Text( Self.dateFormatter.string(from: self.record.timestamp) )
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
                HStack{
                    Text(self.record.administrativeArea ?? "")
                    Text(self.record.locality ?? "")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct LastRecordView_Previews: PreviewProvider {
    static var previews: some View {
        let samples = Self.sampleRecords
        
        SingleRecordView(record: samples[0])
        SingleRecordView(record: samples[1])
    }
    
    static var sampleRecords : [RecordLocation] {
        let all = RecordsList_Previews.sampleRecords
        var different : [RecordLocation] = []
        var countries : Set<String> = []
        for record in all {
            guard let isoCountryCode = record.isoCountryCode else { continue }
            if !countries.contains( isoCountryCode ){
                different.append(record)
                countries.insert(isoCountryCode)
            }
        }
        return different
    }
}
