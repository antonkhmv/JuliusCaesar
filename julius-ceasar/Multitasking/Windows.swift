//
//  Windows.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 09.05.2021.
//

import SwiftUI

struct Windows: View {
    @EnvironmentObject var windowsData : WindowsData
    @State private var name: String = ""
    @State private var newName: String = ""
    
    var body: some View {
        VStack (spacing: 0) {
        HStack {
            Button(action: {
                if !windowsData.namePresent(name) {
                    windowsData.createEmptyWindow(name)
                }
            }) {
                Text("Create new window")
                Image(systemName:"plus")
            }
            TextField("Name", text: $name)
        }
        .padding()
        .frame(height: 50)
        
        Divider()
        
        ScrollView {

        VStack(spacing: 0) {
            ForEach (windowsData.windows.indices, id: \.self) { id in
                VStack (spacing: 0) {
                    WindowView(id: id, window: windowsData.windows[id])
                        //.environmentObject(windowsData)
                        
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                            windowsData.selectedWindow != nil
                                        && windowsData.selectedWindow! == id ?
                                        Color.Blue : Color.primary.opacity(0.3)
                        ))
                        
                        .padding(.horizontal, 15)
                        .padding(.top, 15)
                    
                        .foregroundColor(windowsData.selectedWindow != nil
                                            && windowsData.selectedWindow! == id ?
                                            .white : .primary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if windowsData.selectedWindow != id {
                        windowsData.selectedWindow = id
                    }
                }
            }
        }//Vstack
            
        }//Scroll View
         
        Divider()
            
        HStack {
            Button(action: {
                windowsData.deleteSelectedWindow()
            }) {
                Image(systemName:"xmark")
                Text("Delete window")
            }
            
            Button(action: {
                if !newName.isEmpty && !windowsData.namePresent(newName) {
                    windowsData.editSelectedName(newName: newName)
                }
            }) {
                Text("Rename window")
            }
            
            TextField("New name", text: $newName)
        }
        .disabled(windowsData.selectedWindow == nil)
        .padding()
        .frame(height: 50)
            
        }//Vstack
    }
}
