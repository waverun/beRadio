import Foundation

class StreamBuffer {
    private let streamURL: URL
    private let chunkDuration: TimeInterval
    private var chunks: [URL] = []
    
    init(streamURL: URL, chunkDuration: TimeInterval) {
        self.streamURL = streamURL
        self.chunkDuration = chunkDuration
    }

    func downloadChunk(completion: @escaping (URL?) -> Void) {
        // Download a chunk of the stream and save it to a temporary file
        // You can use URLSession dataTask to download data and then save it to a temporary file
    }

    
    func getNextChunk() -> URL? {
        return chunks.first
    }
    
    func removePlayedChunk() {
        if !chunks.isEmpty {
            try? FileManager.default.removeItem(at: chunks.removeFirst())
        }
    }
    
    func deleteAllChunks() {
            for chunkURL in chunks {
                do {
                    try FileManager.default.removeItem(at: chunkURL)
                } catch {
                    print("Error deleting chunk at \(chunkURL): \(error)")
                }
            }
            chunks.removeAll()
        }
}
