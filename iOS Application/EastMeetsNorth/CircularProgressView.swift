//
//  CircularProgressView.swift
//  EastMeetsNorth
//
//  Created by Sae Nuruki on 2023/11/11.
//

import SwiftUI

struct CircularProgressView: View {
    @State var progress2: Double = .zero
    let progress: Double
    
    let baseColor: Color = .init(red: 59 / 255, green: 63 / 255, blue: 73 / 255)
    let themeRed: Color = .init(red: 201 / 255, green: 31 / 255, blue: 31 / 255)
    let themeYellow: Color = .init(red: 223 / 255, green: 225 / 255, blue: 80 / 255)
    let themeGreen: Color = .init(red: 102 / 255, green: 230 / 255, blue: 81 / 255)
    var progressColor: Color {
        switch progress2 {
        case let progress where progress >= 0.7:
            return themeGreen
        case let progress where progress >= 0.4:
            return themeYellow
        default:
            return themeRed
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    baseColor,
                    lineWidth: 4
                )
            Circle()
                .trim(from: 0, to: progress2)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut.delay(0.5), value: progress2)
        }
        .onAppear {
            withAnimation {
                progress2 = progress
            }
        }
    }
}
