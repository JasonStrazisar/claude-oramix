import SwiftUI

// MARK: - Agent

enum Agent: Int, CaseIterable, Identifiable {
    case specautomatix, nuitefix

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .specautomatix: return "Specautomatix"
        case .nuitefix:      return "Nuitéfix"
        }
    }

    var iconName: String {
        switch self {
        case .specautomatix: return "AgentIconSpecautomatix"
        case .nuitefix:      return "AgentIconNuitefix"
        }
    }

}

// MARK: - ChevronsUpDownIcon

private struct ChevronsUpDownShape: Shape {
    func path(in rect: CGRect) -> Path {
        // SVG viewBox: 0 0 10 15
        let sx = rect.width / 10
        let sy = rect.height / 15
        var p = Path()
        // bottom chevron ↓
        p.move(to:    CGPoint(x: 0.834961 * sx, y: 10.0017 * sy))
        p.addLine(to: CGPoint(x: 5.00163  * sx, y: 14.1683 * sy))
        p.addLine(to: CGPoint(x: 9.16829  * sx, y: 10.0017 * sy))
        // top chevron ↑
        p.move(to:    CGPoint(x: 0.834961 * sx, y: 5.00166  * sy))
        p.addLine(to: CGPoint(x: 5.00163  * sx, y: 0.834991 * sy))
        p.addLine(to: CGPoint(x: 9.16829  * sx, y: 5.00166  * sy))
        return p
    }
}

private struct ChevronsUpDownIcon: View {
    var body: some View {
        ChevronsUpDownShape()
            .stroke(
                Color(hex: "A4A7AE"),
                style: StrokeStyle(lineWidth: 1.67, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 10, height: 15)   // native SVG size
            .frame(width: 20, height: 20)   // centred in inner area (32 − 2×6)
            .padding(6)                     // 32×32 container with 6px padding
    }
}

// MARK: - AgentRadioButton

private struct AgentRadioButton: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color(hex: "155EEF") : Color.white)
                .frame(width: 16, height: 16)
            if isSelected {
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .stroke(Color(hex: "D0D5DD"), lineWidth: 1.5)
                    .frame(width: 16, height: 16)
            }
        }
    }
}

// MARK: - AgentMenuRow

private struct AgentMenuRow: View {
    let agent: Agent
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isHovered = false

    private var rowBackground: Color {
        if isSelected { return Color(hex: "FAFAFA") }
        return isHovered ? Color(hex: "F5F5F5") : .clear
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(agent.iconName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )

                Text(agent.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "181D27"))

                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(rowBackground)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(alignment: .topTrailing) {
                AgentRadioButton(isSelected: isSelected)
                    .padding(8)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

// MARK: - AgentPickerPanel

private struct AgentPickerPanel: View {
    @Binding var activeAgent: Agent
    @Binding var isOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Changer d'agent")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: "535862"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

            VStack(spacing: 8) {
                ForEach(Agent.allCases) { agent in
                    AgentMenuRow(agent: agent, isSelected: agent == activeAgent) {
                        activeAgent = agent
                        isOpen = false
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "E9EAEB"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
    }
}

// MARK: - AgentSelectorView

struct AgentSelectorView: View {
    @Binding var activeAgent: Agent
    @State private var isHovered = false
    @State private var isOpen = false
    @State private var triggerHeight: CGFloat = 0
    @State private var triggerWidth: CGFloat = 0

    var body: some View {
        Button { isOpen.toggle() } label: {
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(activeAgent.iconName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )

                    Text(activeAgent.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "181D27"))
                }

                Spacer()

                ChevronsUpDownIcon()
            }
            .padding(12)
            .background(isHovered ? Color(hex: "F5F5F5") : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "E9EAEB"), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .padding(8)
        .onHover { isHovered = $0 }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    triggerHeight = geo.size.height
                    triggerWidth  = geo.size.width
                }
            }
        )
        .overlay(alignment: .topLeading) {
            if isOpen {
                AgentPickerPanel(activeAgent: $activeAgent, isOpen: $isOpen)
                    .frame(width: triggerWidth - 16)
                    .offset(x: 8, y: triggerHeight)
                    .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
        .animation(.easeOut(duration: 0.15), value: isOpen)
        .zIndex(isOpen ? 100 : 0)
    }
}
