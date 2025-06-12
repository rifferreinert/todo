// FocusBarView.swift
// SwiftUI view for the always-on-top focus bar

import SwiftUI
import Foundation

// Import the settings utility file so FocusBarOpacitySettings is visible
// (No explicit import needed if in same module, but ensure file is in target membership)
#if canImport(FocusBarOpacitySettings)
import FocusBarOpacitySettings
#endif

/// A SwiftUI view that displays the current focus task's title and an opacity slider.
/// - Parameters:
///   - title: The current focus task's title (String).
///   - opacity: The current opacity value (Double, 0.2–1.0).
struct FocusBarView: View {
    let title: String
    @Binding var opacity: Double

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
                Slider(
                    value: $opacity,
                    in: FocusBarOpacitySettings.minOpacity...FocusBarOpacitySettings.maxOpacity,
                    step: 0.01
                )
                .frame(width: 100)
                .accessibilityLabel("Todo Bar Opacity")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 28)
        .background(.ultraThinMaterial)
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
