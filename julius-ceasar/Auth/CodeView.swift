//
//  CodeView.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 27.04.2021.
//

import SwiftUI

struct CodeView : View {
    
    @EnvironmentObject var authDelegate : AuthViewDelegate
    // @Binding var isDisabled : Bool
    @State var textField : NSTextField?
    
    var body: some View {
        VStack {
            HStack {
                TextField("Code", text: $authDelegate.code, onCommit: {
                    // Send code button
                    authDelegate.authService.sendCode(authDelegate.code)
                    authDelegate.setState(state: .loading)
                })
                .disabled(authDelegate.currState != .code)
                .introspectTextField { textField in
                    if self.textField == nil {
                        self.textField = textField
                        textField.becomeFirstResponder()
                    }
                }
                
                    Button(action: {textField?.becomeFirstResponder()}) {
                        Text("Log in").frame(width: 70, alignment: .center)
                    }
                    .isHidden(authDelegate.currState != .code)
            }
            .frame(width: 300, height: 35)
            
            if (authDelegate.currState == .code) {
                Button(action: {
                    authDelegate.authService.resendCode(authDelegate.phoneNumber)
                }) {
                    Text("Resend code").frame(width: 120, alignment: .center)
                }
            }
        }
    }
}

