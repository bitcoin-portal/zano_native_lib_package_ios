//
//  ContentView.swift
//  zano-ios-sample
//
//  Created by Jumpei Katayama on 2024/09/13.
//

import SwiftUI
import zano_ios

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Button("Init wallet") {
                    viewModel.tapInit()
                }
                Text("ZanoWallet.InitIpPort response")
                Text(viewModel.initStatus)
                
                Button("tap to Create wallet") {
                    viewModel.tapCreateWallet()
                }
                Text("createWalletStatus")
                Text(viewModel.createStatus)
                
                Button("tap to reset wallet") {
                    viewModel.tapReset()
                }
                Text("reset")
                Text(viewModel.resetStatus)
                
                Button("tap to get wallet files") {
                    viewModel.tapGetWalletFiles()
                }
                Text("reset")
                Text(viewModel.getWalletStatus)


            }
            .padding()
        }
    }
}

class ViewModel: ObservableObject {
    @Published var initStatus: String = ""
    @Published var restoreStatus: String = ""
    @Published var createStatus: String = ""
    @Published var resetStatus: String = ""
    @Published var getWalletStatus: String = ""
    
    
    init() {
        
    }
    
    func tapGetWalletFiles() {
        let fileManager = FileManager.default
        if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let strX = docsDir.path
            let res = try? ZanoWallet.getWalletFiles()
            getWalletStatus = res?.items.first ?? ""
        } else {
            fatalError("fileManager.url failed")
        }
        

    }
    
    func tapInit() {
        let fileManager = FileManager.default
        if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let strX = docsDir.path
            let res = try! ZanoWallet.InitIpPort(ip: ZANOConst.ZANO_MAINNET_IP, port: ZANOConst.ZANO_MAINNET_PORT, working_dir: strX, log_level: 0)
            initStatus = res.returnCode
        } else {
            fatalError("fileManager.url failed")
        }
        
    }
    
    func tapCreateWallet() {
        let fileManager = FileManager.default
        if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let strX = docsDir.path
            if let res = try? ZanoWallet.generate(walletName: ZANOConst.TEST_WALLET_NAME, password: "asdf123") {
                createStatus = "\(res.name) is created"
                debugPrint(res)
            } else {
                fatalError("ZanoWallet.generate failed")
            }
            
        } else {
            fatalError("fileManager.url failed")
        }
        
    }
    
    
    func tapReset() {
        let fileManager = FileManager.default
        if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let strX = docsDir.path
            let res = try? ZanoWallet.reset().returnCode
            resetStatus = res ?? ""
            
            
        } else {
            fatalError("fileManager.url failed")
        }
        
    }


}

#Preview {
    ContentView()
}
