//
//  zano_ios_sampleApp.swift
//  zano-ios-sample
//
//  Created by Jumpei Katayama on 2024/09/13.
//

import SwiftUI

@main
struct zano_ios_sampleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Home", systemImage: "list.dash")
                    }
                
                SettingsScreen()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            
        }
    }
}
