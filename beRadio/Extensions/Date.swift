
import Foundation

extension Date {
    func relativeDate() -> String {
        let date = self
        let calendar = Calendar.current
//        let now = Date()
        
        let isToday = calendar.isDateInToday(date)
        let isYesterday = calendar.isDateInYesterday(date)
//        let dateInfo = (isToday: isToday, isYesterday: isYesterday)
        
        switch true {
        case isToday:
            return "Today"
        case isYesterday:
            return "Yesterday"
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE" // Day name format
            return dateFormatter.string(from: date)
        }
    }
}
