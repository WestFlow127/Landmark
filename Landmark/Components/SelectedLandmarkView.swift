//
//  SelectedLandmarkView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/21/22.
//

import SwiftUI

enum DisplayTitles: String
{
    case name = "Landmark"
    case location = "Address"
    case description = "Description"
    
    var string: String {
        rawValue
    }
}

struct SelectedLandmarkView: View
{
    @Environment(\.dismiss) var dismiss
    var subTitles: [DisplayTitles] = [.location, .description]
    
    @StateObject private var viewModel: SelectedLandmarkViewModel
    
    @State private var name: String
    @State private var location: String
    @State private var description: String

    var body: some View
    {
        ScrollView
        {
            VStack(alignment: .leading)
            {
                TabView
                {
                    ForEach(viewModel.landmarkImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width)
//                            .offset(CGSize(width: -5, height: -5))
                    }
                }
                .frame(height: UIScreen.main.bounds.height / 3)
                
                HStack
                {
                    Text(DisplayTitles.name.string + ": ")
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
                
                ForEach(subTitles, id: \.self)
                { title in
                    Divider()
                    
                    HStack
                    {
                        Group {
                            Text(title.rawValue + ": ")
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary, lineWidth: 2)
                                }
                            
                            Text(getDisplayValue(forTitle: title))
                        }
                        .font(Font.landmarkFontBold(21))
                        .padding(5)
                        .offset(x: 2.5, y: 2.5)
                    }
                }.padding(5)
            }
        }.ignoresSafeArea()
    }
    
    init(viewModel: SelectedLandmarkViewModel)
    {
        _viewModel = StateObject(wrappedValue: viewModel)

        _name = State(initialValue: viewModel.landmark.name)
        _location = State(initialValue: viewModel.landmark.location ?? "")
        _description = State(initialValue: viewModel.landmark.description ?? "")
    }
    
    func getDisplayValue(forTitle: DisplayTitles) -> String
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
        SelectedLandmarkView(viewModel: SelectedLandmarkViewModel(landmark: LandmarkEntity(name: "Venice Beach Boardwalk")))
    }
}
