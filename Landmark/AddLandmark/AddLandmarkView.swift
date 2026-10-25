//
//  AddLandmarkView.swift
//  Landmark
//

import SwiftUI

struct AddLandmarkView: View {
    @StateObject var viewModel: AddLandmarkViewModel

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
                    self.viewModel.uploadLandmark()
                } label: {
                    Text("Upload Landmark")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!self.viewModel.canUpload)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("New Landmark")
        .navigationBarTitleDisplayMode(.inline)
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
                Text("Location unavailable. Enable Location Services to add a landmark.")
                    .foregroundColor(.red)
            } else {
                Text(self.viewModel.addressText)
                    .foregroundColor(.secondary)
            }
        }
        .font(.subheadline)
    }
}
