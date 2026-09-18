//
//  BirthdayScreenView.swift
//  HappyBirthday
//
//  Created by Choi, David on 9/13/26.
//

import SwiftUI

// MARK: - Color group model
private struct BirthdayColorGroup {
    let background: Color
    let circleBackground: Color
    let circleStroke: Color
}

private let birthdayColorGroups: [BirthdayColorGroup] = [
    .init(background: Color(hex: "C5E8DF"), circleBackground: Color(hex: "A9DCCF"), circleStroke: Color(hex: "6FC5AF")),
    .init(background: Color(hex: "DAF1F6"), circleBackground: Color(hex: "B9E5EF"), circleStroke: Color(hex: "8BD3E4")),
    .init(background: Color(hex: "FEEFCB"), circleBackground: Color(hex: "FEE7B7"), circleStroke: Color(hex: "FEBE20"))
]

struct BirthdayScreenView: View {
    private let repo: DataRepository
    @State private var colorIndex = Int.random(in: 0..<birthdayColorGroups.count)   // randomized on open
    @State private var bgAsset = ["BG_elephant", "BG_fox", "BG_pelican"].randomElement() ?? ""
    @State private var screenSize: CGSize = .zero
    @State private var sharePayload: SharePayload?
    @State private var circleImage: UIImage?
    @State private var preparedShareImage: UIImage?
    @Environment(\.displayScale) private var displayScale
    @Environment(\.dismiss) private var dismiss

    init(repo: DataRepository) {
        self.repo = repo
    }

    private var colors: BirthdayColorGroup { birthdayColorGroups[colorIndex] }

    // Age -> (number to show, unit label)
    private var age: (value: Int, unit: String) {
        guard let birthday = repo.birthday else { return (0, "MONTHS OLD") }
        let comps = Calendar.current.dateComponents([.year, .month], from: birthday, to: Date())
        let years = comps.year ?? 0
        let months = comps.month ?? 0
        if years >= 1 {
            return (years, years == 1 ? "YEAR OLD!" : "YEARS OLD!")
        } else {
            return (months, months == 1 ? "MONTH OLD!" : "MONTHS OLD!")
        }
    }

    var body: some View {
        GeometryReader { geo in
            // circle diameter = 60% width, but at least 50pt inset each side
            let photoDiameter = min(geo.size.width * 0.6, geo.size.width - 100)

            ZStack {
                colors.background.ignoresSafeArea()

                content(pd: photoDiameter, showCircle: true, forSharing: false)

                Image(bgAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()

                content(pd: photoDiameter, showCircle: false, forSharing: false)
            }
            .onAppear { screenSize = geo.size }
            .onChange(of: geo.size) { _, newSize in screenSize = newSize }
            // Decode + downsample the circle photo off-main; reloads only when the photo URL changes.
            .task(id: repo.photoImageURL) {
                if let url = repo.photoImageURL {
                    let target = max(photoDiameter, 120) * displayScale
                    circleImage = await ImageLoader.downsampledImage(at: url, maxPixelSize: target)
                } else {
                    circleImage = nil
                }
            }
            // Pre-render the share image OFF the tap path so tapping Share is instant.
            // ImageRenderer is @MainActor (can't move off-main), so we move it off the tap
            // instead — re-rendering only when a visible input changes.
            .task(id: shareRenderInputs) { await prepareShareImage() }
            .overlay(alignment: .topLeading) {
                Button { dismiss() } label: {
                    Image("nav_back_icon")
                }
                .padding(.leading, 20)
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.image])
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func content(pd: CGFloat, showCircle: Bool, forSharing: Bool) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)   // flexible top margin (spec); close button is a screen overlay now

            // "TODAY [name] IS" — text block sized to photo width, centered
            Text("TODAY \((repo.name ?? "").uppercased()) IS")
                .font(.system(size: 33))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: pd)
                .opacity(showCircle ? 0 : 1)

            Spacer().frame(height: 13)

            // swirl — number — swirl(flipped), row width = photo width
            HStack(spacing: 0) {
                Image("swirls_left")
                Spacer().frame(width: 22)
                Image("num_\(age.value)")
                Spacer().frame(width: 22)
                Image("swirls_left").scaleEffect(x: -1, y: 1)
            }
            .frame(width: pd)
            .opacity(showCircle ? 0 : 1)

            Spacer().frame(height: 14)

