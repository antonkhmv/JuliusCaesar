//
//  AuthViewController.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 27.04.2021.
//

import SwiftUI
import TdlibKit

class AuthViewDelegate : ObservableObject {
    
    func setAuthService(_ authService : AuthService) {
        self.authService = authService
    }
    
    @State var authService : AuthService = ServiceLayer.instance.authService
    
    @Published var currState : AuthState = .phone
    
    @Published var phoneNumber : String = ""
    
    @Published var password : String = ""
    
    @Published var code : String = ""
    
    @Published var showErrorMessage : Bool = false
    
    @State var errorMessageText : String = ""
    
    var stateBeforeLoading : AuthState = .phone
    
    var parent : AppDelegate!
    
    init(parent: AppDelegate) {
        self.parent = parent
        authService.delegate = self
        setState(state: .loading)
    }
    
    func setState(state: AuthState) {
        currState = state
        
        if state != .loading {
            stateBeforeLoading = state
        }
    }
}

extension AuthViewDelegate : AuthServiceDelegate {
    
    func waitPhoneNumber() {
        setState(state: .phone)
    }
    
    func waitCode(_ code : AuthorizationStateWaitCode) {
        setState(state: .code)
        self.phoneNumber = code.codeInfo.phoneNumber
    }
    
    func waitPassword(_ code : AuthorizationStateWaitPassword) {
        setState(state: .password)
    }
    
    func onReady() {
        parent.setMain() 
    }
    
    func onError(_ error:Swift.Error) {
        switch(stateBeforeLoading) {
        case .code:     sendAlert("Incorrect Code")
        case .password: sendAlert("Incorrect Password")
        case .phone:    sendAlert("Invalid Phone Number")
        default: sendAlert(error.localizedDescription)
        }
    }
    
    func sendAlert(_ text : String) {
        self.showErrorMessage.toggle()
        self.errorMessageText = text
        setState(state: .loading)
    }
}

