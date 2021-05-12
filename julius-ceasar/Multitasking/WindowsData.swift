//
//  WindowsData.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 10.05.2021.
//

import SwiftUI

struct Window {
    var chatIds: [Int64]
    let uuid = UUID()
    var name: String
}

class WindowsData : ObservableObject {
    @Published var selectedWindow: Int? = nil
    @Published var windows: [Window] = []
    var count: Int = 1
    
    func removeChat(_ chatId: Int64, _ id: Int) {
        windows[id].chatIds.removeAll(where: { $0 == chatId } )
    }
    
    func namePresent(_ name: String) -> Bool {
        return windows.first(where: { $0.name == name }) != nil
    }
    
    func deleteSelectedWindow() {
        if let id = selectedWindow {
            windows.remove(at: id)
            selectedWindow = id > 0 ? id-1 : nil
            self.count -= 1
        }
    }
    
    func editSelectedName(newName: String) {
        if let id = selectedWindow {
            windows[id].name = newName
        }
    }
    
    func createEmptyWindow(_ name: String) {
        var name = name
        
        if name.isEmpty {
            name = "Window \(self.count)"
        }
        windows.insert(Window(chatIds: [], name: name), at: 0)
        selectedWindow = 0
        self.count += 1
    }
    
    func openWindow(_ id: Int) {
        
        parent.openMultiWindow(rootView: MultiWindow(id: id,
                                    window: Binding(
                                        get: { id < self.windows.count ?
                                            self.windows[id] :
                                            Window(chatIds: [], name: "") },
                                        set: { [self] in self.windows[id] = $0
                                    }),
                                    parent: parent
                            )
                            .environmentObject(self)
                            .environmentObject(ChatListData(parent: parent)),
                    title: windows[id].name)
    }
    
    func addChat(chatId: Int64) {
        if let id = selectedWindow {
            guard !windows[id].chatIds.contains(chatId) else {return}
            windows[id].chatIds.append(chatId)
        }
    }
    
    func addChat(id: Int, chatId: Int64) {
        windows[id].chatIds.append(chatId)
    }
    
    func createNewWindow(chatId: Int64) {
        windows.insert(Window(chatIds: [chatId], name: "Window \(self.count)"), at: 0)
        selectedWindow = 0
        self.count += 1
    }
    
    init(parent: AppDelegate) {
        self.parent = parent
    }
    var parent: AppDelegate
}
