//
//  AnimatedGifView.swift
//  EastMeetsNorth
//
//  Created by Sae Nuruki on 2023/11/11.
//

//Bundle.main.url(forResource: rawValue, withExtension: "gif")

import Kingfisher
import SwiftUI
import UIKit

struct AnimatedGifView: UIViewRepresentable {
    let url: URL?

    func makeUIView(context: Context) -> AnimatedImageView {
        let view = AnimatedImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: AnimatedImageView, context: Context) {
        guard let url else { return }
        let cacheKey = "\(url)".split(separator: "?").compactMap { String($0) }.first
        let resource = ImageResource(downloadURL: url, cacheKey: cacheKey)
        uiView.kf.setImage(with: resource)
    }
}
