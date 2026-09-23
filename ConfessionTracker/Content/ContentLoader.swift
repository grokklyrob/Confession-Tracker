import Foundation

nonisolated enum ContentLoader {
    static let blessMeToken = "{blessMe}"
    static let actOfContritionToken = "{actOfContrition}"

    static func load(bundle: Bundle = AppBundle.module) -> AppContent {
        guard let url = bundle.url(forResource: "Content", withExtension: "json") else {
            fatalError("Content.json is missing from the app bundle")
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            fatalError("Content.json could not be read: \(error)")
        }
        let content: AppContent
        do {
            content = try JSONDecoder().decode(AppContent.self, from: data)
        } catch {
            fatalError("Content.json could not be decoded: \(error)")
        }
        do {
            try validate(content)
        } catch {
            fatalError("Content.json is invalid: \(error)")
        }
        return content
    }

    static func validate(_ content: AppContent) throws {
        if content.actOfContrition.body.isEmpty || content.actOfContrition.body.contains(where: \.isEmpty) {
            throw ContentValidationError.emptyPrayerBody
        }
        if content.actOfContrition.title.isEmpty || content.actOfContrition.source.isEmpty {
            throw ContentValidationError.emptyPrayerBody
        }
        var seenIDs = Set<String>()
        var blessMeCount = 0
        var actCount = 0
        for step in content.guideSteps {
            if !seenIDs.insert(step.id).inserted {
                throw ContentValidationError.duplicateStepID(step.id)
            }
            for line in step.lines {
                if line.text.contains("{") {
                    guard line.text == blessMeToken || line.text == actOfContritionToken else {
                        throw ContentValidationError.invalidToken(line.text)
                    }
                }
                if line.text == blessMeToken { blessMeCount += 1 }
                if line.text == actOfContritionToken { actCount += 1 }
            }
        }
        if blessMeCount != 1 {
            throw ContentValidationError.tokenCount(blessMeToken, blessMeCount)
        }
        if actCount != 1 {
            throw ContentValidationError.tokenCount(actOfContritionToken, actCount)
        }
    }
}

nonisolated enum ContentValidationError: Error, Equatable, CustomStringConvertible {
    case emptyPrayerBody
    case duplicateStepID(String)
    case invalidToken(String)
    case tokenCount(String, Int)

    var description: String {
        switch self {
        case .emptyPrayerBody:
            return "Act of Contrition body is empty"
        case .duplicateStepID(let id):
            return "Duplicate guide step id \(id)"
        case .invalidToken(let text):
            return "Invalid guide token \(text)"
        case .tokenCount(let token, let count):
            return "Token \(token) appears \(count) times"
        }
    }
}
