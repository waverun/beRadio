#if os(tvOS)
import SwiftUI

struct RemovalConfirmationView: View {
    @Environment(\.dismiss) var dismiss

    @State var stationName: String = ""
    @State var showAlert: Bool = false
//    @State var station: Item

    var removalAction: () -> Void

    var body: some View {
        Text("")
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .multilineTextAlignment(.center)  // Horizontal centering
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Remove Station (It can be added again by searching for station)"),
                      message: Text("Are you sure you want to remove\n\n\(stationName)?"),
                      primaryButton: .destructive(Text("Remove")) {
                    removalAction()
                    showAlert = false
                    dismiss()
                },
                      secondaryButton: .cancel({
                    showAlert = false
                    dismiss()
                }))
            }
            .onAppear {
                showAlert = true
            }
    }
}
#endif
