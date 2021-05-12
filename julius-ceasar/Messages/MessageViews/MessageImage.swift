//
//  MessageImage.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 07.05.2021.
//

import TdlibKit
import SwiftUI


class MessageImageData : ObservableObject {
    
    var fileService = ServiceLayer.instance.fileService
    
    // @State var reloadId = UUID()
    
    func reload(path: String?) {
        image = NSImage(byReferencingFile: path!)
        // reloadId = UUID()
    }
    
    @Published var image: NSImage?
    
    init(photo: Photo) {
        
        //choose the best size
        //var minDist = Double.infinity
        var bestSize : PhotoSize?
        
        bestSize = photo.sizes.max(by: {
            a, b in a.height < b.height
        })
        
        if let size = bestSize {
            let path = fileService.files[size.photo.id]
            
            if path != nil {
                image = NSImage(byReferencingFile: path!!)
            }
            
            //if image == nil || !image!.isValid {
                fileService.downloadFile(fileId: size.photo.id,
                                          storageId: size.photo.id,
                                          onSuccess: reload)
            //}
        }
    }
    
}


struct MessageImage: View {
    
    @StateObject var messageImageData: MessageImageData
   
    @State private var isPresented = false
    
    init(photo: Photo) {
        _messageImageData = StateObject(wrappedValue: MessageImageData(photo: photo))
    }
    
    var body: some View {
        HStack{
            if messageImageData.image != nil {
                Image(nsImage: messageImageData.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 320, maxHeight: 320, alignment: .leading)
                    .onTapGesture {
                        isPresented.toggle()
                    }
                .sheet(isPresented: $isPresented) {
                    VStack {
                        Button(action: { isPresented.toggle() }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Close").font(.title2)
                            }
                        }
                        .foregroundColor(.Blue)
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        
                        Image(nsImage: messageImageData.image!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            //.ignoresSafeArea(.all)
                            //.frame(maxWidth: 320, maxHeight: 320, alignment: .leading)
                            .onTapGesture {
                                isPresented.toggle()
                            }
                    }
                    .padding(20)
                    .padding(.bottom, 30)
                    .visualEffect(material: .hudWindow, blendingMode: .behindWindow, emphasized: false)
                    .frame(width: NSScreen.main!.frame.width * 0.7,
                           height: NSScreen.main!.frame.height * 0.7)
                }
            }
            else {
                ZStack {
                    ProgressView()
                }
                .background(Color.black)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 320, maxHeight: 320, alignment: .leading)
                //.padding(.trailing, 50)
            }
            Spacer()
        }
        
    }
}
