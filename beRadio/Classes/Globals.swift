class ApprovedStations {
    static let shared = ApprovedStations()

    let approvedStations: [RadioStation] = [RadioStation(
        id: "4d90c38f-b1c2-442c-91ff-ed4068b36454",
        name: "Le village pop",
        url: "https://listen.radioking.com/radio/200437/stream/243028",
        homepage: "http://levillagepop.com/",
        favicon: "",
        country: "France",
        state: ""
    )
    ]

    private init() { } // private initialization to ensure just one instance is created.
}
