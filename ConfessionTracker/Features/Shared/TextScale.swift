import SwiftUI

enum TextScale {
    static func resolvedSteps(_ stored: Int) -> Int {
        switch stored {
        case 2, 4:
            return stored
        default:
            return 0
        }
    }

    static func stepped(system: DynamicTypeSize, storedSteps: Int) -> DynamicTypeSize {
        let sizes = Array(DynamicTypeSize.allCases)
        guard let index = sizes.firstIndex(of: system) else { return .accessibility5 }
        let next = min(index + resolvedSteps(storedSteps), sizes.count - 1)
        return sizes[next]
    }
}
