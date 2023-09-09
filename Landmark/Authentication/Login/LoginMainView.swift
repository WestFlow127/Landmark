//
//  LoginMainView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import SwiftUI

struct LoginMainView: View
{
    @EnvironmentObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    @State var isCreatingAccount = false
    @State var doesRemember: Bool = false
    
    @State private var emptyPasswordAlertIsPresented = false
    @State private var emptyEmailAlertIsPresented = false
    
    var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    var rememberedEmail: String? {
        viewModel.authManager.rememberedEmail
    }
    
    var currentModeTitle: String {
        !isCreatingAccount ? "Sign In" : "Create Acoount"
    }
    
    var body: some View
    {
        NavigationStack
        {
            if viewModel.signedIn
            {
                LandmarkMainView()
                    .onAppear {
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
                    
                    credentialInputView
                    
                    signInButton
                    
                    toggleAuthMode
                    
                    Spacer()
                }
                .navigationTitle(currentModeTitle)
                .background(Color.ui.mainColor)
            }
        }
    }
    
    var credentialInputView: some View
    {
        // Credentials Input View
        VStack(alignment: .leading)
        {
            Group {
                TextField("Email Address", text: $email)
                    .task {
                       email = rememberedEmail ?? ""
                    }
                    .alert(isPresented: $emptyEmailAlertIsPresented)
                    {
                        Alert(
                            title: Text("Email cannot be empty."),
                            dismissButton: .default(Text("Ok"))
                        )
                    }
                
                SecureField("Password", text: $password)
                    .alert(isPresented: $emptyPasswordAlertIsPresented)
                    {
                        Alert(
                            title: Text("Password cannot be empty."),
                            dismissButton: .default(Text("Ok"))
                        )
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
    }
    
    var signInButton: some View
    {
        // Sign In Button
        Button(action: signIn)
        {
            Text(currentModeTitle)
                .foregroundColor(Color.white)
                .frame(width: 200, height: 50)
                .cornerRadius(8)
                .background(Color.blue)
            
        }
        .cornerRadius(8)
        .padding(10)
        .alert(isPresented: $viewModel.hasLoginError)
        {
            let error = viewModel.loginError!
            
            debugPrint("Login Error: \(String(describing: error))")
            
            let errorMessage = error.localizedDescription
            
            return Alert(
                title: Text(errorMessage),
                dismissButton: .default(
                    Text("Ok"),
                    action: { viewModel.loginError = nil })
            )
        }
    }
    
    // Toggle account login/creation mode
    var toggleAuthMode: some View
    {
        Button {
            isCreatingAccount = !isCreatingAccount
        } label: {
            Text(isCreatingAccount ? "Sign In" : "Create Acoount")
        }
        .padding(5)
    }
}

// MARK: Functions
extension LoginMainView
{
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
            
            viewModel.rememberEmail(email: doesRemember ? email : nil)
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
