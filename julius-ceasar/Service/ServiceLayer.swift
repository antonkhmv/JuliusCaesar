import Foundation
import TdlibKit

final class ServiceLayer {
    
    static var instance = ServiceLayer()
    
    let telegramService: TelegramService
    let authService: AuthService
    let chatListService: ChatListService
    let fileService: FileService
    
    private init() {
        let logger = StdOutLogger()
        telegramService = TelegramService(logger: logger)
        
        authService = AuthService(tdApi: telegramService.api)
        telegramService.add(listener: authService)
        
        chatListService = ChatListService(tdApi: telegramService.api)
        telegramService.add(listener: chatListService)
        
        fileService = FileService(tdApi: telegramService.api)
        telegramService.add(listener: fileService)
    }
    
    static func reload(sender: AppDelegate) {
        try? instance.telegramService.api.close { _ in }
        instance = ServiceLayer()
        sender.reloadAuth()
    }
}
