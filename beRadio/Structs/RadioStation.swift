//import Foundation
//
//struct RadioStation: Codable, Identifiable {
//    let id: String
//    let name: String
//    let country: String
//    let favicon: String?
//    let url_resolved: String
//}
struct RadioStation: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
    let homepage: String?
    let favicon: String?
    let country: String?
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "stationuuid"
        case name
        case url = "url_resolved"
        case homepage
        case favicon
        case country
        case state
    }

    // Manual initialization
    init(id: String, name: String, url: String, homepage: String?, favicon: String?, country: String?, state: String?) {
        self.id = id
        self.name = name
        self.url = url
        self.homepage = homepage
        self.favicon = favicon
        self.country = country
        self.state = state
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        homepage = try container.decodeIfPresent(String.self, forKey: .homepage)
        favicon = try container.decodeIfPresent(String.self, forKey: .favicon)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
    }
}
