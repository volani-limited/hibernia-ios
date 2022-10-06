//
//  AuthService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 29/09/2022.
//

import Foundation
import Firebase

class AuthService: ObservableObject {
    @Published var user: User?
    
    @Published var authServiceError: Error?
    @Published var retryHandler: (() -> Void)?
    
    private var userStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        registerAuthStateDidChangeListener()
        if user == nil {
            signInAnonymously()
        }
    }
    
    private func registerAuthStateDidChangeListener () {
        if let handle = userStateHandle {
            Auth.auth().removeStateDidChangeListener(handle) // Remove handle if it exists already
        }
        self.userStateHandle = Auth.auth().addStateDidChangeListener { [ weak self] (auth, user) in // Add handle and handle cases
            self?.user = user
            if let user = user {
                print("User state changed, uid: " + user.uid)
               
            } else {
                print("User state changed, user signed out.")
            }
        }
    }
    
    // MARK: Sign in/out functions
    func signOutUser() { //TODO: improve error handling
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            fatalError(signOutError as! String +  " encountered whilst signing out user.") // Try to sign out user and record error if this fails
        }
    }
    
    func signInAnonymously() -> Void {
        Auth.auth().signInAnonymously() { [weak self] authResult, error in
            if let error = error {
                self?.authServiceError = error
                self?.retryHandler = self?.signInAnonymously
                print("Could not sign in user")
            } else {
                print("User anonymously signed in")
            }
        }
    }
    
    func getAuthToken() async -> String  {
        return try! await user!.getIDToken()
    }
}

