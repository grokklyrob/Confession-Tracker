import Foundation
import Testing
@testable import ConfessionTracker

struct ContentLoaderTests {
    private let expectedStepIDs = [
        "before-you-go-in",
        "entering",
        "sign-of-the-cross",
        "beginning",
        "confessing",
        "counsel-and-penance",
        "act-of-contrition",
        "absolution",
        "dismissal",
        "after-confession",
    ]

    @Test func bundledContentDecodes() {
        let content = ContentLoader.load()
        #expect(content.contentVersion == 1)
        #expect(!content.actOfContrition.title.isEmpty)
        #expect(!content.actOfContrition.body.isEmpty)
        #expect(!content.actOfContrition.source.isEmpty)
        #expect(content.actOfContrition.body[0].hasPrefix("O my God, I am heartily sorry"))
        #expect(content.actOfContrition.source == "Traditional; public domain.")
    }

    @Test func speakersAndTokensAreValid() {
        let content = ContentLoader.load()
        let allowed: Set<GuideLine.Speaker> = [.penitent, .priest, .both, .note]
        var blessMe = 0
        var act = 0
        for step in content.guideSteps {
            for line in step.lines {
                #expect(allowed.contains(line.speaker))
                if line.text.contains("{") {
                    #expect(line.text == "{blessMe}" || line.text == "{actOfContrition}")
                }
                if line.text == "{blessMe}" { blessMe += 1 }
                if line.text == "{actOfContrition}" { act += 1 }
                if line.speaker == .priest {
                    #expect(line.text == "Give thanks to the Lord, for he is good.")
                }
            }
        }
        #expect(blessMe == 1)
        #expect(act == 1)
        #expect(content.guideSteps.map(\.id) == expectedStepIDs)
    }

    @Test func shippedTextMatchesPermittedSources() throws {
        let content = ContentLoader.load()
        let joined = ([content.guideIntro, content.actOfContrition.body.joined(separator: "\n")] + content.guideSteps.flatMap { step in
            [step.title] + step.lines.map(\.text)
        }).joined(separator: "\n")
        let forbidden = [
            "father of mercies",
            "sorry for my sins with all my heart",
            "freed you from your sins",
        ]
        for phrase in forbidden {
            #expect(!joined.lowercased().contains(phrase))
        }
        try ContentLoader.validate(content)
    }
}
