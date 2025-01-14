//
//  EmptyView.swift
//  Notes
//
//  Created by Sergei Semenov on 14/01/2025.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        Text("Nothing here, yet")
            .foregroundColor(.secondary)
            .fontWeight(.medium)
        Text("Add tasks to get started.")
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    EmptyView()
}
