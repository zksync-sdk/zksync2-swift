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
        VStack(spacing: 10) {
            Text("\(viewModel.balance.description)")
            
            Button(action: {
                viewModel.refreshBalance()
            }, label: {
                Text("Refresh")
            })
            
            Button(action: {
                viewModel.transferViaWallet()
            }, label: {
                Text("Transfer via Wallet")
            })
        }
        .padding()
        .onAppear {
            viewModel.refreshBalance()
        }
    }
}
