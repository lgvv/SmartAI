import Charts
import SwiftUI

struct ChartView: View {
    private let assessments: [QualityAssessment]

    init(assessments: [QualityAssessment]) {
        self.assessments = assessments
    }

    var body: some View {
        VStack {
            Text("그래프는 2개(CoreML, CNN)\n서버 통신에 문제가 있는 경우 CNN결과가 생략될 수 있습니다.")
                .multilineTextAlignment(.center)
                .foregroundColor(.green)

            Chart(assessments) { assessment in
                ForEach(assessment.grades.sorted { $0.name < $1.name }) { grade in
                    LineMark(
                        x: .value("이름", grade.name),
                        y: .value("확률", grade.probability)
                    )
                    .foregroundStyle(by: .value("타입", assessment.source.rawValue))

                    PointMark(
                        x: .value("이름", grade.name),
                        y: .value("확률", grade.probability)
                    )
                    .foregroundStyle(by: .value("타입", assessment.source.rawValue))
                    .symbol(by: .value("심볼", assessment.source.rawValue))
                }
            }
        }
    }
}
