//
//  Settings.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 08.05.2021.
//

import SwiftUI

struct Settings: View {
    
    var parent: AppDelegate
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Button(action: {
                ServiceLayer.instance.authService.logout()
                parent.setAuth()
            }) {
                HStack {
                    Text("Log out")
                        .font(.system(size: 14))
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(5)
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                RoundedRectangle(cornerRadius: 6.0)
                    .fill(Color.primary.opacity(0.5)))
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
 
