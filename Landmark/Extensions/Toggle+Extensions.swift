//
//  Toggle+Extensions.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/7/23.
//

import Foundation
import SwiftUI

struct CheckboxToggleStyle: ToggleStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        HStack {
 
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 3)
                .frame(width: 20, height: 20)
                .cornerRadius(5.0)
                .overlay {
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
 
            configuration.label
 
        }
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle
{
    static var checkmark: CheckboxToggleStyle { CheckboxToggleStyle() }
}
