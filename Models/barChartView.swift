import SwiftUI
import Charts

struct AnalyticsChartView: View {
    var data: [ChartData]

    @State private var animatedData: [ChartData] = []

    var body: some View {
        VStack {
            Chart {
                ForEach(animatedData, id: \.month) { item in
                    BarMark(
                        x: .value("Month", item.month),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(Color.orange)
                }
                ForEach(animatedData, id: \.month) { item in
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Line Value", item.lineValue)
                    )
                    .foregroundStyle(Color.black)
                }
                ForEach(animatedData, id: \.month) { item in
                    PointMark(
                        x: .value("Month", item.month),
                        y: .value("Line Value", item.lineValue)
                    )
                    .symbol {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 10, height: 10)
                    }
                    .annotation(position: .top) {
                        Text("\(Int(item.lineValue))")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
            .background(Color(UIColor.systemGray5))
            .frame(height: 252)
            .animation(.easeInOut(duration: 2.0), value: animatedData)
            .onAppear {
                withAnimation {
                    animatedData = data
                }
            }
        }
    }
}

struct ChartData: Identifiable, Equatable {
    let id = UUID()
    let month: String
    let value: Double
    let lineValue: Double
}
