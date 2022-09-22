//
//  SelectedLandmarkView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/21/22.
//

import SwiftUI

struct SelectedLandmarkView: View {
    @Environment(\.dismiss) var dismiss
    var landmark: LandmarkEntity
    
    @State private var name: String
    @State private var locationString: String
    @State private var description: String
    
    var body: some View {
        NavigationView {
            GeometryReader{ proxy in
                
                VStack(alignment: .leading) {
                    Image("test_landmark")
                        .resizable()
                        .frame(width: proxy.size.width)
                        .aspectRatio(contentMode: .fit)
                    
                    
                    Text("Landmark:  " + name)
                        .font(Font.landmarkFontBold(25))
                        .padding(5)
                        .fixedSize()
                    
                    Text("Address: " + locationString)
                        .font(Font.landmarkFontBold(20))
                        .padding(5)
                    
                    Text("Description: " + description)
                        .font(Font.landmarkFontBold(20))
                        .padding(5)
                }
            }
        }.ignoresSafeArea()
    }
    
    init(landmark: LandmarkEntity) {
        self.landmark = landmark
        
        _name = State(initialValue: landmark.name)
        _locationString = State(initialValue: landmark.location)
        _description = State(initialValue: landmark.description)
    }
}

struct SelectedLandmarkView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedLandmarkView(landmark: LandmarkEntity(name: "Venice Beach Boardwalk"))
    }
}
