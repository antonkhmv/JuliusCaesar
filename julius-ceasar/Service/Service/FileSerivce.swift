//
//  FileSerivce.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 04.05.2021.
//

import Foundation
import TdlibKit
import SwiftUI

final class FileService : ObservableObject, UpdateListener {

    private let api: TdApi
    
    func resetStorage() {
        self.users = [:]
        self.files = [:]
        self.chatPhotos = [:]
    }
    
    var users: [Int : UserInfo] = UserDefaults.users
    {
        didSet {
            UserDefaults.users = self.users
        }
    }
    
    
    @Published var files: [Int: String?] = UserDefaults.pictures
    {
        didSet {
            UserDefaults.pictures = self.files
            objectWillChange.send()
        }
    }
    
    @Published var chatPhotos: [Int64: String?] = UserDefaults.chatPhotos
    {
        didSet {
            UserDefaults.chatPhotos = self.chatPhotos
            objectWillChange.send()
        }
    }
    
    init(tdApi: TdApi) {
        
        self.api = tdApi
    }
    
    func downloadProfilePicture(_ info: UserInfo,
                       completion: @escaping (String?) -> (), tryAgain:Bool=true){
        
        if let picId = info.profilePhoto?.id {
            let userId = info.id
            if userId == 0 {
                return
            }
            self.downloadFile(fileId: picId,
                               storageId: userId,
                               onSuccess: completion,
                               onFailure: {
                if tryAgain {
                    self.getUser(userId) { user in
                        self.downloadProfilePicture(user,
                                                    completion: completion,
                                                    tryAgain: false)
                    }
                }
            })
        }
        
        
    }
    
    func downloadChatPhoto(_ info: ChatInfo,
                           completion: @escaping (String?) -> ()){
        guard let picId = info.chatPhoto else {return}
        try? api.downloadFile(fileId: picId,
                         limit: 0,
                         offset: 0,
                         priority: 32,
                         synchronous: true,
                 completion: {
                    [weak self] result in
                        guard let self = self else {return}
                        
                    switch (result) {
                        case .success(let file):
                            self.chatPhotos[info.id] = file.local.path
                            completion(file.local.path)
                            break
                        case .failure(_):
                            break
                    }
                 })
    }
    
    func downloadFile(fileId: Int, storageId: Int,
                                onSuccess: @escaping (String?) -> () = { _ in },
                                onFailure: @escaping () -> () = { }) {
        // guard let picId = info.profilePhoto?.id else {return}
        try? api.downloadFile(fileId: fileId,
                         limit: 0,
                         offset: 0,
                         priority: 32,
                         synchronous: true,
                 completion: {
                    [weak self] result in
                        guard let self = self else {return}
                        
                    switch (result) {
                        case .success(let file):
                            self.files[storageId] = file.local.path
                            onSuccess(file.local.path)
                            break
                        case .failure(_):
                            onFailure()
                            break
                    }
                 })
    }
    
    
    func getUser(_ userId: Int, completion: @escaping (UserInfo) -> ()) {
        // var user : UserInfo?
        
        try? api.getUser(userId: userId, completion: {
            [weak self] result in
                guard let self = self
                else { return }
            
                switch (result) {
                    case .success(let res):
                        let user = UserInfo(res)
                        self.users[userId] = user
                        completion(user)
                    case .failure(_):
                        break
                }
        })
        
    }
    
    func onUpdate(_ update: Update) {
        switch(update) {
        case .updateUser(let update) :
            // User
            let info = UserInfo(update.user)
            let infoOld = self.users[update.user.id]
            self.users[update.user.id] = info
            
            if let photo = info.profilePhoto, infoOld != nil,
               let oldPhoto = infoOld!.profilePhoto, photo.id != oldPhoto.id {
                self.downloadProfilePicture(info, completion: { _ in })
            }
        default:
            break
        }
    }
}
