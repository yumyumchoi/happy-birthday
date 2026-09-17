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

                content(pd: photoDiameter, showCircle: true)

                Image(bgAsset)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                content(pd: photoDiameter, showCircle: false)
            }
        }
    }
    
    @ViewBuilder
    private func content(pd: CGFloat, showCircle: Bool) -> some View {
        VStack(spacing: 0) {
            // Back icon — navigation back button is more idiomatic and we get for free, so disabling the custom backbutton, but commented so can be resurrected
//            HStack {
//                Image("nav_back_icon")
//                Spacer()
//            }
//            .padding(.leading, 20)
//            .opacity(showCircle ? 0 : 1)

            // "TODAY [name] IS" — text block sized to photo width, centered
            Text("TODAY \((repo.name ?? "David").uppercased()) IS")
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
                if let url = repo.photoImageURL,
                   let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
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

            Spacer(minLength: 20)

            Image("nanit_logo")
                .opacity(showCircle ? 0 : 1)

            Spacer().frame(height: 53)

            Button {
                // share action
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
            .opacity(showCircle ? 0 : 1)

            Spacer().frame(height: 53)
        }
        .frame(maxWidth: .infinity)
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

#Preview {
    BirthdayScreenView(repo: BirthdayRepository(localMetadataStore: LocalMetadataStore(), localPhotoStore: LocalPhotoStore()))
}
