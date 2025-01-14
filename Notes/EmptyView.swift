//
//  EmptyView.swift
//  Notes
//
//  Created by Sergei Semenov on 14/01/2025.
//

import SwiftUI

struct Empty1View: View {
    var body: some View {
        VStack {
            Text("Nothing here, yet")
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            
            Text("Add tasks to get started.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        
    }
    
}

#Preview {
    EmptyView()
}
