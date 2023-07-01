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
            VStack(spacing: 10) {
                Text("Total Balance:")
                    .font(Font.subheadline)
                    .bold()
                
                Text("\(viewModel.balance.description)")
                    .font(Font.title3)
                    .bold()
            }
            
            Divider()
            
            TabView {
                basicView
                    .tabItem {
                        Label("Basic", systemImage: "list.dash")
                    }
                
                contractsView
                    .tabItem {
                        Label("Contracts", systemImage: "square.and.pencil")
                    }
                
                paymasterView
                    .tabItem {
                        Label("Paymaster", systemImage: "list.dash.header.rectangle")
                    }
                    .tint(Color.green)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor(named: "11142b")!))
            .padding(.horizontal, 20)
            .tint(Color(UIColor(named: "4e529a")!))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(UIColor(named: "11142b")!))
        .onAppear {
            DispatchQueue.global().async {
                viewModel.refreshBalance()
            }
        }
    }
    
    @ViewBuilder
    var basicView: some View {
        VStack(spacing: 15) {
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Refresh Balance", action: {
                DispatchQueue.global().async {
                    viewModel.refreshBalance()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Transfer via Wallet", action: {
                DispatchQueue.global().async {
                    viewModel.transferViaWallet()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Transfer", action: {
                DispatchQueue.global().async {
                    viewModel.transfer()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Deposit", action: {
                DispatchQueue.global().async {
                    viewModel.deposit()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Withdraw", action: {
                DispatchQueue.global().async {
                    viewModel.withdraw()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Withdraw via Wallet", action: {
                DispatchQueue.global().async {
                    viewModel.withdrawViaWallet()
                }
            }))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "11142b")!))
    }
    
    @ViewBuilder
    var contractsView: some View {
        VStack(spacing: 15) {
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Deploy Smart Contract", action: {
                DispatchQueue.global().async {
                    viewModel.deploySmartContract()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Deploy Smart Contract via Wallet", action: {
                DispatchQueue.global().async {
                    viewModel.deploySmartContractViaWallet()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Deploy Smart Account", action: {
                DispatchQueue.global().async {
                    viewModel.deploySmartAccount()
                }
            }))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "11142b")!))
    }
    
    @ViewBuilder
    var paymasterView: some View {
        VStack(spacing: 15) {
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Deploy Token", action: {
                DispatchQueue.global().async {
                    viewModel.deployToken()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Deploy Paymaster", action: {
                DispatchQueue.global().async {
                    viewModel.deployPaymaster()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Mint Token", action: {
                DispatchQueue.global().async {
                    viewModel.mintToken()
                }
            }))
            
            PrimaryButton(viewModel: ButtonViewModel(style: PrimaryButtonStyle.primary, fullWidth: true, title: "Token Balance", action: {
                DispatchQueue.global().async {
                    viewModel.tokenBalance()
                }
            }))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor(named: "11142b")!))
    }
}
