import SwiftUI

struct GuideLineView: View {
    let line: GuideLine
    let prayer: Prayer
    let blessMeSentence: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage(PreferenceKeys.textSizeSteps) private var storedSteps = 0

    var body: some View {
        VStack(alignment: .leading, spacing: line.speaker == .note ? 0 : 4) {
            if let speakerKey {
                Text(speakerKey)
                    .font(.caption.bold())
                    .foregroundStyle(speakerStyle)
            }
            bodyContent
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilityText))
    }

    @ViewBuilder
    private var bodyContent: some View {
        if line.text == ContentLoader.actOfContritionToken {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(prayer.body.enumerated()), id: \.offset) { _, paragraph in
                    readingText(paragraph, font: .body, color: .primary)
                }
            }
        } else if line.speaker == .note {
            readingText(displayedText, font: .footnote, color: .primary)
        } else {
            readingText(displayedText, font: .body, color: .primary)
        }
    }

    private func readingText(_ text: String, font: Font, color: Color) -> some View {
        Text(verbatim: text)
            .font(font)
            .foregroundStyle(color)
            .textSelection(.enabled)
            .dynamicTypeSize(TextScale.stepped(system: dynamicTypeSize, storedSteps: storedSteps))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var displayedText: String {
        if line.text == ContentLoader.blessMeToken {
            return blessMeSentence
        }
        return line.text
    }

    private var speakerKey: LocalizedStringKey? {
        switch line.speaker {
        case .penitent:
            "guide.speaker.you"
        case .priest:
            "guide.speaker.priest"
        case .both:
            "guide.speaker.together"
        case .note:
            nil
        }
    }

    private var speakerStyle: Color {
        switch line.speaker {
        case .penitent:
            Color.accentColor
        case .priest:
            Color.secondary
        case .both, .note:
            Color.primary
        }
    }

    private var accessibilityText: String {
        let body = accessibilityBody
        switch line.speaker {
        case .penitent:
            return "\(String(localized: "guide.speaker.you", bundle: AppBundle.module)): \(body)"
        case .priest:
            return "\(String(localized: "guide.speaker.priest", bundle: AppBundle.module)): \(body)"
        case .both:
            return "\(String(localized: "guide.speaker.together", bundle: AppBundle.module)): \(body)"
        case .note:
            return body
        }
    }

    private var accessibilityBody: String {
        if line.text == ContentLoader.actOfContritionToken {
            return prayer.body.joined(separator: "\n\n")
        }
        return displayedText
    }
}

#if DEBUG
#Preview {
    List {
        GuideLineView(
            line: GuideLine(speaker: .penitent, text: "{blessMe}"),
            prayer: Prayer(title: "Act of Contrition", body: ["O my God."], source: "Traditional; public domain."),
            blessMeSentence: "Bless me, Father, for I have sinned. It has been [time] since my last confession."
        )
    }
}
#endif
