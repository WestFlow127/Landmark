//
//  AddLandmarkView.swift
//  Landmark
//

import SwiftUI

struct AddLandmarkView: View {
    @StateObject var viewModel: AddLandmarkViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(uiImage: self.viewModel.croppedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                self.locationRow

                TextField("Landmark title", text: self.$viewModel.title)
                    .textFieldStyle(.roundedBorder)

                TextField("Description", text: self.$viewModel.landmarkDescription, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await self.viewModel.uploadLandmark() }
                } label: {
                    Group {
                        if self.viewModel.isUploading {
                            ProgressView()
                        } else {
                            Text("Post Landmark")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!self.viewModel.canUpload || self.viewModel.isUploading)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("New Landmark")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: self.viewModel.didUpload) { didUpload in
            if didUpload { self.dismiss() }
        }
        .alert("Upload Failed", isPresented: Binding(
            get: { self.viewModel.uploadErrorMessage != nil },
            set: { if !$0 { self.viewModel.uploadErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(self.viewModel.uploadErrorMessage ?? "")
        }
    }

    private var locationRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.red)

            if self.viewModel.isLoadingLocation {
                ProgressView()
                Text("Getting location…")
                    .foregroundColor(.secondary)
            } else if self.viewModel.coordinate == nil {
                Text("We couldn't determine this landmark's location. Enable Location Services and try again.")
                    .foregroundColor(.red)
            } else {
                Text(self.viewModel.addressText)
                    .foregroundColor(.secondary)
            }
        }
        .font(.subheadline)
    }
}
