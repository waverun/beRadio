import SwiftUI

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    var title: String
    var message: String
    var onAgree: () -> Void
    var onDisagree: () -> Void
    var onOpenSite: () -> Void

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                VStack {
                    Text(title)
                        .font(.headline)
                        .padding()
                    Text(message)
                        .padding()
                    HStack {
                        Button("Agree") {
                            isPresented = false
                            onAgree()
                        }
                        Spacer()
                        Button("Go to station's site") {
                            isPresented = false
                            onOpenSite()
                        }
                        Spacer()
                        Button("Disagree") {
                            isPresented = false
                            onDisagree()
                        }
                    }
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding()
            }
        }
    }
}
