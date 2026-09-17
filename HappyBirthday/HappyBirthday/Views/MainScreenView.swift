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
            // app title
            Text("Happy Birthday")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
            
            // Name picker
            TextField("Enter Name", text: $draftName)
                .multilineTextAlignment(.center)
                .onSubmit {
                    repo.name = draftName
                }
                .padding(20)
            
            // Birthday picker
            if shouldShowBirthdayPicker{
                HStack(spacing: 20) {
                    Spacer()
                    Text("Birthday")
                    DatePicker("",
                               selection: Binding(
                                get: { repo.birthday ?? Date() },
                                set: { repo.birthday = $0 }
                               ), displayedComponents: .date)
                    .labelsHidden()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(20)
            } else {
                Button("Pick a Birthday") {
                    shouldShowBirthdayPicker = true
                }
                .padding(20)
            }
           
            // Photo picker
            PhotoPickerView(originView: { Text("Add Photo")}) { image in
                repo.savePhotoImage(image)
            }
            .padding(20)
            if let url = repo.photoImageURL,
               let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
            }
            
            // Birthday screen link
            Button("Show birthday screen") {
                path.append(Route.birthdayScreen)
            }
            .disabled(repo.name == nil || repo.birthday == nil)
            .padding(20)
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let repo = BirthdayRepository(localMetadataStore: LocalMetadataStore(), localPhotoStore: LocalPhotoStore())
    MainScreenView(repo:repo, path:$path)
}
