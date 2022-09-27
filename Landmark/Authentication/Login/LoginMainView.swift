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
    @State var isCreatingAccount = false
   
    @State private var emptyPasswordAlertIsPresented = false
    @State private var emptyEmailAlertIsPresented = false

    @EnvironmentObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    var body: some View {
        NavigationView {
            if viewModel.signedIn {
                LandmarkMainView()
                    .onAppear{
                        email = ""
                        password = ""
                    }
            } else {
                VStack{
                    Image(isDarkMode ? "castle_dark" : "castle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    VStack{
                        TextField("Email Address", text: $email)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .alert(isPresented: $emptyEmailAlertIsPresented) {
                                Alert(title: Text("Email cannot be empty."), dismissButton: .default(Text("Ok")))
                            }
                        
                        SecureField("Password", text: $password)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
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
                            
                            if !isCreatingAccount {
                                viewModel.signIn(email: email, password: password)
                            } else {
                                viewModel.signUp(email: email, password: password)
                            }
                        } label: {
                            Text(isCreatingAccount ? "Create Account" : "Sign In")
                                .foregroundColor(Color.white)
                                .frame(width: 200, height: 50)
                                .cornerRadius(8)
                                .background(Color.blue)
                            
                        }
                        .cornerRadius(8)
                        .padding(10)
                        .alert(isPresented: $viewModel.hasLoginError) {
                            debugPrint("Login Error: \(viewModel.loginError!)")

                            return Alert(title: Text("Failed to login or create account.\n Check Internet connection."), dismissButton: .default(Text("Ok")))
                        }
                        
                        Button {
                            isCreatingAccount = !isCreatingAccount
                        } label: {
                            Text(isCreatingAccount ? "Sign In" : "Create Acoount")
                        }
                        .padding(5)
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle(!isCreatingAccount ? "Sign In" : "Create Acount")
                .background(Color.ui.mainColor)
            }
        }
    }
}

struct LoginMainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LoginViewModel()
        
        Group{
            LoginMainView()
                .preferredColorScheme(.light)
                .environmentObject(viewModel)
            
            LoginMainView()
                .preferredColorScheme(.dark)
                .environmentObject(viewModel)
        }
    }
}
