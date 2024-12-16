import SwiftUI

struct PieChartData {
    let label: String
    let value: Double
    let color: Color
}

struct PieChartView: View {
    var data: [PieChartData]
    @State private var animated: Bool = false
    
    var total: Double {
        data.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    let startAngle = angle(for: index)
                    let endAngle = angle(for: index + 1)
                    
                    PieSliceView(startAngle: startAngle, endAngle: endAngle)
                        .fill(data[index].color)
                        .scaleEffect(animated ? 1 : 0)
                        .animation(.spring(response: 1.0, dampingFraction: 0.6), value: animated)
                        .overlay(
                            PieSliceView(startAngle: startAngle, endAngle: endAngle)
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                    Text("Quarterly Revenue")
                    .font(.title2)
                    .foregroundColor(.black)
                
                ForEach(0..<data.count, id: \.self) { index in
                    let midAngle = (angle(for: index).degrees + angle(for: index + 1).degrees) / 2
                    let radius = geometry.size.width * 0.25
                    let xOffset = cos(CGFloat(midAngle) * .pi / 180) * radius
                    let yOffset = sin(CGFloat(midAngle) * .pi / 180) * radius
                    
                    Text("\(data[index].label)\n\(Int(data[index].value / total * 100))%")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 0) 
                        .offset(x: xOffset, y: yOffset)
                }

            }
            .onAppear {
                animated = true
            }
            .background(Color(UIColor.systemGray5))
        }
    }
    
    private func angle(for index: Int) -> Angle {
        let start = data.prefix(index).reduce(0) { $0 + $1.value }
        return .degrees(start / total * 360 - 90)
    }
}

struct PieSliceView: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}
