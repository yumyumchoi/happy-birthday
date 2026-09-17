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
    private let age: (value: Int, unit: String)
    private var bgAssets = ["BG_fox","BG_pelican","BG_elephant"]

    init(repo: DataRepository) {
        self.repo = repo
        // temp for preview
        age = (value: 2,"MONTHS OLD" )
    }

    private var colors: BirthdayColorGroup { birthdayColorGroups[colorIndex] }

    // Age -> (number to show, unit label)
    private func calculateAgeDisplayValue(_ birthday: Date?) -> (value: Int, unit: String) {
        guard let birthday = repo.birthday else { return (0, "MONTHS OLD") }
        let comps = Calendar.current.dateComponents([.year, .month], from: birthday, to: Date())
        let years = comps.year ?? 0
        let months = comps.month ?? 0
        if years >= 1 {
            return (years, years == 1 ? "YEAR OLD" : "YEARS OLD!")
        } else {
            return (months, months == 1 ? "MONTH OLD" : "MONTHS OLD!")
        }
    }

    var body: some View {
        GeometryReader { geo in
            // circle diameter = 60% width, but at least 50pt inset each side
            let photoDiameter = min(geo.size.width * 0.6, geo.size.width - 100)
            
            ZStack {
                Image(bgAssets[colorIndex])
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer(minLength: 20)                                   // flexible top margin
                    
                    // "TODAY [name] IS" with share icon at far left
                    HStack(alignment: .top) {
                        Image("nav_back_icon")
                        Text("TODAY \((repo.name ?? "David").uppercased()) IS")
                            .font(.system(size: 33))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: photoDiameter)
                        Spacer(minLength: 0)
                    }
                    .frame(width: photoDiameter)
                    
                    Spacer().frame(height: 13)
                    
                    // swirl — number — swirl(flipped), row width = photo width
                    HStack(spacing: 0) {
                        Image("swirls_left")
                        Spacer().frame(width: 22)
                        Image("num_\(age.value)")
                        Spacer().frame(width: 22)
                        Image("swirls_left").scaleEffect(x: -1, y: 1)
                    }
                    .frame(width: photoDiameter)
                    
                    Spacer().frame(height: 14)
                    
                    Text(age.unit)
                        .font(.system(size: 33))
                    
                    Spacer(minLength: 20)
                    
                    // Photo circle group
                    ZStack {
                        Circle().fill(colors.circleBackground)
                        Circle().stroke(colors.circleStroke, lineWidth: 6)
                        if let url = repo.photoImageURL,
                           let uiImage = UIImage(contentsOfFile: url.path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: photoDiameter, height: photoDiameter)
                                .clipShape(Circle())
                        } else {
                            Image("baby_photo_placeholder_symbol")
                        }
                    }
                    .frame(width: photoDiameter, height: photoDiameter)
                    
                    Spacer().frame(height: 15)
                    Image("nanit_logo")
                    
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
                    
                    Spacer().frame(height: 53)
                }
                .frame(maxWidth: .infinity)
            }
            .background(colors.background.ignoresSafeArea())
        }
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
