import Foundation

/// Shared magnitude for every relative interval in the app (summary, history, guide).
nonisolated enum IntervalBucket: Equatable {
    /// 0 calendar days.
    case sameDay
    /// 1...13 calendar days.
    case days(Int)
    /// 2...8 weeks.
    case weeks(Int)
    /// 2...23 months.
    case months(Int)
    /// 2 or more years. A 1-year bucket cannot occur.
    case years(Int)

    /// Lexicographic rank used to assert the bucket never shrinks as the span grows.
    var rank: (unit: Int, value: Int) {
        switch self {
        case .sameDay:
            return (0, 0)
        case .days(let value):
            return (1, value)
        case .weeks(let value):
            return (2, value)
        case .months(let value):
            return (3, value)
        case .years(let value):
            return (4, value)
        }
    }
}
