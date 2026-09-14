//
//  MainScreenView.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//

import SwiftUI

// Just view render of basic metadata and link to birthday screen
@MainActor
struct MainScreenView: View {
    @State var viewModel: MainScreenViewModel
    
    init(viewModel: MainScreenViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        // vertical stack of 3 content elements + 1 app title
        VStack {
            
        }
    }
}
