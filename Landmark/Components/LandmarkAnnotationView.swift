//
//  LandmarkAnnotationView.swift
//  Landmark
//
//  Created by Weston Mitchell on 10/18/22.
//

import SwiftUI

struct LandmarkAnnotationView: View {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    var body: some View {
        VStack(spacing: 0){
            Image(systemName: "map.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
                .padding(3)
                .background(.red)
                .cornerRadius(31)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.red)
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
            
            Text(name)
                .font(Font.caption)
                .lineLimit(2)
                .padding(.bottom, 40)
        }
    }
}

struct LandmarkAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkAnnotationView(name: "Venice Beach")
    }
}
