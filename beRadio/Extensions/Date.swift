
import Foundation

extension Date {
    func relativeDate() -> String {
        let date = self
        let calendar = Calendar.current

        let isToday = calendar.isDateInToday(date)
        let isYesterday = calendar.isDateInYesterday(date)
        
        switch true {
        case isToday:
            return "Today"
        case isYesterday:
            return "Yesterday"
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE" // Day name format
            let dayName = dateFormatter.string(from: date)
            let diffDays = diffDays()
            let diffDaysString = diffDays != nil ? "(\(abs(diffDays!)))" : ""
            let relativeDate = dayName + " " + diffDaysString
            return relativeDate
        }
    }

    func diffDays() -> Int? {
        let currentDate = Date()

        // Use Calendar to calculate the difference in days
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: currentDate, to: self)

        // Output the difference in days
        let days = components.day

        return days
    }
}
