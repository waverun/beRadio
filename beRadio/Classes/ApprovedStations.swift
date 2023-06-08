import Foundation

class ApprovedStations {
    static let shared = ApprovedStations()

    var approvedStations: [RadioStation] = [RadioStation(
        id: "4d90c38f-b1c2-442c-91ff-ed4068b36454",
        name: "Le village pop",
        url: "https://listen.radioking.com/radio/200437/stream/243028",
        homepage: "http://levillagepop.com/",
        favicon: "",
        country: "France",
        state: ""
    )
    ]

    let stationList181FM = """
    1) 181.FM Classic Hits 181    http://listen.181fm.com/181-greatoldies_128k.mp3
    2) 181.FM Good Time Oldies    http://listen.181fm.com/181-goodtime_128k.mp3
    3) 181.FM Mellow Gold    http://listen.181fm.com/181-mellow_128k.mp3
    4) 181.FM Beatles    http://listen.181fm.com/181-beatles_128k.mp3
    5) 181.FM Super 70s    http://listen.181fm.com/181-70s_128k.mp3
    6) 181.FM Awesome 80's    http://listen.181fm.com/181-awesome80s_128k.mp3
    7) 181.FM Lite 80's    http://listen.181fm.com/181-lite80s_128k.mp3
    8) 181.FM 80's Country    http://listen.181fm.com/181-80scountry_128k.mp3
    9) 181.FM Star 90's    http://listen.181fm.com/181-star90s_128k.mp3
    10) 181.FM 90's Dance    http://listen.181fm.com/181-90sdance_128k.mp3
    11) 181.FM 90's Lite RnB    http://listen.181fm.com/181-90sliternb_128k.mp3
    12) 181.FM 90's RnB    http://listen.181fm.com/181-90srnb_128k.mp3
    13) 181.FM Lite 90's    http://listen.181fm.com/181-lite90s_128k.mp3
    14) 181.FM 90's Alternative    http://listen.181fm.com/181-90salt_128k.mp3
    15) 181.FM Power 181 (Top 40)    http://listen.181fm.com/181-power_128k.mp3
    16) 181.FM Power 181 [E]    http://listen.181fm.com/181-powerexplicit_128k.mp3
    17) 181.FM The Office    http://listen.181fm.com/181-office_128k.mp3
    18) 181.FM The Mix    http://listen.181fm.com/181-themix_128k.mp3
    19) 181.FM The Point    http://listen.181fm.com/181-thepoint_128k.mp3
    20) 181.FM Old School HipHop/RnB    http://listen.181fm.com/181-oldschool_128k.mp3
    21) 181.FM Smooth AC    http://listen.181fm.com/181-smoothac_128k.mp3
    22) 181.FM UK top 40    http://listen.181fm.com/181-uktop40_128k.mp3
    23) 181.FM The Heart (Love Songs)    http://listen.181fm.com/181-heart_128k.mp3
    24) 181.FM The Buzz (Alt. Rock)    http://listen.181fm.com/181-buzz_128k.mp3
    25) 181.FM Classic Buzz (Alt)    http://listen.181fm.com/181-classicbuzz_128k.mp3
    26) 181.FM The Eagle (Classic)    http://listen.181fm.com/181-eagle_128k.mp3
    27) 181.FM Rock 181    http://listen.181fm.com/181-rock_128k.mp3
    28) 181.FM Rock 40 (Rock & Roll)    http://listen.181fm.com/181-rock40_128k.mp3
    29) 181.FM 80's Hairband    http://listen.181fm.com/181-hairband_128k.mp3
    30) 181.FM Yacht Rock    http://listen.181fm.com/181-yachtrock_128k.mp3
    31) 181.FM Chloe @181.FM    http://listen.181fm.com/181-chloe_128k.mp3
    32) 181.FM The Rock! (Hard Rock)    http://listen.181fm.com/181-hardrock_128k.mp3
    33) 181.FM Kickin' Country    http://listen.181fm.com/181-kickincountry_128k.mp3
    34) 181.FM Real Country    http://listen.181fm.com/181-realcountry_128k.mp3
    35) 181.FM Highway 181    http://listen.181fm.com/181-highway_128k.mp3
    36) 181.FM 90's Country    http://listen.181fm.com/181-90scountry_128k.mp3
    37) 181.FM Front Porch (Bluegrass)    http://listen.181fm.com/181-frontporch_128k.mp3
    38) 181.FM The Beat (HipHop/R&B)    http://listen.181fm.com/181-beat_128k.mp3
    39) 181.FM The Box (Urban)    http://listen.181fm.com/181-thebox_128k.mp3
    40) 181.FM True R&B    http://listen.181fm.com/181-rnb_128k.mp3
    41) 181.FM Soul    http://listen.181fm.com/181-soul_128k.mp3
    42) 181.FM Party 181    http://listen.181fm.com/181-party_128k.mp3
    43) 181.FM Jammin 181    http://listen.181fm.com/181-jammin_128k.mp3
    44) 181.FM 80's RnB    http://listen.181fm.com/181-80srnb_128k.mp3
    45) 181.FM 80's Lite RnB    http://listen.181fm.com/181-80sliternb_128k.mp3
    46) 181.FM Energy 98    http://listen.181fm.com/181-energy98_128k.mp3
    47) 181.FM Chilled Out    http://listen.181fm.com/181-chilled_128k.mp3
    48) 181.FM Classic Energy    http://listen.181fm.com/181-classicenergy_128k.mp3
    49) 181.FM Energy 93    http://listen.181fm.com/181-energy93_128k.mp3
    50) 181.FM Studio 181    http://listen.181fm.com/181-ball_128k.mp3
    51) 181.FM The Vibe of Vegas    http://listen.181fm.com/181-vibe_128k.mp3
    52) 181.FM True Blues    http://listen.181fm.com/181-blues_128k.mp3
    53) 181.FM The Breeze    http://listen.181fm.com/181-breeze_128k.mp3
    54) 181.FM Jazz Mix    http://listen.181fm.com/181-jazzmix_128k.mp3
    55) 181.FM Classical Guitar    http://listen.181fm.com/181-classicalguitar_128k.mp3
    56) 181.FM Classical Jazz    http://listen.181fm.com/181-classicaljazz_128k.mp3
    57) 181.FM Vocal Jazz    http://listen.181fm.com/181-vocals_128k.mp3
    58) 181.FM BeBop Jazz    http://listen.181fm.com/181-bebop_128k.mp3
    59) 181.FM Fusion Jazz    http://listen.181fm.com/181-fusionjazz_128k.mp3
    60) 181.FM Trance Jazz    http://listen.181fm.com/181-trancejazz_128k.mp3
    61) 181.FM Classical Music    http://listen.181fm.com/181-classical_128k.mp3
    62) 181.FM Acid Jazz    http://listen.181fm.com/181-acidjazz_128k.mp3
    63) 181.FM Comedy Club    http://listen.181fm.com/181-comedy_128k.mp3
    64) 181.FM Christmas Kountry    http://listen.181fm.com/181-xkkountry_128k.mp3
    65) 181.FM Christmas Classics    http://listen.181fm.com/181-xtraditional_128k.mp3
    66) 181.FM Christmas Oldies    http://listen.181fm.com/181-xoldies_128k.mp3
    67) 181.FM Christmas Country    http://listen.181fm.com/181-xcountry_128k.mp3
    68) 181.FM Christmas Power    http://listen.181fm.com/181-xpower_128k.mp3
    69) 181.FM Christmas Highway    http://listen.181fm.com/181-xhighway_128k.mp3
    70) 181.FM Christmas Soundtracks    http://listen.181fm.com/181-xsoundtrax_128k.mp3
    71) 181.FM Christmas R&B    http://listen.181fm.com/181-xtrue_128k.mp3
    72) 181.FM Christmas Rock    http://listen.181fm.com/181-xrock_128k.mp3
    73) 181.FM Christmas Mix    http://listen.181fm.com/181-xmix_128k.mp3
    74) 181.FM Christmas Fun    http://listen.181fm.com/181-xfun_128k.mp3
    75) 181.FM Christmas Kids    http://listen.181fm.com/181-xkids_128k.mp3
    76) 181.FM Christmas Blender    http://listen.181fm.com/181-xblender_128k.mp3
    77) 181.FM Christmas Standards    http://listen.181fm.com/181-xstandards_128k.mp3
    78) 181.FM Christmas Spirit    http://listen.181fm.com/181-xspirit_128k.mp3
    79) 181.FM Christmas Smooth Jazz    http://listen.181fm.com/181-xsmooth_128k.mp3
    80) 181.FM Christmas Gospel    http://listen.181fm.com/181-xgospel_128k.mp3
    81) 181.FM Christmas Swing    http://listen.181fm.com/181-xswing_128k.mp3
"""
    private init() {
        add181FMStations()
    } // private initialization to ensure just one instance is created.

    func add181FMStations() {
        let lines = stationList181FM.split(separator: "\n")
        // Iterate over each line
        for line in lines {
            // Split the line into components
            let components = line.split(separator: "    ", maxSplits: 1)
            // Get the station name and url
            let name = String(components[0].split(separator: ") ")[1])
            let url = String(components[1])

            // Add a new RadioStation to approvedStations
            approvedStations.append(
                RadioStation(
                    id: UUID().uuidString, // Generate a new UUID for the id
                    name: name,
                    url: url,
                    homepage: "https://181.fm/",
                    favicon: "http://www.181.fm/banners/181fm-125x125.gif",
                    country: "The United States Of America",
                    state: ""
                )
            )
        }
    }
}
