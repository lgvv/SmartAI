struct QualityAssessment: Hashable, Identifiable {
    let source: InferenceSource
    let topGradeName: String
    let grades: [BananaGrade]

    var id: String { source.rawValue }

    func prefixed(by count: Int) -> QualityAssessment {
        QualityAssessment(source: source,
                          topGradeName: topGradeName,
                          grades: Array(grades.prefix(count)))
    }
}
