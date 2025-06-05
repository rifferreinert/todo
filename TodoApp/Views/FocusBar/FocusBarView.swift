import SwiftUI

/// Focus bar UI containing an opacity slider.
struct FocusBarView: View {
    /// Binding to the current bar opacity stored in `UserDefaults`.
    @Binding var opacity: Double

    var body: some View {
        Slider(value: $opacity, in: 0.2...1)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
    }
}

#if DEBUG
#Preview {
    FocusBarView(opacity: .constant(0.8))
        .frame(width: 800, height: 28)
}
#endif
