import Foundation

func fetchAudioUrl(link: String, completion: @escaping (URL?) -> Void) {
    getHtmlContent(url: link, search: "data-file=\"([^\"]*)\"") { mp3Name in
        //        completion(URL(string: "https://awaod01.streamgates.net/103fm_aw/mag0404238.mp3"))
        let mp3Link = mp3Name.count > 0 ? "https://awaod01.streamgates.net/103fm_aw/" + mp3Name[0] + ".mp3" : nil
        if let mp3Link = mp3Link {
            completion(URL(string: mp3Link))
            return
        }
        completion(nil)
    }
}
