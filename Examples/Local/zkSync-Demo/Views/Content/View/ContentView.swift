//
//  ContentView.swift
//  zkSync-Demo
//
//  Created by Bojan on 14.5.23..
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.balance.description)")
            
            TabView {
                basicView
                    .tabItem {
                        Label("Basic", systemImage: "list.dash")
                    }
                
                paymasterView
                    .tabItem {
                        Label("Paymaster", systemImage: "square.and.pencil")
                    }
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.global().async {
                viewModel.refreshBalance()
            }
        }
    }
    
    @ViewBuilder
    var basicView: some View {
        VStack(spacing: 20) {
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.refreshBalance()
                }
            }, label: {
                Text("Refresh Balance")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.deploySmartAccount()
                }
            }, label: {
                Text("Deploy Smart Account")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.deploySmartContract()
                }
            }, label: {
                Text("Deploy Smart Contract")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.deploySmartContractViaWallet()
                }
            }, label: {
                Text("Deploy Smart Contract via Wallet")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.transferViaWallet()
                }
            }, label: {
                Text("Transfer via Wallet")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.transfer()
                }
            }, label: {
                Text("Transfer")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.deposit()
                }
            }, label: {
                Text("Deposit")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.withdraw()
                }
            }, label: {
                Text("Withdraw")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.withdrawViaWallet()
                }
            }, label: {
                Text("Withdraw via Wallet")
            })
        }
    }
    
    @ViewBuilder
    var paymasterView: some View {
        VStack(spacing: 20) {
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.deployToken()
                }
            }, label: {
                Text("Deploy Token")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.deployPaymaster()
                }
            }, label: {
                Text("Deploy Paymaster")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.mintToken()
                }
            }, label: {
                Text("Mint Token")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.tokenBalance()
                }
            }, label: {
                Text("Token Balance")
            })
        }
    }
}
