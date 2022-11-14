import XCTest
@testable import SmartAI

final class BananaResponseDTOTests: XCTestCase {
    private let json = Data("""
    {
      "img_name": "2022-11-21.jpg",
      "banana_classes": { "0": "정상", "1": "과숙", "2": "미숙" },
      "Probability": { "0": 0.61, "1": 0.32, "2": 0.07 },
      "argmax": 0
    }
    """.utf8)

    func test_서버_응답을_스네이크케이스_키로_디코딩한다() throws {
        let dto = try when("응답을 디코딩한다") {
            try JSONDecoder().decode(BananaResponseDTO.self, from: json)
        }

        then("문자열 키가 정수 키로 매핑된다") {
            XCTAssertEqual(dto.imgName, "2022-11-21.jpg")
            XCTAssertEqual(dto.argmax, 0)
            XCTAssertEqual(dto.bananaClasses, [0: "정상", 1: "과숙", 2: "미숙"])
            XCTAssertEqual(dto.probability[0], 0.61)
            XCTAssertEqual(dto.probability[2], 0.07)
        }
    }

    func test_도메인_변환은_등급_이름과_확률을_제자리에_넣는다() throws {
        let dto = try given("세 등급이 담긴 응답이 있다") {
            try JSONDecoder().decode(BananaResponseDTO.self, from: json)
        }

        let assessment = when("도메인으로 변환한다") {
            dto.toDomain()
        }

        then("등급 이름과 확률이 뒤바뀌지 않는다") {
            XCTAssertEqual(assessment.source, .server)
            XCTAssertEqual(assessment.grades.map(\.name), ["정상", "과숙", "미숙"])
            XCTAssertEqual(assessment.grades.map(\.probability), [0.61, 0.32, 0.07])
        }
    }

    func test_도메인_변환은_argmax를_상위_등급_이름으로_삼는다() throws {
        let dto = try given("argmax가 1인 응답이 있다") {
            try JSONDecoder().decode(BananaResponseDTO.self, from: Data("""
            {
              "img_name": "a.jpg",
              "banana_classes": { "0": "정상", "1": "과숙" },
              "Probability": { "0": 0.30, "1": 0.70 },
              "argmax": 1
            }
            """.utf8))
        }

        let assessment = when("도메인으로 변환한다") {
            dto.toDomain()
        }

        then("argmax가 가리키는 이름이 상위 등급이 된다") {
            XCTAssertEqual(assessment.topGradeName, "과숙")
        }
    }

    func test_도메인_변환은_확률이_없는_등급을_제외한다() throws {
        let dto = try given("확률이 빠진 등급이 있는 응답이 있다") {
            try JSONDecoder().decode(BananaResponseDTO.self, from: Data("""
            {
              "img_name": "a.jpg",
              "banana_classes": { "0": "정상", "1": "과숙" },
              "Probability": { "0": 0.90 },
              "argmax": 0
            }
            """.utf8))
        }

        let assessment = when("도메인으로 변환한다") {
            dto.toDomain()
        }

        then("확률이 있는 등급만 남는다") {
            XCTAssertEqual(assessment.grades.map(\.name), ["정상"])
        }
    }
}
