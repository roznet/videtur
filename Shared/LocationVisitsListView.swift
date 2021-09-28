//  MIT License
//
//  Created on 26/09/2021 for videtur
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

struct LocationVisitsListView: View {
    @State var visits : [LocationVisits]
    
    var body: some View {
        NavigationView {
           List(visits) { visit in
                NavigationLink(
                    destination: LocationVisitsSingleView(visit: visit) ){
                        LocationVisitsSingleView(visit: visit)
                }
            }
            
        }
    }
}

#if DEBUG
struct LocationVisitsListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationVisitsListView(visits: Self.sampleCountryVisits)
    }
    
    static var sampleCountryVisits : [LocationVisits] {
        guard let url = Bundle.main.url( forResource: "samplerecords", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            return []
        }
        let decoder = JSONDecoder()
        if let array = try? decoder.decode([LocationRecord].self, from: data) {
            let keeper = RecordKeeper(records: array)
            return keeper.countries
        }
        return []
        
    }
}
#endif

