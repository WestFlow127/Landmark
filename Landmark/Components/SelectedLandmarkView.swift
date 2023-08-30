//
//  SelectedLandmarkView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/21/22.
//

import SwiftUI

enum LandmarkDisplayTitles: String
{
    case name = "Landmark"
    case location = "Address"
    case description = "Description"
}

struct SelectedLandmarkView: View
{
    @Environment(\.dismiss) var dismiss
    var landmark: LandmarkEntity
    var subTitles: [LandmarkDisplayTitles] = [.location, .description]
    
    @State private var name: String
    @State private var location: String
    @State private var description: String
    
    var body: some View
    {
        NavigationView
        {
            GeometryReader
            { proxy in
                
                VStack(alignment: .leading)
                {
                    Image("test_landmark")
                        .resizable()
                        .frame(width: proxy.size.width)
                        .offset(CGSize(width: -5, height: -5))
                        .aspectRatio(contentMode: .fit)
                    
                    HStack
                    {
                        Text(LandmarkDisplayTitles.name.rawValue + ": ")
                            .font(Font.landmarkFontBold(25))
                            .padding(4)
                            .offset(x: 2.5, y: 2.5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary, lineWidth: 2)
                            }
                        
                        Text(name)
                            .font(Font.landmarkFontBold(25))
                            .padding(5)
                            .offset(x: 2.5, y: 2.5)
                            .fixedSize()
                    }

                    ForEach(subTitles, id: \.self) { title in
                        Divider()
                        
                        HStack
                        {
                            Text(title.rawValue + ": ")
                                .font(Font.landmarkFontBold(21))
                                .padding(5)
                                .offset(x: 2.5, y: 2.5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary, lineWidth: 2)
                                }
                            
                            Text(getDisplayValue(forTitle: title))
                                .font(Font.landmarkFontBold(21))
                                .padding(5)
                                .offset(x: 2.5, y: 2.5)
                        }
                    }
                }.padding(5)
            }
        }.ignoresSafeArea()
    }
    
    init(landmark: LandmarkEntity)
    {
        self.landmark = landmark
        
        _name = State(initialValue: landmark.name)
        _location = State(initialValue: landmark.location)
        _description = State(initialValue: landmark.description)
    }
    
    func getDisplayValue(forTitle: LandmarkDisplayTitles) -> String
    {
        switch forTitle {
        case .name:
            return name
        case .location:
            return location
        case .description:
            return description
        }
    }
}

struct SelectedLandmarkView_Previews: PreviewProvider
{
    static var previews: some View {
        SelectedLandmarkView(landmark: LandmarkEntity(name: "Venice Beach Boardwalk"))
    }
}
