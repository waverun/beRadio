//import SwiftUI
//
//struct RightToLeftSlider: View {
//    @Binding var value: Double
//    let minValue: Double
//    let maxValue: Double
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .leading) {
//                RoundedRectangle(cornerRadius: 4)
//                    .foregroundColor(.gray.opacity(0.3))
//
//                RoundedRectangle(cornerRadius: 4)
//                    .frame(width: geometry.size.width * CGFloat(1 - (value - minValue) / (maxValue - minValue)))
//                    .foregroundColor(.accentColor)
//                    .padding(.trailing, 4)
//
//                Circle()
//                    .foregroundColor(.white)
//                    .frame(width: 24, height: 24)
//                    .offset(x: CGFloat(1 - (value - minValue) / (maxValue - minValue)) * geometry.size.width - 12, y: 0)
//                    .gesture(DragGesture()
//                        .onChanged { gestureValue in
//                            let newValue = Double(1) - Double(gestureValue.location.x / geometry.size.width)
//                            value = min(maxValue, max(minValue, newValue * (maxValue - minValue) + minValue))
//                        }
//                    )
//            }
//            .frame(height: 24)
//        }
//    }
//}
