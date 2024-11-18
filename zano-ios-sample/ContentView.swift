//
//  ContentView.swift
//  zano-ios-sample
//
//  Created by Jumpei Katayama on 2024/09/13.
//

import SwiftUI
import zano_ios
import Combine


struct Wallet: Identifiable {
    let id = UUID()
    let name: String
}

extension Wallet: Equatable {
}


struct WalletItemView: View {
    let name: String
    var onPress: (() -> Void)
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Circle()
                .foregroundColor(.blue)
                .frame(width: 8, height: 8)
            Button {
                onPress()
            } label: {
                HStack {
                    Text(name)
                }
            }
        }
    }
}

struct WalletNameView: View {
    let name: String
    var onPress: (() -> Void)
    var body: some View {
        HStack(spacing: .zero) {
            Button {
                onPress()
            } label: {
                HStack {
                    Text(name)
                }
            }
        }
    }
}

struct SettingsScreen: View {
    @StateObject var viewModel = SettingsViewModel()
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Versions")
                    Text(viewModel.version)
                }
                VStack(spacing: 8) {
                    Text("IP")
                    Text(viewModel.ipAddress)
                }
                VStack(spacing: 8) {
                    Text("working directory")
                    Text(viewModel.workingDir)
                }
                VStack(spacing: 8) {
                    Text("Versions")
                    Text(viewModel.version)
                }
                VStack(spacing: 8) {
                    Text("Tx Fee")
                    Text(viewModel.fee)
                }
                
                VStack(spacing: 8) {
                    Text("Connectivity Status")
                    Text(viewModel.connectionStatus)
                }

            }
        }
        .onAppear(perform: {
            viewModel.onAppear()
        })
        .task {
            Task {
                await viewModel.getConnectivityStatus()
            }
        }

    }
}

class SettingsViewModel: ObservableObject {
    var interactor = Interactor.shared
    @Published var version: String = ""
    @Published var fee: String = ""
    @Published var workingDir: String = ""
    @Published var ipAddress: String = ""
    @Published var connectionStatus: String = ""
    
    init() {
    }
    
    func onAppear() {
        version = interactor.getVersion()
        fee = interactor.getTransactionFee()
        ipAddress = interactor.ip
        workingDir = interactor.workingDir
        
    }
    
    
    @MainActor
    func getConnectivityStatus() async {
        do {
            let result = try await interactor.getConnectivityStatus()
            connectionStatus = "isOnline: \(result.isOnline), isServerBusy: \(result.isServerBusy), lastDaemonIsDisconnected: \(result.lastDaemonIsDisconnected), lastProxyCommunicateTimestamp: \(result.lastProxyCommunicateTimestamp)"
        } catch {
            debugPrint(error.localizedDescription)
        }
        
    }
}

enum NavigationItem: Hashable {
    case add
    case restoreTop
    case restore
    case openExistingWallet(String)
}

struct ContentView: View {
    @State private var path: [NavigationItem] = []
    @StateObject var viewModel = ViewModel()
    @State var showExistingWallets: Bool = false
    @State var showAddWallets: Bool = false
    @State var showRestoreWallets: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                if viewModel.isOpendingWallet {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .frame(width: 28, height: 28)
                        .padding(.horizontal, 16)
                }
                LazyVStack() {
                    Section(
                        content: {
                            if !viewModel.wallets.isEmpty {
                                ForEach(viewModel.wallets) { wallet in
                                    WalletItemView(name: wallet.name, onPress: {
                                    })
                                }
                            } else {
                                Text("There's no opened wallets")
                                Button("tap to open wallets") {
                                    Task {
                                        await viewModel.getWallets()
                                    }
                                }
                            }
                            
                        },
                        header: {
                            HStack {
                                Text("Opened Wallets")
                                Spacer()
                            }
                        })
                    
                    Section(
                        content: {
                            ForEach(viewModel.allwallets) { wallet in
                                WalletItemView(name: wallet.name, onPress: {
                                    path.append(.openExistingWallet(wallet.name))
                                })
                            }
                        },
                        header: {
                            HStack {
                                Text("All Wallets including opened and closed")
                                Spacer()
                            }
                        })

                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        path.append(NavigationItem.restoreTop)
                    }) {
                        Text("Restore")
                        
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        path.append(NavigationItem.add)
                    }) {
                        Text("Add")
                    }
                }
            }
            .navigationDestination(for: NavigationItem.self, destination: { path in
                switch path {
                case .add:
                    AddWalletScreen(navigationPath: $path)
                case .restore:
                    RestoreWalletScreen(navigationPath: $path)
                case .restoreTop:
                    RestoreTopScreen(path: $path)
                case .openExistingWallet(let walletName):
                    OpenExistingWalletScreen(navigationPath: $path, viewModel: OpenExistingWalletViewModel(walletName: walletName))
                }
            })
        }
        
        
    }
}

