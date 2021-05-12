import Foundation
import TdlibKit


protocol AuthServiceDelegate : class {
    func waitPhoneNumber()
    func waitCode(_ code: AuthorizationStateWaitCode)
    func waitPassword(_ code: AuthorizationStateWaitPassword)
    func onReady()
    func onError(_ error: Swift.Error)
}

protocol  UpdateListener : class {
    func onUpdate(_ update: Update)
}

final class AuthService: UpdateListener {
    
    // MARK: - Private properties
    
    private let api: TdApi
    private var authorizationState: AuthorizationState?
    
    
    // MARK: - Public properties
    
    private(set) var isAuthorized: Bool = false
    weak var delegate: AuthServiceDelegate?
    
    
    // MARK: - Init
    
    init(tdApi: TdApi) {
        self.api = tdApi
    }
    
    func onUpdate(_ update: Update) {
        if case .updateAuthorizationState(let state) = update {
            do {
                try onUpdateAuthorizationState(state.authorizationState)
            } catch {
                print(error)
            }
        }
    }
    
    func sendPhone(_ phone: String) {
        let settings = PhoneNumberAuthenticationSettings(
            allowFlashCall: false,
            allowSmsRetrieverApi: false,
            isCurrentPhoneNumber: false)
        try? self.api.setAuthenticationPhoneNumber(
            phoneNumber: phone,
            settings: settings) { [weak self] in
                self?.checkResult($0)
            }
    }
    
    func resendCode(_ phone: String) {
        try? self.api.resendAuthenticationCode() { [weak self] (x) in
            switch (x) {
            case .success:
                break
            case .failure:
                (self?.delegate as? AuthViewDelegate)?
                    .sendAlert("Failed to resend")
            }
        }
    }
    
    func sendCode(_ code: String) {
        try? self.api.checkAuthenticationCode(code: code) { [weak self] in
            self?.checkResult($0)
        }
    }
    
    func sendPassword(_ password: String) {
        try? self.api.checkAuthenticationPassword(password: password) { [weak self] in
            self?.checkResult($0)
        }
    }
    
    public func logout() {
        try? self.api.logOut() { [weak self] in
            self?.checkResult($0)
        }
    }
    
    
    // MARK: - Private methods
    
    private func onUpdateAuthorizationState(_ state: AuthorizationState) throws {
        authorizationState = state
        
        switch state {
        case .authorizationStateWaitTdlibParameters:
            guard let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return
            }
            let tdlibPath = cachesUrl.appendingPathComponent("julius-ceasar-db", isDirectory: true).path
            let params = TdlibParameters(
                apiHash: "5e6d7b36f0e363cf0c07baf2deb26076", // https://core.telegram.org/api/obtaining_api_id
                apiId: 287311,
                applicationVersion: "1.0",
                databaseDirectory: tdlibPath,
                deviceModel: "macOS",
                enableStorageOptimizer: true,
                filesDirectory: "",
                ignoreFileNames: true,
                systemLanguageCode: "en",
                systemVersion: "Unknown",
                useChatInfoDatabase: true,
                useFileDatabase: true,
                useMessageDatabase: true,
                useSecretChats: true,
                useTestDc: false)
            try api.setTdlibParameters(parameters: params) { [weak self] in
                self?.checkResult($0)
            }
            
        case .authorizationStateWaitEncryptionKey(_):
            let keyData = "sdfsdkjfkbsddsj".data(using: .utf8)!
            try api.checkDatabaseEncryptionKey(encryptionKey: keyData) { [weak self] in
                self?.checkResult($0)
            }
            
        case .authorizationStateWaitPhoneNumber:
            delegate?.waitPhoneNumber()
            
        case .authorizationStateWaitCode(let code):
            delegate?.waitCode(code)
            
        case .authorizationStateWaitPassword(let code):
            delegate?.waitPassword(code)
            
        case .authorizationStateReady:
            isAuthorized = true
            delegate?.onReady()
            
        case .authorizationStateLoggingOut:
            isAuthorized = false
            
        case .authorizationStateClosing:
            isAuthorized = false
            
        case .authorizationStateClosed:
            // TODO: close client
            ServiceLayer.reload(sender: (delegate as! AuthViewDelegate).parent)
            
        case .authorizationStateWaitRegistration:
            break
            
        case .authorizationStateWaitOtherDeviceConfirmation(_):
            break
        }
    }
    
    private func checkResult(_ result: Result<Ok, Swift.Error>) {
        switch result {
        case .success:
            // result is already received through UpdateAuthorizationState, nothing to do
            break
        case .failure(let error):
            delegate?.onError(error)
        }
    }
}
