
//
//  MainViewParams.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 27.04.2021.
//

import SwiftUI

class ChatListData : ObservableObject {
    
    @Published var selectedChat : Int64?
    
    init(parent: AppDelegate) {
        self.parent = parent
    }
    
    var parent : AppDelegate
}
