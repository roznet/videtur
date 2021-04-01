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

struct RecordsListView: View {
    @ObservedObject var records : RecordKeeperObservable
    
    var body: some View {
        List(records.list) { record in
            SingleRecordView(record: record)
        }
    }
}

struct RecordsList_Previews: PreviewProvider {
    static var previews: some View {
        let jsonData = "[{\"location\":{\"timeZone\":{\"identifier\":\"Europe\\/London\"},\"administrativeArea\":\"England\",\"locality\":\"London\",\"isoCountryCode\":\"GB\"},\"timestamp\":637801200,\"coordinate\":[0.1278,51.507399999999997],\"recordId\":18,\"date\":20210318},{\"location\":{\"timeZone\":{\"identifier\":\"Europe\\/Paris\"},\"administrativeArea\":\"Île-de-France\",\"locality\":\"Paris\",\"isoCountryCode\":\"FR\"},\"timestamp\":637671600,\"coordinate\":[2.3521999999999998,48.8566],\"recordId\":15,\"date\":20210317},{\"location\":{\"timeZone\":{\"identifier\":\"Europe\\/London\"},\"administrativeArea\":\"England\",\"locality\":\"London\",\"isoCountryCode\":\"GB\"},\"timestamp\":637714800,\"coordinate\":[0.1278,51.507399999999997],\"recordId\":16,\"date\":20210317},{\"location\":{\"timeZone\":{\"identifier\":\"Europe\\/Zurich\"},\"administrativeArea\":\"Schwyz\",\"locality\":\"Feusisberg\",\"isoCountryCode\":\"CH\"},\"timestamp\":637412400,\"coordinate\":[8.7127999999999997,47.174799999999998],\"recordId\":9,\"date\":20210314},{\"location\":{\"timeZone\":{\"identifier\":\"Europe\\/Zurich\"},\"administrativeArea\":\"Zürich\",\"locality\":\"Zürich\",\"isoCountryCode\":\"CH\"},\"timestamp\":637455600,\"coordinate\":[8.5417000000000005,47.376899999999999],\"recordId\":10,\"date\":20210314}]".data(using: .utf8)
        
        let sample = try! JSONDecoder().decode([RecordLocation].self, from: jsonData!)

        RecordsListView(records: RecordKeeperObservable(records: sample))
    }
}
