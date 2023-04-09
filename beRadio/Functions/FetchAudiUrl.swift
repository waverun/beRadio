import Foundation

func fetchAudioUrl(link: String, completion: @escaping (URL?) -> Void) {
    getHtmlContent(url: link, search: "data-file=\"([^\"]*)\"") { mp3Name in
        let mp3Link = mp3Name.count > 0 ? "https://awaod01.streamgates.net/103fm_aw/" + mp3Name[0] + ".mp3" : "https://cdn.cybercdn.live/103FM/Live/icecast.audio"
            completion(URL(string: mp3Link))
    }
}
