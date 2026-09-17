//
//  PhotoPickerView.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/16/26.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView<OriginView:View>: View {
    @ViewBuilder let originView: () -> OriginView
    let onImagePicked: (UIImage) -> Void
    
    @State private var showSourceDialogue = false
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var pickedItem: PhotosPickerItem?
    
    var body: some View {
        Button { showSourceDialogue = true } label: {
            originView()
        }
        .confirmationDialog("Add Photo", isPresented: $showSourceDialogue) {
            Button("Use Camera") { showCamera = true }
            Button("Choose from Library") { showLibrary = true }
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(isPresented: $showLibrary, selection: $pickedItem, matching: .images)
        .onChange(of: pickedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                    onImagePicked(img)
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPhotoPicker { img in
                showCamera = false
                onImagePicked(img)
            }
        }
    }
}