struct AddWalletScreen: View {
    @Binding var navigationPath: [NavigationItem]
    @StateObject var viewModel: AddWalletViewModel = AddWalletViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                TextField("enter your wallet name", text: $viewModel.name)
                TextField("enter password", text: $viewModel.pass)
            }
            .padding(.horizontal, 32)
            Button(action: {
                viewModel.tapCreateWallet()
            }) {
                Text("Create wallet")
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .navigationTitle("Add Wallet")
        }
        .task(id: viewModel.shouldBeBackToTop) {
            guard viewModel.shouldBeBackToTop != nil else { return }
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
            
        }
    }
}
// MARK: - Add
class AddWalletViewModel: ObservableObject {
    var interactor = Interactor.shared
    @Published var shouldBeBackToTop: Bool?

    @Published var name: String = ""
    @Published var pass: String = ""
    
    func tapCreateWallet() {
        do {
            let walletResult = try interactor.createWallet(name: name, pass: pass)
            debugPrint("interactor.createWallet was successful \n \(walletResult)")
            shouldBeBackToTop = true
        } catch {
            debugPrint(error)
        }
    }
}

class RestoreWalletViewModel: ObservableObject {
    var interactor = Interactor.shared
    @Published var pass: String = ""
    @Published var seedPass: String = ""
    @Published var mnemonic: String = ""
    
    @Published var shouldBeBackToTop: Bool?
    
    init() {
    }
    
    @MainActor
    func tapRestoreWallet() {
        let generatedName = UUID.init(uuidString: mnemonic)?.uuidString ?? String(mnemonic.prefix(10))
        Task {
//            let result = try await interactor.asyncRestore(name: "wallet of \(mnemonic.prefix(6))", pass: mnemonic)
            let result = try await interactor.asyncRestore(name: generatedName, seed: mnemonic, password: pass, seedPass: seedPass)
            
            debugPrint("result is \(String(describing: result))")
            shouldBeBackToTop = true
        }
    }
}

struct RestoreWalletScreen: View {
    @Binding var navigationPath: [NavigationItem]
    @StateObject var viewModel = RestoreWalletViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                TextField("enter password for wallet pass (Optional)", text: $viewModel.pass)
                TextField("mnemonic", text: $viewModel.mnemonic)
                TextField("Enter password for mnemonic (Optional)", text: $viewModel.seedPass)
                
            }
            .padding(.horizontal, 32)
            Button(action: {
                viewModel.tapRestoreWallet()
            }) {
                Text("Create wallet")
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .navigationTitle("Restore Wallet")
            .task(id: viewModel.shouldBeBackToTop) {
                guard viewModel.shouldBeBackToTop != nil else { return }
                navigationPath.removeLast()
            }

        }
    }
}

