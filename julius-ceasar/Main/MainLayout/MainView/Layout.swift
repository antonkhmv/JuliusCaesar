//
//  ContentView.swift
//  test2
//
//  Created by Anton Khomyakov on 27.04.2021.
//

import SwiftUI

struct FittedImage: View
{
    @Binding var selectedTab : MainView.Tab
    
    private let width: CGFloat = 24
    private let height: CGFloat = 24
    let systemName: String
    let tag : MainView.Tab

    var body: some View {
        HStack {
            Spacer()
            Image(systemName: systemName)
                .resizable().scaledToFit()
                .frame(width: width, height: height)
                .foregroundColor(selectedTab != tag ? .primary : .Blue)
            Spacer()
        }
        .padding(.vertical, 13)
        .background(Color.primary.opacity(0.01))
        .gesture(
            TapGesture().onEnded({
                selectedTab = tag
            })
        )
    }
}

struct Footer : View {
    
    
    @Binding var selectedTab : MainView.Tab
    
    init(selectedTab: Binding<MainView.Tab>) {
        _selectedTab = selectedTab
    }
    
    var body : some View {
        HStack {
            FittedImage(selectedTab: $selectedTab, systemName:"gear", tag: .settings)
            FittedImage(selectedTab: $selectedTab, systemName:"message.fill", tag: .chats)
            FittedImage(selectedTab: $selectedTab, systemName:"table.badge.more", tag: .windows)
        }
        //.pickerStyle(PopUpButtonPickerStyle())
    }
}
