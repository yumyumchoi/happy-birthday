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
    @Binding var path: NavigationPath
    @State private var draftName: String
    @State private var shouldShowBirthdayPicker: Bool
    
    init(viewModel: MainScreenViewModel, path: Binding<NavigationPath>) {
        _viewModel = State(initialValue: viewModel)
        _path = path
        _draftName = State(initialValue: viewModel.name ?? "")
        _shouldShowBirthdayPicker = State(initialValue: viewModel.hasBirthday)
    }
    
    var body: some View {
        // vertical stack of 3 content elements + 1 app title
        VStack {
            // TODO :: swap out with final UI treatment. For now placeholder graphics
            TextField("Enter Name", text: $draftName)
                .multilineTextAlignment(.center)
                .onSubmit {
                    viewModel.name = draftName
                }
            if shouldShowBirthdayPicker{
                DatePicker("Birthday",
                           selection: Binding(
                    get: { viewModel.birthday ?? Date() },
                    set: { viewModel.birthday = $0 }
                ), displayedComponents: .date)
            } else {
                Button("Pick a Birthday") {
                    shouldShowBirthdayPicker = true
                }
            }
           
        }
    }
}
