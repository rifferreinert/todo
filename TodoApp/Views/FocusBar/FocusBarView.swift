// FocusBarView.swift
// SwiftUI view for the always-on-top focus bar

import SwiftUI

/// A SwiftUI view that displays the current focus task's title and an opacity slider.
/// - Parameters:
///   - title: The current focus task's title (String).
///   - opacity: The current opacity value (Double, 0.2–1.0).
///   - onOpacityChange: Closure called when the opacity slider changes.
struct FocusBarView: View {
    let title: String
    @Binding var opacity: Double
    var onOpacityChange: ((Double) -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Text(title.isEmpty ? "No Focus Task" : title)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)
                .accessibilityLabel(title.isEmpty ? "No Focus Task" : title)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 4) {
                Image(systemName: "circle.lefthalf.filled")
                    .accessibilityHidden(true)
                Slider(value: $opacity, in: 0.2...1.0, step: 0.01, onEditingChanged: { _ in
                    onOpacityChange?(opacity)
                })
                .frame(width: 100)
                .accessibilityLabel("Todo Bar Opacity")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 28)
        .background(.ultraThinMaterial.opacity(opacity))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
struct FocusBarView_Previews: PreviewProvider {
    @State static var previewOpacity: Double = 1.0
    static var previews: some View {
        FocusBarView(
            title: "This is a very long focus task title that should be" +
                "truncated with ellipsis if it does not fit in the bar",
            opacity: $previewOpacity
        )
        .previewLayout(.fixed(width: 800, height: 28))
    }
}
#endif
