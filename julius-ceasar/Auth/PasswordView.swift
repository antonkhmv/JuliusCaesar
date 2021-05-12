//
//  PasswordView.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 27.04.2021.
//

import SwiftUI

struct PasswordView : View {
    
    @EnvironmentObject var authDelegate : AuthViewDelegate
    @State var isDisabled = false
    @State var textField : NSTextField?
    
    var body: some View {
        VStack {
            HStack {
                TextField("Password", text: $authDelegate.password, onCommit: {
                    authDelegate.authService.sendPassword(authDelegate.password)
                    authDelegate.setState(state: .loading)
                })
                .introspectTextField { textField in
                    if self.textField == nil {
                        self.textField = textField
                        textField.becomeFirstResponder()
                    }
                }
                
                Button(action: {textField?.becomeFirstResponder()}) {
                    Text("Log in").frame(width: 70, alignment: .center)
                }
                
            }
            .frame(width: 300, height: 35)
        }
    }
}
