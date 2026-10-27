//
//  LoginMainView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import SwiftUI

struct LoginMainView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencies) var dependencies

    @State private var email = ""
    @State private var password = ""
    @State var isCreatingAccount = false
    @State var doesRemember: Bool = false

    @State private var emptyPasswordAlertIsPresented = false
    @State private var emptyEmailAlertIsPresented = false

    var isDarkMode: Bool {
        self.colorScheme == .dark
    }

    var rememberedEmail: String? {
        self.viewModel.authManager.rememberedEmail
    }

    var currentModeTitle: String {
        !self.isCreatingAccount ? "Sign In" : "Create Acoount"
    }

    var body: some View {
        NavigationStack {
            if self.viewModel.signedIn {
                LandmarkMainView(dependencies: self.dependencies)
                    .onAppear {
                        self.email = ""
                        self.password = ""
                    }
            } else {
                VStack {
                    Image(self.isDarkMode ? "castle_dark" : "castle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    self.credentialInputView

                    self.signInButton

                    self.toggleAuthMode

                    Spacer()
                }
                .navigationTitle(self.currentModeTitle)
                .background(Color.mainColor)
            }
        }
        .onAppear {
            self.viewModel.signedIn = self.viewModel.isSignedIn
        }
    }

    var credentialInputView: some View {
        VStack(alignment: .leading) {
            Group {
                TextField("Email Address", text: self.$email)
                    .task {
                        self.email = self.rememberedEmail ?? ""
                    }
                    .alert(isPresented: self.$emptyEmailAlertIsPresented) {
                        Alert(
                            title: Text("Email cannot be empty."),
                            dismissButton: .default(Text("Ok"))
                        )
                    }

                SecureField("Password", text: self.$password)
                    .alert(isPresented: self.$emptyPasswordAlertIsPresented) {
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
                Toggle(isOn: self.$doesRemember) {
                    Text("Remember me?")
                }
                .padding([.leading, .top], 5)
                .toggleStyle(.checkmark)
                .foregroundStyle(Color.black)
            }
            .foregroundColor(Color.secondary)
            .shadow(radius: 0.25)
        }
        .padding()
    }

    var signInButton: some View {
        Button(action: signIn) {
            Text(self.currentModeTitle)
                .foregroundColor(Color.white)
                .frame(width: 200, height: 50)
                .cornerRadius(8)
                .background(Color.black)
        }
        .cornerRadius(8)
        .padding(10)
        .alert(isPresented: self.$viewModel.hasLoginError) {
            let error = self.viewModel.loginError!

            debugPrint("Login Error: \(String(describing: error))")

            let errorMessage = error.localizedDescription

            return Alert(
                title: Text(errorMessage),
                dismissButton: .default(
                    Text("Ok"),
                    action: { self.viewModel.loginError = nil }
                )
            )
        }
    }

    // Toggle account login/creation mode
    var toggleAuthMode: some View {
        Button {
            self.isCreatingAccount = !self.isCreatingAccount
        } label: {
            Text(self.isCreatingAccount ? "Sign In" : "Create Acoount")
        }
        .foregroundStyle(Color.black)
        .padding(5)
    }
}

// MARK: Functions

extension LoginMainView {
    func signIn() {
        guard !self.email.isEmpty, !self.password.isEmpty else {
            if self.email.isEmpty {
                self.emptyEmailAlertIsPresented = true
            }
            if self.password.isEmpty {
                self.emptyPasswordAlertIsPresented = true
            }
            return
        }

        if !self.isCreatingAccount {
            self.viewModel.signIn(email: self.email, password: self.password)

            self.viewModel.rememberEmail(email: self.doesRemember ? self.email : nil)
        } else {
            self.viewModel.signUp(email: self.email, password: self.password)
        }
    }
}

struct LoginMainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LoginViewModel()

        Group {
            LoginMainView()
                .preferredColorScheme(.light)
                .environmentObject(viewModel)

            LoginMainView()
                .preferredColorScheme(.dark)
                .environmentObject(viewModel)
        }
    }
}
