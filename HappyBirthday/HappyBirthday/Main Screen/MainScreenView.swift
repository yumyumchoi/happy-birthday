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
    @Binding var path: NavigationPath
    private let repo: DataRepository
    @State private var draftName: String
    @State private var shouldShowBirthdayPicker: Bool = false
    
    init(repo: DataRepository, path: Binding<NavigationPath>) {
        self.repo = repo
        _path = path
        _draftName = State(initialValue: repo.name ?? "")
        _shouldShowBirthdayPicker = State(initialValue: repo.birthday != nil)
    }
    
    var body: some View {
        // vertical stack of 3 content elements + 1 app title
        VStack {
            
            // Name picker
            TextField("Enter Name", text: $draftName)
                .multilineTextAlignment(.center)
                .onSubmit {
                    repo.name = draftName
                }
            
            // Birthday picker
            if shouldShowBirthdayPicker{
                DatePicker("Birthday",
                           selection: Binding(
                    get: { repo.birthday ?? Date() },
                    set: { repo.birthday = $0 }
                ), displayedComponents: .date)
            } else {
                Button("Pick a Birthday") {
                    shouldShowBirthdayPicker = true
                }
            }
           
            // Photo picker
            PhotoPickerView(originView: { Text("Add Photo")}) { image in
                repo.savePhotoImage(image)
            }
            
            // Birthday screen link
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let repo = BirthdayRepository(localMetadataStore: LocalMetadataStore())
    MainScreenView(repo:repo, path:$path)
}