            Text(age.unit)
                .font(.system(size: 33))
                .opacity(showCircle ? 0 : 1)

            Spacer(minLength: 20)

            // Circle slot — ALWAYS reserves pd×pd; drawn only in the back layer,
            // an invisible (but space-holding) gap in the front layer.
            ZStack {
                Circle().fill(colors.circleBackground)
                Circle().stroke(colors.circleStroke, lineWidth: 6)
                if let circleImage {
                    Image(uiImage: circleImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: pd, height: pd)
                        .clipShape(Circle())
                } else {
                    Image("baby_photo_placeholder_symbol")
                    .renderingMode(.template)
                    .foregroundStyle(colors.circleStroke)
                }
            }
            .frame(width: pd, height: pd)
            .opacity(showCircle ? 1 : 0)
            .overlay(alignment: .center) {
                // Camera badge sits on the stroke at 45° clockwise from the top.
                // Front layer only (visible + tappable, on top of the decorative bg).
                // Excluded from the shared image (forSharing).
                if !showCircle && !forSharing {
                    PhotoPickerView(originView: { cameraButton(size: 48) }) { image in
                        repo.savePhotoImage(image)
                    }
                    .offset(x: (pd / 2) * sin(.pi / 4), y: -(pd / 2) * cos(.pi / 4))
                }
            }

            Spacer(minLength: 20)

            Image("nanit_logo")
                .opacity(showCircle ? 0 : 1)

            Spacer().frame(height: 53)

            Button {
                shareTapped()
            } label: {
                HStack {
                    Text("Share the news")
                    Image("share_icon")
                }
                .padding()
            }
            .background(Color(hex: "EF7B7B"))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .opacity((showCircle || forSharing) ? 0 : 1)

            Spacer().frame(height: 53)
        }
        .frame(maxWidth: .infinity)
    }

    // Camera badge: bg circle sized to the asset, camera symbol centered on top.
    private func cameraButton(size: CGFloat) -> some View {
        ZStack {
            Circle().fill(colors.circleStroke)          // bg circle, same size as the asset
            Image("camera_icon_symbol")
                .renderingMode(.template)
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }

    // Inputs that change what the shared image looks like. When any change, the pre-render
    // task re-runs. Keyed on the circle image's object identity so it re-renders once the
    // downsampled photo finishes loading (nil -> loaded, or a new photo).
    private var shareRenderInputs: String {
        let photoToken = circleImage.map { "\(ObjectIdentifier($0).hashValue)" } ?? "none"
        return "\(colorIndex)|\(bgAsset)|\(age.value)|\(Int(screenSize.width))|\(photoToken)"
    }

    // Tap is instant when the pre-render is ready; otherwise render on demand as a fallback.
    private func shareTapped() {
        if let image = preparedShareImage {
            sharePayload = SharePayload(image: image)
        } else {
            Task {
                await prepareShareImage()
                if let image = preparedShareImage {
                    sharePayload = SharePayload(image: image)
                }
            }
        }
    }

    // Render the whole birthday screen — minus share button + camera badge — to a UIImage.
    // Runs on @MainActor (ImageRenderer requires it) but OFF the tap path, so no tap lag.
    @MainActor
    private func prepareShareImage() async {
        guard screenSize != .zero else { return }
        await Task.yield()   // let the current frame commit before the heavy render

        let pd = min(screenSize.width * 0.6, screenSize.width - 100)
        let shareView = ZStack {
            colors.background
            content(pd: pd, showCircle: true,  forSharing: true)
            Image(bgAsset)
                .resizable()
                .scaledToFill()
                .frame(width: screenSize.width, height: screenSize.height)
                .clipped()
            content(pd: pd, showCircle: false, forSharing: true)
        }
        .frame(width: screenSize.width, height: screenSize.height)

        let renderer = ImageRenderer(content: shareView)
        renderer.scale = displayScale          // crisp @2x/@3x output
        preparedShareImage = renderer.uiImage
    }
}

// hex color utility
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// UIActivityViewController bridge for presenting the system share sheet.
struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// Identifiable wrapper so the share sheet presents via .sheet(item:) with the image guaranteed present.
struct SharePayload: Identifiable {
    let id = UUID()
    let image: UIImage
}

#Preview {
    BirthdayScreenView(repo: BirthdayRepository(localMetadataStore: LocalMetadataStore(), localPhotoStore: LocalPhotoStore()))
}
