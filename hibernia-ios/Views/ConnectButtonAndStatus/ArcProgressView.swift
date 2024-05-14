//
//  ArcProgressView.swift
//  hiberniaui
//
//  Created by Oliver Bevan on 11/05/2024.
//

import SwiftUI

struct ArcProgressView: View {
    var progress: Double
    var color: Color

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(Color.text, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(Angle(degrees: 36))

            Circle()
                .trim(from: 0, to: progress / 3.33)
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(Angle(degrees: -216 - (108*progress)))
                .shadow(radius: 15)
        }
    }
}
