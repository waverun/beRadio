import SwiftUI

struct RadioStationsView: View {
    @State private var searchQuery: String = ""
    @State private var radioStations: [RadioStation] = []
    
    @Environment(\.presentationMode) private var presentationMode
    let onDone: (RadioStation) -> Void

    var body: some View {
        VStack {
            TextField("Search", text: $searchQuery, onCommit: {
                fetchRadioStations(searchQuery: searchQuery) { stations in
                    radioStations = stations
                }
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())

            List(radioStations) { station in
                Button(action: {
                    onDone(station)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        if let urlString = station.favicon {
                            AsyncImage(url: urlString)
                                .frame(width: 60, height: 60) // Adjust the size as needed
                        }
                        VStack(alignment: .leading) {
                            Text(station.name)
                                .font(.headline)
                            Text(station.country ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        //                    Button(action: {
                        //                        onDone(station)
                        //                        presentationMode.wrappedValue.dismiss()
                        //                    }) {
                        //                        Text("Done")
                        //                    }
                    }
                }
            }
        }
    }
}


//to merge from gpt:
//
//List(radioStations) { station in
//    HStack {
//        if let urlString = station.favicon {
//            @State private var urlExists = true // A state variable to keep track of whether the URL exists
//
//            // Call the checkIfURLExists function to determine if the URL exists
//            checkIfURLExists(url: urlString) { exists in
//                urlExists = exists
//            }
//
//            // Use the urlExists state variable to conditionally display either the AsyncImage or a placeholder
//            if urlExists {
//                AsyncImage(url: urlString)
//                    .frame(width: 60, height: 60) // Adjust the size as needed
//            } else {
//                Image(systemName: "photo")
//                    .resizable()
//                    .frame(width: 60, height: 60)
//                    .foregroundColor(.gray)
//            }
//        }
//        VStack(alignment: .leading) {
//            Text(station.name)
//                .font(.headline)
//            Text(station.country ?? "")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//        Button(action: {
//            onDone(station)
//            presentationMode.wrappedValue.dismiss()
//        }) {
//            Text("Done")
//        }
//    }
//}

