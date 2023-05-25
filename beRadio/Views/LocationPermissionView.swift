import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    @ObservedObject var locationManager: LocationManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var linkActive = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 20) {
                Text("Location Access Needed")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("To provide you with local stations, we need your permission to access your location. You can change this in your device's settings.")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()

                Text("Here's how:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Open your device's Settings.")
                        .foregroundColor(.white)
                    Text("2. Scroll down and tap on the beRadio app.")
                        .foregroundColor(.white)
                    Text("3. Tap Location.")
                        .foregroundColor(.white)
                    Text("4. Select either 'While Using the App' or 'Always'.")
                        .foregroundColor(.white)
                }
                .padding()

                Button(action: {
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Open Settings")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Dismiss")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                }
                .padding()

            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .environment(\.layoutDirection, .leftToRight)
        .onAppear {
            checkLocationAuthorizationStatus()
        }
    }

    private func checkLocationAuthorizationStatus() {
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            linkActive = true
            presentationMode.wrappedValue.dismiss()
        }
    }
}

//struct LocationPermissionView: View {
//    @ObservedObject var locationManager: LocationManager
//    @Environment(\.presentationMode) var presentationMode
//    @State private var shouldDismiss = false
//
//    var body: some View {
//        VStack {
//            Text("Location Permission Required")
//            Text("Please enable location permissions in settings to search for local stations.")
//            Button("Go to Settings") {
//                if let url = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
//            }
//        }
//        .onAppear(perform: checkLocationPermission)
//        .onChange(of: shouldDismiss, perform: { value in
//            if value {
//                presentationMode.wrappedValue.dismiss()
//            }
//        })
//    }
//
//    func checkLocationPermission() {
//        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
//            shouldDismiss = true
//        }
//    }
//}
