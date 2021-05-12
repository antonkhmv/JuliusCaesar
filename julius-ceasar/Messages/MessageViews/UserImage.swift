//
//  FileImage.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 05.05.2021.
//

import SwiftUI
import Foundation


class UserImageData : ObservableObject {
    
    var fileService = ServiceLayer.instance.fileService
    @Published var image: NSImage?
    
    init(chatId : Int64?, userId: Int?) {
        
        if let userId = userId {
            if let path = fileService.files[userId] {
                self.image = NSImage(byReferencingFile: path!)
                
                if image == nil || !image!.isValid,
                let user = fileService.users[userId] {
                    fileService.downloadProfilePicture(user, completion: { path in
                        //[weak self] path in
                        //if let self = self {
                            self.image = NSImage(byReferencingFile: path!)
                        //}
                    })
                }
            }
        }
        else if let chatId = chatId {
            if let path = fileService.chatPhotos[chatId] {
                image = NSImage(byReferencingFile: path!)
                
                if image == nil || !image!.isValid,
                let chat = ServiceLayer.instance.chatListService.chats[chatId] {
                    fileService.downloadChatPhoto(chat, completion: { path in
                        //[weak self] path in
                        //if let self = self {
                            self.image = NSImage(byReferencingFile: path!)
                        //}
                    })
                }
            }
        }
        
    }
    
}

struct UserImage: View {
    var name: String?
    var size: NSSize
    @StateObject private var userImageData: UserImageData
    
    init(fileService: FileService,
         chatId: Int64?,
         userId: Int?,
         name: String?,
         size: NSSize) {
        
        self.name = name
        self.size = size
        
        self._userImageData = StateObject(wrappedValue:
                        UserImageData(chatId: chatId, userId: userId))
    }
    
    var body: some View {
        ZStack{
            if userImageData.image != nil && userImageData.image!.isValid {
                Image(nsImage: userImageData.image!)
                    .resizable()
                    .scaledToFit()
                    //.aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .blur(radius: 0.5)
                    .clipShape(Circle())
                    //.offset(y: 6)
            }
            else {
                VStack {
                    Text(name != nil && name!.count>0 ?
                            String(name!.first!) : "")
                        .font(.title)
                }
                .frame(width: size.width, height: size.height)
                .background(Color.primary.opacity(0.5))
                .clipShape(Circle())
                //.offset(y: 6)
            }
        }
    }
}
