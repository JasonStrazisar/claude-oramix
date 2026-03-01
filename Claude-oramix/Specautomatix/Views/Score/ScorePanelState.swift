import Foundation

struct ScorePanelState {
    var isChecking: Bool = false
    var ollamaAnalysis: OllamaAnalysis? = nil

    var isCheckButtonDisabled: Bool {
        ollamaAnalysis != nil || isChecking
    }
}
