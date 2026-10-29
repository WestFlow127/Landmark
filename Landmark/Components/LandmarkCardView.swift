//
//  LandmarkCardView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/21/22.
//

import SwiftUI

struct LandmarkCardView: View {
    @StateObject private var viewModel: LandmarkCardViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingLarge) {
                TabView {
                    ForEach(self.viewModel.landmarkImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }
                }
                .tabViewStyle(.page)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusMedium))

                if let location = self.viewModel.landmark.location, !location.isEmpty {
                    self.locationRow(location)
                }

                Text(self.viewModel.landmark.name)
                    .font(.title2)
                    .fontWeight(.semibold)

                if let description = self.viewModel.landmark.description, !description.isEmpty {
                    Text(description)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }

    init(viewModel: LandmarkCardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private func locationRow(_ location: String) -> some View {
        HStack(spacing: .spacingSmall) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.red)

            Text(location)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
}

struct LandmarkCardView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkCardView(viewModel: LandmarkCardViewModel(landmark: Landmark(name: "Venice Beach Boardwalk")))
    }
}
