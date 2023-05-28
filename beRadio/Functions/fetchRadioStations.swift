import Foundation

func fetchRadioStations(name: String, country: String, state: String, completion: @escaping ([RadioStation]) -> Void) {
    var encodedSearchString = ""
    if !name.isEmpty {
        let encodedSearchName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        encodedSearchString = "name=" + encodedSearchName
    }
    if !country.isEmpty {
        if !encodedSearchString.isEmpty {
            encodedSearchString += "&"
        }
        let encodedSearchCountry = country.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? country
        encodedSearchString += "country=" + encodedSearchCountry
    }
//    if !state.isEmpty {
//        if !encodedSearchString.isEmpty {
//            encodedSearchString += "&"
//        }
//        let encodedSearchState = state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? state
//        encodedSearchString += "state=" + encodedSearchState
//    }
    if !encodedSearchString.isEmpty {
        encodedSearchString = "?" + encodedSearchString
    }

    guard let url = URL(string: "https://de1.api.radio-browser.info/json/stations/search\(encodedSearchString)") else {
        print("Invalid URL")
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            let decoder = JSONDecoder()
            if let stations = try? decoder.decode([RadioStation].self, from: data) {
                DispatchQueue.main.async {
                    completion(stations)
                }
                return
            }
        }
        print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    }
    task.resume()
}

