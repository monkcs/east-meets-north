//
//  GuideView.swift
//  EastMeetsNorth
//
//  Created by Sae Nuruki on 2023/11/11.
//

import SwiftUI

struct GuideView: View {
    let backgroundColor: Color = .init(red: 25 / 255, green: 27 / 255, blue: 35 / 255)

    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            mainBody
        }
    }
    
    var mainBody: some View {
        ScrollView {
            VStack {
                HStack {
                    Image("main_circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120)
                    Text("How do you measure the reliability score?")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                Spacer().frame(height: 40)
                Text("Reliability score is based on the source type. Each source type has different criteria that gets scored and weight to calculate the reliability score.")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                academicResearch
                newsArticles
            }
        }
        .padding(.horizontal, 24)
    }
    
    var academicResearch: some View {
        VStack {
            Spacer().frame(height: 32)
            HStack {
                Text("Academic research")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer().frame(height: 8)
            Image("table_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    var newsArticles: some View {
        VStack {
            Spacer().frame(height: 32)
            HStack {
                Text("News articles")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer().frame(height: 8)
            Text("For news articles we use NewsGards ranking on credible news sources. Their ranking includes a pool of professional journalists who ranks news sites based on nine criteria. They also have a process for reviewing, asking the news sites for feedback, and continuously updating this score.  Read more on their website. ")
                .font(.system(size: 12))
                .foregroundColor(.white)
            Spacer().frame(height: 8)
            Image("table_2")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

