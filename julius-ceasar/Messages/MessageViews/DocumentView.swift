//
//  DocumentView.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 08.05.2021.
//
 
import TdlibKit
import SwiftUI

class DocumentViewData : ObservableObject {
    
    var fileService = ServiceLayer.instance.fileService
    
    // @State var reloadId = UUID()
    
    func onClick() {
        if path != nil{
            NSWorkspace.shared.open(URL(fileURLWithPath: path!))
        }
        else {
            isLoading = true
            fileService.downloadFile(fileId: doc.document.id,
                                     storageId: doc.document.id,
                                     onSuccess: { path in
                                        self.isLoading = false
                                        self.path = path
                                        self.onClick()
                                     })
        }
    }
    
    @Published var isLoading: Bool = false
    @Published var doc: Document
    
    var path: String?
    
    init(_ doc: Document) {
        self.doc = doc
    }
    
}


struct DocumentView: View {
    
    @StateObject var documentViewData: DocumentViewData
    
    init(doc: Document) {
        _documentViewData = StateObject(wrappedValue: DocumentViewData(doc))
    }
    
    var body: some View {
        HStack {
            Button {
                documentViewData.onClick()
            } label: {
                HStack {
                    if documentViewData.isLoading {
                        ProgressView()
                            .frame(height: 20)
                    }
                    else {
                        Image(systemName: "arrow.down.doc.fill")
                            .resizable()
                            .frame(width: 20, height: 27)
                    }
                    
                    Text(documentViewData.doc.fileName)
                        .padding(.leading, 5)
                }
            }
            .frame(height: 40, alignment: .leading)
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
    }
}
