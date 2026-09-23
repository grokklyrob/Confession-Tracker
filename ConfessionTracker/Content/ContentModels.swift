import Foundation

nonisolated struct AppContent: Codable, Equatable {
    let contentVersion: Int
    let actOfContrition: Prayer
    let guideIntro: String
    let guideSteps: [GuideStep]
}

nonisolated struct Prayer: Codable, Equatable {
    let title: String
    let body: [String]
    let source: String
}

nonisolated struct GuideStep: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let lines: [GuideLine]
}

nonisolated struct GuideLine: Codable, Equatable {
    enum Speaker: String, Codable {
        case penitent
        case priest
        case both
        case note
    }

    let speaker: Speaker
    let text: String
}
