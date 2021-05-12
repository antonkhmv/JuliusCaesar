//
//  WindowsView.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 10.05.2021.
//

import SwiftUI

struct PreviewCell: View {
    @EnvironmentObject var windowsData : WindowsData
    
    var chatListService = ServiceLayer.instance.chatListService
    
    var chatId: Int64
    
    var id: Int
    
    var body: some View {
        HStack {
            Text(chatListService.chats[chatId]!.title)
                .lineLimit(1)
            Button(action: {
                windowsData.removeChat(chatId, id)
            }) {
                Image(systemName: "xmark").foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment:.trailing)
        .padding(2)
    }
}

struct WindowView: View {
    
    @EnvironmentObject var windowsData : WindowsData
    // var chatListService = ServiceLayer.instance.chatListService
    
    var id: Int
    
    //@Binding
    var window: Window
    
    @ViewBuilder func getTable() -> some View {
        let cell = window.chatIds.indices.map {
            PreviewCell(chatId: window.chatIds[$0], id: id)
        }
        
        switch window.chatIds.count {
        case 1: cell[0]
        case 2: HStack(spacing:0) { cell[0]; cell[1] }
        case 3: VStack(spacing:0) {
                    HStack(spacing:0) { cell[0]; cell[1] }
                    HStack(spacing:0) { cell[2] }
                }
        case 4: VStack(spacing:0) {
                    HStack(spacing:0) { cell[0]; cell[1] }
                    HStack(spacing:0) { cell[2]; cell[3] }
                }
        case 5: VStack(spacing:0) {
                    HStack(spacing:0) { cell[0]; cell[1]; cell[2] }
                    HStack(spacing:0) { cell[3].hidden(); cell[3]; cell[4]}
                }
        case 6: VStack(spacing:0) {
                    HStack(spacing:0) { cell[0]; cell[1]; cell[2] }
                    HStack(spacing:0) { cell[3]; cell[4]; cell[5] }
                }
        default:
            Text("Empty")
                .frame(maxWidth: .infinity, alignment:.trailing)
                .padding(2)
        }
    }
        
        
    var body: some View {
        HStack {
            Button(action: {
                windowsData.openWindow(id)
            }) {
                Text("Open window")
                    .foregroundColor(.primary)
            } 
            Text(window.name)
                .padding(.trailing, 10)
            Divider()
            Spacer(minLength: 10)
            self.getTable()
            Spacer(minLength: 10)
        }
        .padding(.leading, 10)
        .frame(maxWidth: .infinity, minHeight: 60)
    }
}
    
