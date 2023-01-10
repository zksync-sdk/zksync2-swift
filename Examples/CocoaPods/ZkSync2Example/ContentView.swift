//
//  ContentView.swift
//  ZkSync2Example
//
//  Created by Maxim Makhun on 7/10/22.
//

import SwiftUI
import web3swift_zksync
import ZkSync2

struct ContentView: View {
    
    // Make sure that ZkSync2 symbols are available
    let credentials = Credentials("0x<private_key>")
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
