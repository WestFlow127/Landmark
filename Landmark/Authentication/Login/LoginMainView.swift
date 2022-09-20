//
//  LoginMainView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import SwiftUI

struct LoginMainView: View {
    @State var email = ""
    @State var password = ""
    @State private var emptyPasswordAlertIsPresented = false
    @State private var emptyEmailAlertIsPresented = false

    @EnvironmentObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack{
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            VStack{
                TextField("Email Address", text: $email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .alert(isPresented: $emptyEmailAlertIsPresented) {
                        Alert(title: Text("Email cannot be empty."), dismissButton: .default(Text("Ok")))
                    }
                
                
                SecureField("Password", text: $password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .alert(isPresented: $emptyPasswordAlertIsPresented) {
                        Alert(title: Text("Password cannot be empty."), dismissButton: .default(Text("Ok")))
                    }
                
                
                Button {
                    guard !email.isEmpty, !password.isEmpty else {
                        if email.isEmpty {
                            emptyEmailAlertIsPresented = true
                        }
                        if password.isEmpty{
                            emptyPasswordAlertIsPresented = true
                        }
                        return
                    }
                    
                    viewModel.signIn(email: email, password: password)
                } label: {
                    Text("Sign In")
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .cornerRadius(8)
                        .background(Color.blue)
                    
                }
                NavigationLink("Create Account", destination: CreateAccountView())
                    .padding()
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Sign In")
        .background(Color.ui.mainColor)
    }
}

struct CreateAccountView: View {
    @State private var email = ""
    @State private var password = ""
    
    @State private var emptyPasswordAlertIsPresented = false
    @State private var emptyEmailAlertIsPresented = false
    
    @EnvironmentObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack{
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            VStack{
                TextField("Email Address", text: $email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .alert(isPresented: $emptyEmailAlertIsPresented) {
                        Alert(title: Text("Email cannot be empty."), dismissButton: .default(Text("Ok")))
                    }
                
                SecureField("Password", text: $password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .alert(isPresented: $emptyPasswordAlertIsPresented) {
                        Alert(title: Text("Password cannot be empty."), dismissButton: .default(Text("Ok")))
                    }
                
                Button {
                    guard !email.isEmpty, !password.isEmpty else {
                        if email.isEmpty {
                            emptyEmailAlertIsPresented = true
                        }
                        if password.isEmpty{
                            emptyPasswordAlertIsPresented = true
                        }
                        return
                    }
                    
                    viewModel.signUp(email: email, password: password)
                } label: {
                    Text("Create Account")
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .cornerRadius(8)
                        .background(Color.blue)
                    
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Create Account")
        .background(Color.ui.mainColor)
    }
}

struct LoginMainView_Previews: PreviewProvider {
    static var previews: some View {
        LoginMainView()
    }
}
