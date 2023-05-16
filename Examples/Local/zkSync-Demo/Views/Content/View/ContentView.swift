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
        VStack(spacing: 20) {
            Text("\(viewModel.balance.description)")
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.refreshBalance()
                }
            }, label: {
                Text("Refresh Balance")
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
                    viewModel.transfer()
                }
            }, label: {
                Text("Deposit")
            })
            
            Button(action: {
                DispatchQueue.global().async {
                    viewModel.withdrawViaWallet()
                }
            }, label: {
                Text("Withdraw via Wallet")
            })
        }
        .padding()
        .onAppear {
            DispatchQueue.global().async {
                viewModel.refreshBalance()
            }
        }
    }
}
