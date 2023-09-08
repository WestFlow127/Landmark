//
//  LoginMainView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import SwiftUI

struct LoginMainView: View
{
    @State var email = ""
    @State var password = ""
    @State var isCreatingAccount = false
    @State var doesRemember: Bool = false
    
    @State private var emptyPasswordAlertIsPresented = false
    @State private var emptyEmailAlertIsPresented = false

    @EnvironmentObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    var rememberedEmail: String? {
        viewModel.authManager.rememberedEmail
    }
    
    var body: some View
    {
        NavigationStack
        {
            if viewModel.signedIn
            {
                LandmarkMainView()
                    .onAppear{
                        email = ""
                        password = ""
                    }
            } else {
                VStack
                {
                    Image(isDarkMode ? "castle_dark" : "castle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    VStack(alignment: .leading)
                    {
                        Group {
                            TextField("Email Address", text: $email)
                                .task {
                                   email = rememberedEmail ?? ""
                                }
                                .alert(isPresented: $emptyEmailAlertIsPresented) {
                                    Alert(title: Text("Email cannot be empty."), dismissButton: .default(Text("Ok")))
                                }
                            
                            SecureField("Password", text: $password)
                                .alert(isPresented: $emptyPasswordAlertIsPresented)
                                {
                                    Alert(title: Text("Password cannot be empty."), dismissButton: .default(Text("Ok")))
                                }
                        }
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        
                        Group {
                            Toggle(isOn: $doesRemember) {
                                Text("Remember me?")
                            }
                            .padding([.leading, .top], 5)
                            .toggleStyle(.checkmark)
                        }
                        .foregroundColor(Color.secondary)
                        .shadow(radius: 0.25)
                    }
                    .padding()
                    
                    Button(action: signIn)
                    {
                        Text(isCreatingAccount ? "Create Account" : "Sign In")
                            .foregroundColor(Color.white)
                            .frame(width: 200, height: 50)
                            .cornerRadius(8)
                            .background(Color.blue)
                        
                    }
                    .cornerRadius(8)
                    .padding(10)
                    .alert(isPresented: $viewModel.hasLoginError) {
                        let error = viewModel.loginError!
                        
                        debugPrint("Login Error: \(String(describing: viewModel.loginError))")
                        
                        var errorMessage = viewModel.loginError?.localizedDescription
                        
                        return Alert(
                            title: Text(errorMessage ?? "Failed Login"),
                            dismissButton: .default(
                                Text("Ok"),
                                action: { viewModel.loginError = nil })
                        )
                    }
                    
                    Button {
                        isCreatingAccount = !isCreatingAccount
                    } label: {
                        Text(isCreatingAccount ? "Sign In" : "Create Acoount")
                    }
                    .padding(5)
                    
                    Spacer()
                }
                .navigationTitle(!isCreatingAccount ? "Sign In" : "Create Acount")
                .background(Color.ui.mainColor)
            }
        }
    }
    
    func signIn()
    {
        guard !email.isEmpty, !password.isEmpty else
        {
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
            
            if doesRemember {
                viewModel.rememberEmail(email: email)
            }
        } else {
            viewModel.signUp(email: email, password: password)
        }
    }
}

struct LoginMainView_Previews: PreviewProvider
{
    static var previews: some View
    {
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
