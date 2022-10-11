struct BananaGrade: Hashable, Identifiable {
    let name: String
    let probability: Float

    var id: String { name }
}
