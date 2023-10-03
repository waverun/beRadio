import SwiftUI

struct CustomNavigationBar: View {
    @Environment(\.presentationMode) var presentationMode

    var title: String

    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.backward")
                    Text("Back")
                }
            }
            Spacer()
            Text(title)
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}
