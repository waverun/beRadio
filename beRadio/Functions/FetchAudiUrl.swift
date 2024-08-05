import Foundation

func fetchAudioUrl(link: String, completion: @escaping (URL?) -> Void) {
    getHtmlContent(url: link, search: "data-file=\"([^\"]*)\"") { mp3Name in
        guard mp3Name.count > 0 && !mp3Name[0].isEmpty else {
            fetchAudioUrlFromIframe(link: link, completion: completion)
            return
        }
        let mp3Link = mp3Name.count > 0 ? "https://awaod01.streamgates.net/103fm_aw/" + mp3Name[0] + ".mp3" : "https://cdn.cybercdn.live/103FM/Live/icecast.audio"
            completion(URL(string: mp3Link))
    }
}

//func fetchAudioUrlFromIframe(link: String, completion: @escaping (URL?) -> Void) {
//    getHtmlContent(url: link, search: " <p><iframe[^>]*?src=[\"'](.*?)[\"'][^>]*?>") { iframeUrl in
//        //    completion(URL(string: mp3Link))
//        if iframeUrl.count > 0 {
//            let iframeUrl = iframeUrl[0].replacingOccurrences(of: " ", with: "-")
//            print("iframeUrl:", iframeUrl)
//            getHtmlContent(url: iframeUrl, search: "\"AudioUrl\":\"(https?://[^\"]+)\"") { audioUrl in
//                if audioUrl.count > 0 {
//                    print("audioUrl:", audioUrl[0])
//                    completion(URL(string: audioUrl[0].replacingOccurrences(of: " ", with: "-")))
//                }
//            }
//        }
//    }

func fetchAudioUrlFromIframe(link: String, completion: @escaping (URL?) -> Void) {
    // Update the search pattern to account for the optional <strong> tag
    let searchPattern = "<p>(?:<strong>)?<iframe[^>]*?src=[\"'](.*?)[\"'][^>]*?>"

    getHtmlContent(url: link, search: searchPattern) { iframeUrls in
        if iframeUrls.count > 0 {
            let iframeUrl = iframeUrls[0].replacingOccurrences(of: " ", with: "-")
            print("iframeUrl:", iframeUrl)
            getHtmlContent(url: iframeUrl, search: "\"AudioUrl\":\"(https?://[^\"]+)\"") { audioUrls in
                if audioUrls.count > 0 {
                    print("audioUrl:", audioUrls[0])
                    completion(URL(string: audioUrls[0].replacingOccurrences(of: " ", with: "-")))
                }
            }
        }
    }
}
