//
//  PhoneView.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 27.04.2021.
//

import SwiftUI
import Introspect

struct PhoneView : View {
    @EnvironmentObject var authDelegate : AuthViewDelegate
    //@State private var isDisabled : Bool
    @State var textField : NSTextField?
    
    var body: some View {
        VStack {
            
            HStack{
                
                TextField("Phone", text: $authDelegate.phoneNumber, onCommit: {
                    authDelegate.authService.sendPhone(authDelegate.phoneNumber)
                    authDelegate.setState(state: .loading)
                })
                    .disabled(authDelegate.currState != .phone)
                    .introspectTextField { textField in
                        if self.textField == nil {
                            self.textField = textField
                            textField.becomeFirstResponder()
                        }
                    }
                
                if authDelegate.currState != .phone {
                    // Edit phone number button
                    Button(action: {
                        authDelegate.setState(state: .phone)
                        authDelegate.code = ""
                    }) {
                        Text("Edit").frame(width: 70, alignment: .center)
                    }
                }
                else {
                    // Send phone button
                    Button(action: {textField?.becomeFirstResponder()}) {
                        Text("Send").frame(width: 70, alignment: .center)
                    }
                }
                
            }
            .frame(width: 300, height: 35, alignment: .center)
            
        }
    }
}
