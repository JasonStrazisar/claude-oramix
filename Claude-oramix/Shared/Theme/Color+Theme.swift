import SwiftUI

// MARK: - Theme singleton

extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {

    // MARK: - Base surfaces

    let background   = Color(hex: "F9F8F6")   // Warm white canvas
    let surface      = Color.white
    let surfaceRaised = Color(hex: "FAFAF9")  // Slightly lifted cards
    let border       = Color(hex: "E8E6E1")   // Warm light divider
    let borderLight  = Color(hex: "F0EEE9")   // Hairline separator

    // MARK: - Text

    let textPrimary   = Color(hex: "1A1916")  // Near-black, warm
    let textSecondary = Color(hex: "6B6860")  // Warm medium gray
    let textTertiary  = Color(hex: "A09D99")  // Light warm gray

    // MARK: - Accent / actions

    let accent        = Color(hex: "4F46E5")  // Indigo primary
    let accentLight   = Color(hex: "EEF2FF")  // Indigo tint
    let accentHover   = Color(hex: "4338CA")  // Darker indigo
    let destructive   = Color(hex: "DC2626")  // Red

    // MARK: - Grade A — Green (confident, ready)

    let gradeABadge  = Color(hex: "DCFCE7")
    let gradeAText   = Color(hex: "15803D")
    let gradeAAccent = Color(hex: "22C55E")

    // MARK: - Grade B — Blue (solid, reliable)

    let gradeBBadge  = Color(hex: "DBEAFE")
    let gradeBText   = Color(hex: "1D4ED8")
    let gradeBAccent = Color(hex: "3B82F6")

    // MARK: - Grade C — Amber (caution, not ready)

    let gradeCBadge  = Color(hex: "FEF3C7")
    let gradeCText   = Color(hex: "B45309")
    let gradeCAccent = Color(hex: "F59E0B")

    // MARK: - Grade D — Rose (problem)

    let gradeDBadge  = Color(hex: "FFE4E6")
    let gradeDText   = Color(hex: "BE123C")
    let gradeDAccent = Color(hex: "F43F5E")

    // MARK: - Grade F — Stone (nothing to save)

    let gradeFBadge  = Color(hex: "F1F0EE")
    let gradeFText   = Color(hex: "44403C")
    let gradeFAccent = Color(hex: "78716C")

    // MARK: - Status colors

    let statusReady        = Color(hex: "15803D")
    let statusReadyBg      = Color(hex: "DCFCE7")
    let statusDraft        = Color(hex: "6B6860")
    let statusDraftBg      = Color(hex: "F1F0EE")
    let statusInProgress   = Color(hex: "1D4ED8")
    let statusInProgressBg = Color(hex: "DBEAFE")
    let statusDone         = Color(hex: "15803D")
    let statusDoneBg       = Color(hex: "DCFCE7")
    let statusFailed       = Color(hex: "DC2626")
    let statusFailedBg     = Color(hex: "FFE4E6")
    let statusQueued       = Color(hex: "B45309")
    let statusQueuedBg     = Color(hex: "FEF3C7")
    let statusSplit        = Color(hex: "6B21A8")
    let statusSplitBg      = Color(hex: "F3E8FF")
}

// MARK: - Grade color helpers

extension ThemeColors {
    func badgeColor(for grade: ScoreGrade) -> Color {
        switch grade {
        case .A: return gradeABadge
        case .B: return gradeBBadge
        case .C: return gradeCBadge
        case .D: return gradeDBadge
        case .F: return gradeFBadge
        }
    }

    func textColor(for grade: ScoreGrade) -> Color {
        switch grade {
        case .A: return gradeAText
        case .B: return gradeBText
        case .C: return gradeCText
        case .D: return gradeDText
        case .F: return gradeFText
        }
    }

    func accentColor(for grade: ScoreGrade) -> Color {
        switch grade {
        case .A: return gradeAAccent
        case .B: return gradeBAccent
        case .C: return gradeCAccent
        case .D: return gradeDAccent
        case .F: return gradeFAccent
        }
    }

    func statusColor(for status: SpecStatus) -> Color {
        switch status {
        case .draft:      return statusDraft
        case .ready:      return statusReady
        case .queued:     return statusQueued
        case .inProgress: return statusInProgress
        case .done:       return statusDone
        case .failed:     return statusFailed
        case .split:      return statusSplit
        }
    }

    func statusBgColor(for status: SpecStatus) -> Color {
        switch status {
        case .draft:      return statusDraftBg
        case .ready:      return statusReadyBg
        case .queued:     return statusQueuedBg
        case .inProgress: return statusInProgressBg
        case .done:       return statusDoneBg
        case .failed:     return statusFailedBg
        case .split:      return statusSplitBg
        }
    }
}

// MARK: - Hex initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
