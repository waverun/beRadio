import Foundation

extension URL {
    func replaceSpacesWithHyphens() -> URL? {
        // קבלת ה-string מה-URL
        var urlString = self.absoluteString

        // החלפת הרווחים במקפים
//        urlString = urlString.replacingOccurrences(of: " ", with: "-")
        urlString = urlString.replacingOccurrences(of: "%20", with: "-")

        // יצירת URL חדש מה-string המעודכן
        return URL(string: urlString)
    }
}
