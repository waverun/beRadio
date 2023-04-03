import SwiftUI

struct LinkButton: View {
    var label: String
    var link: String
    @State private var imageUrl: String?
    var action: (String) -> Void
    @State private var buttonColor: Color = .gray

    private func updateButtonColor() {
        // Add your logic to process the link and update the button color
        // This will be similar to the logic in ColoredProgramButton, but will
        // be applied to the link lines.
        LinkProcessor.processLink(link) { (processedTitle, extractedPrograms) in
//            title = processedTitle
            let programs = extractedPrograms
//            switch true {
            if programs.count > 0 {
                let program = programs[0]
                imageUrl = program.image
                buttonColor = program.date.relativeColor()
            }
        }
    }

    var body: some View {
        Button(action: {
            action(link)
        },
        label: {
            HStack {
                if let imageUrl = imageUrl {
                    AsyncImage(url: "https://103fm.maariv.co.il" + imageUrl)
                        .frame(width: 60, height: 60) // Adjust the size as needed
                }
                Text(label)
                    .foregroundColor(buttonColor)
            }
        })
        .onAppear(perform: updateButtonColor)
    }
}
