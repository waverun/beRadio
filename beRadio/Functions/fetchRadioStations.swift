//import Foundation

//func fetchRadioStations(searchQuery: String, completion: @escaping ([RadioStation]) -> Void) {
//    guard let url = URL(string: "https://de1.api.radio-browser.info/json/stations/search?name=\(searchQuery)") else {
//        print("Invalid URL")
//        return
//    }
//
//    let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        if let data = data {
//            let decoder = JSONDecoder()
//            if let stations = try? decoder.decode([RadioStation].self, from: data) {
//                DispatchQueue.main.async {
//                    completion(stations)
//                }
//                return
//            }
//        }
//        print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
//    }
//    task.resume()
//}

//func fetchRadioStations(searchText: String, completion: @escaping (Result<[RadioStation], Error>) -> Void) {
//    let urlString = "https://de1.api.radio-browser.info/json/stations/byname/\(searchText)?limit=10"
//    let url = URL(string: urlString)!
//
//    let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//
//        if let data = data {
//            do {
//                let stations = try JSONDecoder.radioApiDecoder.decode([RadioStation].self, from: data)
//                completion(.success(stations))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//    task.resume()
//}

//import Foundation
//
//func fetchRadioStations(searchQuery: String, completion: @escaping ([RadioStation]) -> Void) {
//    guard let url = URL(string: "https://de1.api.radio-browser.info/json/stations/search?name=\(searchQuery)") else {
//        print("Invalid URL")
//        return
//    }
//
//    let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        if let data = data {
//            do {
//                let stations = try JSONDecoder.radioApiDecoder.decode([RadioStation].self, from: data)
//                DispatchQueue.main.async {
//                    completion(stations)
//                }
//            } catch {
//                print("Fetch failed: \(error.localizedDescription)")
//            }
//        } else {
//            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
//        }
//    }
//    task.resume()
//}

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

