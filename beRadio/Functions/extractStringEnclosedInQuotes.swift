import Foundation

func extractStringEnclosedInQuotes(from input: String) -> String? {
    // Regular expression pattern to find text enclosed in quotes
    let pattern = "\"([^\"]*)\""

    // Attempt to create a regular expression
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

    // Search for the first match
    if let match = regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)) {
        // Extract the matched range, considering the first capture group
        if let range = Range(match.range(at: 1), in: input) {
            return String(input[range])
        }
    }

    // Return nil if no match was found
    return nil
}
