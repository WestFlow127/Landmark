//
//  ProfileView.swift
//  Landmark
//

import PhotosUI
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var pickerItem: PhotosPickerItem?

    /// Natural height of the scrolling content, so the popover hugs it when there's room
    /// and the scroll view takes over when the keyboard shrinks the available space.
    @State private var contentHeight: CGFloat = 0

    private let accent = Color.red

    var body: some View {
        VStack(spacing: 16) {
            // Save sits outside the scroll view so it stays visible above the keyboard.
            ScrollView {
                VStack(spacing: 20) {
                    self.header

                    VStack(spacing: 16) {
                        self.field("Name", text: self.$viewModel.name, contentType: .name)
                        self.field("Bio", text: self.$viewModel.bio, axis: .vertical, lines: 3 ... 5)
                        self.field("City", text: self.$viewModel.city, contentType: .addressCity)

                        HStack(alignment: .top, spacing: 16) {
                            self.field("State", text: self.$viewModel.state, contentType: .addressState)
                            self.field("Country", text: self.$viewModel.country, contentType: .countryName)
                        }
                    }
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: ContentHeightKey.self, value: proxy.size.height)
                    }
                )
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .frame(maxHeight: self.contentHeight > 0 ? self.contentHeight : nil)
            .onPreferenceChange(ContentHeightKey.self) { self.contentHeight = $0 }

            self.saveButton
        }
        .padding(24)
        .frame(width: 330)
        .tint(self.accent)
        .task { await self.viewModel.load() }
        .onChange(of: self.pickerItem) { _, item in
            Task { await self.loadPickedImage(item) }
        }
        .alert(
            "Profile",
            isPresented: Binding(
                get: { self.viewModel.errorMessage != nil },
                set: { if !$0 { self.viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(self.viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            self.profilePicture

            Text(self.displayName)
                .font(.dmSans(20, semibold: true))
                .foregroundStyle(self.viewModel.name.isEmpty ? .secondary : .primary)
                .lineLimit(1)

            if let location = self.locationSummary {
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(.robotoCondensed(14))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var displayName: String {
        let name = self.viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines)

        return name.isEmpty ? "Your Profile" : name
    }

    /// "City, State, Country" with any blank parts left out, or nil if all are blank.
    private var locationSummary: String? {
        let parts = [self.viewModel.city, self.viewModel.state, self.viewModel.country]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    /// A blank placeholder until the user picks a picture.
    private var profilePicture: some View {
        PhotosPicker(selection: self.$pickerItem, matching: .images) {
            Group {
                if let image = self.viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(26)
                        .foregroundStyle(self.accent.opacity(0.75))
                        .background(self.accent.opacity(0.1))
                }
            }
            .frame(width: 96, height: 96)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(self.accent.opacity(0.5), lineWidth: 1.5))
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(self.accent, in: Circle())
                    .overlay(Circle().strokeBorder(.background, lineWidth: 2))
            }
        }
        .accessibilityLabel("Profile picture")
        .accessibilityHint("Choose a new picture")
    }

    // MARK: - Fields

    /// A small monospaced label above a softly filled field.
    private func field(
        _ title: String,
        text: Binding<String>,
        axis: Axis = .horizontal,
        lines: ClosedRange<Int> = 1 ... 1,
        contentType: UITextContentType? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.plexMono(10))
                .tracking(1.2)
                .foregroundStyle(.secondary)

            TextField(title, text: text, axis: axis)
                .font(.dmSans(16))
                .textContentType(contentType)
                .lineLimit(lines)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.inputBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.inputBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            Task { await self.viewModel.save() }
        } label: {
            Group {
                if self.viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("SAVE")
                        .font(.robotoCondensed(16, bold: true))
                        .tracking(1.5)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(self.accent.opacity(self.viewModel.canSave ? 1 : 0.35), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!self.viewModel.canSave)
    }

    private func loadPickedImage(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data)
        else {
            return
        }

        self.viewModel.imagePicked(image)
    }
}

private struct ContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    ProfileView()
}
