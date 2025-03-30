//
//  ContentView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        if sessionStore.currentUser != nil {
            HomeFeedView()
        } else {
            LoginView()
        }
    }
}

//
//#Preview {
//    ContentView()
//}
