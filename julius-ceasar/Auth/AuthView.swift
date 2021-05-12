//
//  AuthView.swift
//  Julius Ceasar
//
//  Created by Anton Khomyakov on 23.04.2021.
//

import SwiftUI

enum AuthState {
    case phone
    case code
    case password
    case loading
}

struct AuthViewWrapper: View {
    let parent: AppDelegate
    let authData: AuthViewDelegate
    
    init(parent: AppDelegate) {
        self.parent = parent
        self.authData = AuthViewDelegate(parent: parent)
    }
    
    var body: some View {
        AuthView()
            .environmentObject(authData)
    }
}

struct AuthView : View {
    
    @EnvironmentObject var authDelegate : AuthViewDelegate
    
    // let authDelegate= AuthViewauthDelegate(self)
    
    var body : some View {
        VStack {
            Spacer()
            if (authDelegate.currState != .loading) {
                VStack (spacing: 0) {
                    Text("Log in with your phone number")
                        .font(.title2)
                        .padding(.bottom)
                        .multilineTextAlignment(.leading)

                    PhoneView()
                        //.environmentObject(authDelegate)
                    
                    if (authDelegate.currState != .phone) {
                        CodeView()
                            //.environmentObject(authDelegate)
                            .animation(.easeIn(duration: 0.1))
                    }
                    
                    if (authDelegate.currState == .password) {
                        PasswordView()
                            //.environmentObject(authDelegate)
                            .animation(.easeIn(duration: 0.1))
                    }
                }
                .frame(alignment: .center)
            }
            else {
                ProgressView()
                    .frame(alignment: .center)
                    .alert(isPresented: $authDelegate.showErrorMessage) {
                        Alert(title: Text("Error"),
                              message: Text(authDelegate.errorMessageText),
                              dismissButton: .default(Text("OK")) {
                                authDelegate.showErrorMessage = false
                                authDelegate.setState(state: authDelegate.stateBeforeLoading)
                        })
                    }
            }
            Spacer()
        }
        .frame(minWidth: 400, idealWidth: 600, maxWidth: .infinity,
               minHeight: 200, idealHeight: 300, maxHeight: .infinity,
               alignment: .center) 
    }
}

