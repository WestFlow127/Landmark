//
//  ToastService.swift
//  Landmark
//

import SwiftUI

struct Toast: Identifiable, Equatable {
    enum Style {
        case success
        case error

        var systemImage: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.triangle.fill"
            }
        }

        var tint: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
    }

    let id = UUID()
    let message: String
    let style: Style
}

/// Shows a short-lived message at the top of the screen, e.g. to confirm an action succeeded.
/// Call `ToastService.shared.show(...)` from anywhere on the main actor; the toast is rendered
/// by the `.toastHost()` modifier applied at the app's root view.
@MainActor
final class ToastService: ObservableObject {
    static let shared = ToastService()

    @Published private(set) var current: Toast?

    private var dismissTask: Task<Void, Never>?

    private init() {}

    /// Replaces any toast that's already showing.
    func show(_ message: String, style: Toast.Style = .success, duration: Duration = .seconds(2.5)) {
        self.dismissTask?.cancel()

        withAnimation(.spring(duration: 0.4, bounce: 0.25)) {
            self.current = Toast(message: message, style: style)
        }

        UINotificationFeedbackGenerator().notificationOccurred(style == .success ? .success : .error)

        self.dismissTask = Task { [weak self] in
            try? await Task.sleep(for: duration)
            guard !Task.isCancelled else { return }

            self?.dismiss()
        }
    }

    func dismiss() {
        self.dismissTask?.cancel()

        withAnimation(.easeInOut(duration: 0.25)) {
            self.current = nil
        }
    }
}

private struct ToastView: View {
    let toast: Toast

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: self.toast.style.systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(self.toast.style.tint)

            Text(self.toast.message)
                .font(.dmSans(15, semibold: true))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.inputBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
    }
}

private struct ToastHostModifier: ViewModifier {
    @ObservedObject var service: ToastService

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast = self.service.current {
                ToastView(toast: toast)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { self.service.dismiss() }
                    .id(toast.id)
            }
        }
    }
}

extension View {
    /// Renders `ToastService` toasts over this view. Apply once, at the root.
    func toastHost(_ service: ToastService = .shared) -> some View {
        self.modifier(ToastHostModifier(service: service))
    }
}
