import Foundation

func checkIfURLExists(url: String, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: url) else {
        completion(false)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"

    let task = URLSession.shared.dataTask(with: request) { (_, response, _) in
        if let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode {
            completion(true)
        } else {
            completion(false)
        }
    }
    task.resume()
}
