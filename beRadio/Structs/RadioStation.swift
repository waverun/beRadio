//import Foundation
//
//struct RadioStation: Codable, Identifiable {
//    let id: String
//    let name: String
//    let country: String
//    let favicon: String?
//    let url_resolved: String
//}

//import Foundation
//
//struct RadioStation: Codable, Identifiable {
//    let id: String
//    let name: String
//    let url: String
//    let favicon: String?
//    let country: String?
//    let state: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "stationuuid"
//        case name
//        case url = "url_resolved"
//        case favicon
//        case country
//        case state
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        name = try container.decode(String.self, forKey: .name)
//        url = try container.decode(String.self, forKey: .url)
//        favicon = try container.decodeIfPresent(String.self, forKey: .favicon)
//        country = try container.decodeIfPresent(String.self, forKey: .country)
//        state = try container.decodeIfPresent(String.self, forKey: .state)
//    }
//}

import Foundation

struct RadioStation: Codable, Identifiable {
    let id: String
    let name: String
    let url: String
    let favicon: String?
    let country: String?
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "stationuuid"
        case name
        case url = "url_resolved"
        case favicon
        case country
        case state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        favicon = try container.decodeIfPresent(String.self, forKey: .favicon)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
    }
}
