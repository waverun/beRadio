import Foundation

extension JSONDecoder {
    static let radioApiDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Inf", negativeInfinity: "-Inf", nan: "NaN")
        return decoder
    }()
}
