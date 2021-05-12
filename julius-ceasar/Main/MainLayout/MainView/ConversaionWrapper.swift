import SwiftUI

struct ConversationWrapper : View {
    var chatListService = ServiceLayer.instance.chatListService
    
    @Binding var selectedChat : Int64?
    
    @State private var selectedService: ConversationService?
    
    var body: some View {
        ZStack {
            if (selectedChat != nil) {
                Conversation(chatId: chatListService.chats[selectedChat!]!.id)
            }
            else {
                Text("Select a chat to start messaging.")
                    .frame(maxWidth:.infinity, maxHeight:.infinity, alignment: .center)
            }
        }
        .onChange(of: selectedChat, perform: {
            selectedService?.closeChat()
            selectedService = ConversationData.getConversationService(chatId: $0!)
            selectedService?.openChat()
        })
    }
}
