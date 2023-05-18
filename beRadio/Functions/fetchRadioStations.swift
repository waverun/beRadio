import Foundation

func fetchRadioStations(searchQuery: String, completion: @escaping ([RadioStation]) -> Void) {
    let encodedSearchQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
    guard let url = URL(string: "https://de1.api.radio-browser.info/json/stations/search?name=\(encodedSearchQuery)") else {
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

