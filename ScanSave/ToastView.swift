import SwiftUI

/// A pill-shaped banner styled like the Dynamic Island, used for transient confirmations.
struct ToastView: View {
    let message: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
            Text(message)
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(.black)
                .opacity(0.85)
        }
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}

// MARK: - Toast Modifier

private struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let systemImage: String
    let duration: TimeInterval

    @State private var offset: CGFloat = -120

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    ToastView(message: message, systemImage: systemImage)
                        .offset(y: offset)
                        .padding(.top, 60)
                        .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                offset = 0
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    offset = -120
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isPresented = false
                                }
                            }
                        }
                        .transition(.identity)
                }
            }
    }
}

// MARK: - View Extension

extension View {
    /// Shows a pill-shaped toast banner at the top of the view.
    /// - Parameters:
    ///   - isPresented: A binding that controls visibility.
    ///   - message: The text to display.
    ///   - systemImage: An SF Symbol name.
    ///   - duration: How long to show the toast (default 2s).
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        systemImage: String = "checkmark.circle.fill",
        duration: TimeInterval = 2.0
    ) -> some View {
        modifier(
            ToastModifier(
                isPresented: isPresented,
                message: message,
                systemImage: systemImage,
                duration: duration
            )
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Button("Show Toast") { }
    }
    .toast(isPresented: .constant(true), message: "PDF Saved")
}
