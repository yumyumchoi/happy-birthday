//
//  RootNavigation.swift
//  happy-birthday
//
//  Created by Choi, David on 9/13/26.
//

// Central orchestration of view navigation. Bit of an overkill for 2 screen app, but having a centralized, separate place for navigationStack would ensure easier reading of flow & separation of concerns

import SwiftUI

enum Route: Hashable {
    case birthdayScreen
}

struct RootNavigationView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            let localMetadataStore = LocalMetadataStore()
            let repo = BirthdayRepository(localMetadataStore: localMetadataStore)
            let mainScreenViewModel = MainScreenViewModel(repo: repo)
            MainScreenView(viewModel: mainScreenViewModel, path: $path).navigationDestination(for: Route.self) { route in
                switch route {
                case .birthdayScreen:
                    let birthdayScreenViewModel = BirthdayScreenViewModel(repo: repo)
                    BirthdayScreenView(viewModel: birthdayScreenViewModel)
                }
           
            }
        }
    }
}

#Preview {
    RootNavigationView()
}