// MARK: - RestoreWalletScreen
struct RestoreTopScreen: View {
    @StateObject var viewModel = RestoreTopViewModel()
    @Binding var path: [NavigationItem]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Button("Restore", action: {
                    path.append(.restore)
                })
            }
            VStack(spacing: 8) {
                Text("Existing Wallets you can open")
                LazyVStack() {
                    ForEach(viewModel.wallets) { wallet in
                        WalletItemView(name: wallet.name, onPress: {
                            viewModel.openWallet(walletName: wallet.name)
                        })
                    }
                }
            }
            .navigationDestination(for: NavigationItem.self, destination: { path in
                switch path {
                case .add:
                    AddWalletScreen(navigationPath: $path)
                case .restore:
                    RestoreWalletScreen(navigationPath: $path)
                case .restoreTop:
                    RestoreTopScreen(path: $path)
                case .openExistingWallet(let name):
                    OpenExistingWalletScreen(navigationPath: $path, viewModel: OpenExistingWalletViewModel(walletName: name))
                }
            })
            .navigationTitle("Restore Wallet")
        }
    }
}

class RestoreTopViewModel: ObservableObject {
    var interactor = Interactor()
    @Published var wallets: [Wallet] = []
    
    init() {
        wallets = interactor.getWalletNames().map { Wallet(name: $0) }
    }
    
    func openWallet(walletName: String) {
        debugPrint("tap open wallet \(walletName)")
    }
}


// MARK: - ExistingsWalletsScreen
struct OpenExistingWalletScreen: View {
    @Binding var navigationPath: [NavigationItem]
    @StateObject var viewModel: OpenExistingWalletViewModel
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Wallet name:")
                    Spacer()
                }
                Text(viewModel.name)
            }
            VStack {
                HStack {
                    Text("Password:")
                    Spacer()
                }
                TextField("enter password", text: $viewModel.pass)
            }
            Button {
                Task {
                    try await viewModel.open()
                }
            } label: {
                HStack {
                    Text("Open wallets")
                }
            }
            .navigationTitle("Open Existing Wallet")
        }
        .alert(
            Text("Error"),
            isPresented: $viewModel.showAlert,
            actions: {
                Button(
                    "OK", role: .cancel,
                    action: {
                        viewModel.showAlert = false
                    })
            },
            message: {
                Text("Something went wrong.")
            }
        )
        .task(id: viewModel.shouldBeBackToTop) {
            guard viewModel.shouldBeBackToTop != nil else { return }
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
            
        }

    }
}


class OpenExistingWalletViewModel: ObservableObject {
    var interactor = Interactor.shared
    let name: String
    @Published var pass: String = ""
    @Published var shouldBeBackToTop: Bool?
    @Published var showAlert: Bool = false
    
    
    init(walletName: String) {
        self.name  = walletName
    }
    
    @MainActor
    func open() async throws {
        do {
            let result = try await interactor.asyncOpen(name: name, pass: pass)
            debugPrint("result is \(result.debugDescription)")
            shouldBeBackToTop = true
        } catch {
            showAlert = true
            debugPrint(error.localizedDescription)
        }
        
    }
}

class ViewModel: ObservableObject {
    @Published var initStatus: String = ""
    @Published var restoreStatus: String = ""
    @Published var createStatus: String = ""
    @Published var resetStatus: String = ""
    @Published var getWalletStatus: String = ""
    @Published var isOpendingWallet: Bool = false
    
    // opened wallet
    @Published var wallets: [Wallet] = []
    // all wallet
    @Published var allwallets: [Wallet] = []
    fileprivate var walletSubject: PassthroughSubject<[Wallet], Never> = .init()
    fileprivate var allWalletSubject: PassthroughSubject<[Wallet], Never> = .init()

    
    var interactor = Interactor.shared
    
    init() {
        initZANO()
        bind()
        getAllWallets()
    }
    
    func bind() {
        walletSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$wallets)
        
        allWalletSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$allwallets)
    }

    func getWallets() async {
        let names = await interactor.getOpenedWallets().map { Wallet(name: $0.name) }
        walletSubject.send(names)
    }

    func getAllWallets() {
        allWalletSubject.send(interactor.getWalletNames().map { Wallet(name: $0) })
    }

    private func initZANO() {
        _ = interactor.initZano()
    }
}




struct JsonConverter {
    static func dictonaryToJsonString(dic: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            debugPrint("Error converting dictionary to Json string: \(error.localizedDescription)")
            return nil
        }
    }
}
