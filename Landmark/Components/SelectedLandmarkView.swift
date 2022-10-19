//
//  SelectedLandmarkView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/21/22.
//

import SwiftUI

enum LandmarkDisplayTitles: String {
    case name = "Landmark"
    case location = "Address"
    case description = "Description"
}

struct SelectedLandmarkView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var viewModel: LandmarkMainViewModel
    
    @State private var name: String
    @State private var location: String
    @State private var description: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                imageTabView
                
                VStack(alignment: .leading, spacing: 8){
                    Text(name)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .fixedSize()
                    
                    Text(location)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Divider()

                    Text(description)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
        .overlay(backButton, alignment: .topTrailing)
    }
    
    init(selectedLandmark: LandmarkEntity) {
//        _viewModel = StateObject(wrappedValue: viewModel)
        
        _name = State(initialValue: selectedLandmark.name)
        _location = State(initialValue: selectedLandmark.location)
        _description = State(initialValue: selectedLandmark.description)
    }
}

struct SelectedLandmarkView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedLandmarkView(selectedLandmark: LandmarkEntity(name: "Venice Beach"))
    }
}

extension SelectedLandmarkView {
    private var imageTabView: some View {
        TabView {
            ForEach(viewModel.selectedLandmarkImages, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width)
            }
        }
        .frame(height: UIScreen.main.bounds.height / 3)
        .shadow(radius: 20, x: 0, y: 10)
    }
    
    private var backButton: some View {
        Button {
            viewModel.selectedLandmark = nil
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(8)
                .foregroundColor(.primary)
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
        }

    }
}
