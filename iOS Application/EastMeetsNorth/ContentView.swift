//
//  ContentView.swift
//  EastMeetsNorth
//
//  Created by Sae Nuruki on 2023/11/11.
//

import SwiftUI
import PDFKit
import Combine
import Kingfisher

struct ContentView: View {
    let backgroundColor: Color = .init(red: 25 / 255, green: 27 / 255, blue: 35 / 255)
    let gradientColor: Color = .init(red: 13 / 255, green: 15 / 255, blue: 25 / 255, opacity: 0)
    let themeBlue: Color = .init(red: 1 / 255, green: 150 / 255, blue: 240 / 255)
    let themeGray: Color = .init(red: 46 / 255, green: 48 / 255, blue: 51 / 255)
    let placeholderGray: Color = .init(red: 214 / 255, green: 199 / 255, blue: 199 / 255)
    let secondalyGray: Color = .init(red: 142 / 255, green: 145 / 255, blue: 154 / 255)
    
    func isAIMessage(with message: Message) -> Bool {
        if case .ai(_) = message {
            return true
        }
        return false
    }
    var reliability: Double? {
        guard
            let lastChat = chatHistories.filter({ isAIMessage(with: $0) }).last,
            case .ai(let message) = lastChat else { return nil}
        return message.reliability
    }
    var reliabilityText: String {
        guard let reliability else { return "Not very reliable" }
        switch reliability {
        case let reliability where reliability >= 0.7:
            return "Reliable"
        case let reliability where reliability >= 0.4:
            return "Pretty reliable"
        default:
            return "Not very reliable"
        }
    }
   
    @State var isSplash: Bool = true
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @FocusState var isEditing: Bool
    @State var inputText: String = ""
    @State var chatHistories: [Message] = []
    @State private var animateBigCircle = false
    @State private var animateSmallCircle = false
    @State private var animateText = false
    @Namespace private var switchAnimation
    @State private var showingSheet = false
    @State private var showingPaper = false

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            mainContent
            if !isSplash {
                VStack {
                    chatHeader
                    Spacer()
                }
                .ignoresSafeArea()
            }
            if !isSplash {
                VStack {
                    Spacer()
                    ZStack {
                        LinearGradient(colors: [gradientColor, backgroundColor, backgroundColor, backgroundColor], startPoint: .top, endPoint: .bottom)
                            .frame(height: isEditing ? 120 : 0)
                        textInputView
                            .frame(height: isEditing ? 100 : 0)
                            .padding(.bottom, 20)
                            .animation(.easeOut, value: isEditing)
                    }
                }
            }
            if !isEditing {
                VStack {
                    Spacer()
                    if !isSplash {
                        if isRecording || !speechRecognizer.transcript.isEmpty {
                            ScrollView {
                                Text(speechRecognizer.transcript)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 36)
                            .frame(maxHeight: 100)
                            .background(RoundedRectangle(cornerRadius: 20).foregroundColor(backgroundColor))
                        }
                    }
                    footer
                }
                .ignoresSafeArea()
            }
        }
    }
    
    var mainContent: some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView {
                    if isSplash {
                        initBody
                    } else {
                        chatBody
                            .onChange(of: chatHistories.count) { count in
                                print("count: \(count)")
                                proxy.scrollTo(chatHistories.last, anchor: .bottom)
                            }
                    }
                }
            }
        }
    }

    var initBody: some View {
        VStack {
            Spacer()
            ZStack {
//                let url = Bundle.main.url(forResource: "main_circle", withExtension: "gif")
//                AnimatedGifView(url: url)
                Image("main_circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 36)
                    .matchedGeometryEffect(id: "circleImage", in: switchAnimation)
                if animateText {
                    VStack {
                        Text("Hi, how can I help you?")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .transition(.scale)
                        Spacer().frame(height: 16)
                        Text("Go ahead, I’m listening")
                            .font(.system(size: 16))
                            .foregroundColor(placeholderGray)
                            .transition(.scale)
                    }
                    .opacity(isSplash ? 1.0 : 0.0)
                }
            }
            Spacer()
            if isRecording {
                ScrollView {
                    Text(speechRecognizer.transcript)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 36)
                .frame(maxHeight: 100)
            } else {
                textInputView
            }
            Spacer().frame(height: 48)
        }
        .onAppear {
            withAnimation() {
                animateText = true
            }
        }
    }
    
    var chatHeader: some View {
        ZStack {
            LinearGradient(colors: [backgroundColor, backgroundColor, backgroundColor, gradientColor], startPoint: .top, endPoint: .bottom)
            HStack {
                circleImage
                    .frame(height: 128)
                    .matchedGeometryEffect(id: "circleImage", in: switchAnimation)
                    .animation(.easeOut(duration: 2), value: reliability)
                Spacer()
            }
        }
        .frame(height: 180)
    }

    var circleImage: some View {
        guard let reliability else {
            return Image("main_circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }

        switch reliability {
        case let reliability where reliability >= 0.7:
            return Image("main_circle_green")
                .resizable()
                .aspectRatio(contentMode: .fit)
        case let reliability where reliability >= 0.4:
            return Image("main_circle_yellow")
                .resizable()
                .aspectRatio(contentMode: .fit)
        default:
            return Image("main_circle_red")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    var chatBody: some View {
        VStack(spacing: 40) {
            Spacer().frame(height: 120)
            ForEach(chatHistories, id: \.id) { chat in
                switch chat {
                case .me(let message):
                    meChat(message: message)
                case .ai(let message):
                    aiChat(message: message)
                case .paper(let message, let url):
                    paperChat(message: message, url: url)
                case .error(let message):
                    errorChat(message: message)
                case .loading:
                    loadingChat()
                }
            }
            .animation(.easeIn, value: chatHistories)
        }
        .padding(.bottom, 120)
    }
    
    func meChat(message: String) -> some View {
        HStack {
            Spacer()
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(RoundedCorners(color: themeBlue, tl: 16, tr: 0, bl: 16, br: 16))
        }
        .padding(.horizontal, 24)
        .transition(.move(edge: .bottom))
    }
    
    func aiChat(message: AIMessage) -> some View {
        HStack {
            VStack {
                HStack(spacing: 8) {
                    ZStack {
                        CircularProgressView(progress: message.reliability)
                            .frame(width: 42, height: 42)
                        HStack(spacing: 0) {
                            Text("\(Int(message.reliability * 100))")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                            Text("%")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                        }
                    }
                    Text(reliabilityText)
                        .font(.system(size: 12))
                        .foregroundColor(secondalyGray)
                    Button(action: {
                        showingSheet.toggle()
                    }) {
                        Image("button_i")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16)
                    }
                    .sheet(isPresented: $showingSheet) {
                        GuideView()
                    }
                    Spacer()
                }
                HStack {
                    Text(message.answer)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    Spacer()
                }
                HStack(spacing: 4) {
                    Text("Source:")
                        .font(.system(size: 12))
                        .foregroundColor(secondalyGray)
                    Button(action: {
                        insertPaper(with: message)
                    }) {
                        Text(message.doi)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 2)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: 1)
                                    .fill(secondalyGray)
                            }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(RoundedCorners(color: themeGray, tl: 0, tr: 16, bl: 16, br: 16))
            Spacer()
        }
        .padding(.horizontal, 24)
//        .transition(.move(edge: .bottom))
    }

    func paperChat(message: AIMessage, url: URL) -> some View {
        Group {
            HStack {
                Text("This is where I found the information")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(RoundedCorners(color: themeGray, tl: 0, tr: 16, bl: 16, br: 16))
                Spacer()
            }
            HStack {
                VStack {
                    ScrollView(.vertical) {
                        WebView(url: url)
                            .scaledToFit()
                    }
                    .frame(height: 160)
                    .background(secondalyGray)
                    HStack {
                        Text(message.author + " " + message.organization)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                        Spacer()
                        Text(message.publication_date)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background(themeGray)
                }
                .cornerRadius(16)
                Spacer()
            }
            .onTapGesture { showingPaper.toggle() }
            .sheet(isPresented: $showingPaper) { WebView(url: url) }
        }
        .padding(.horizontal, 24)
        .transition(.move(edge: .bottom))
    }
    
    func errorChat(message: String) -> some View {
        HStack {
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(RoundedCorners(color: themeGray, tl: 0, tr: 16, bl: 16, br: 16))
            Spacer()
        }
        .padding(.horizontal, 24)
//        .transition(.move(edge: .bottom))
    }
    
    func loadingChat() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: UIScreen.screenWidth * 0.6, height: 14)
                    .foregroundColor(secondalyGray)
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: UIScreen.screenWidth * 0.6, height: 14)
                    .foregroundColor(secondalyGray)
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: UIScreen.screenWidth * 0.4, height: 14)
                    .foregroundColor(secondalyGray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(RoundedCorners(color: themeGray, tl: 0, tr: 16, bl: 16, br: 16))
            Spacer()
        }
        .padding(.horizontal, 24)
        .transition(.move(edge: .bottom))
    }

    var textInputView: some View {
        HStack(spacing: 4) {
            TextField("", text: $inputText, axis: .vertical)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .focused($isEditing)
                .onSubmit { isEditing = false }
                .padding(.horizontal, 36)
                .frame(maxHeight: 100)
            if isEditing {
                Button {
                    isEditing = false
                    isRecording = false
                    if !inputText.isEmpty {
                        requestAISuggest()
                    }
                } label: {
                    Image("button_send")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 57, height: 57)
                }
                .frame(width: 57, height: 57)
                .padding(.trailing, 24)
            }
        }
    }
    
    var footer: some View {
        ZStack {
            LinearGradient(colors: [gradientColor, backgroundColor, backgroundColor, backgroundColor], startPoint: .top, endPoint: .bottom)
                .frame(height: 148)
            HStack(alignment: .bottom) {
                Button(action: {
                    isEditing = true
                }, label: {
                    Image("button_keyboard")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 57, height: 57)
                })
                .frame(width: 57, height: 57)
                Spacer()
                
                Button(action: {
                    if !isRecording {
                        speechRecognizer.transcribe()
                    } else {
                        speechRecognizer.stopTranscribing()
                        inputText = speechRecognizer.transcript
                    }
                    isRecording.toggle()
                }) {
                    if isRecording {
                        ZStack {
                            Circle() // Big circle
                                .stroke()
                                .frame(width: 140, height: 140)
                                .foregroundColor(.white)
                                .scaleEffect(animateBigCircle ? 1 : 0.3)
                                .opacity(animateBigCircle ? 0: 1)
                                .animation (Animation.easeInOut (duration:2)
                                    .repeatForever(autoreverses: false))
                                .onAppear() { self.animateBigCircle.toggle() }
                            Circle () //Gray
                                .foregroundColor(themeBlue.opacity(0.5))
                                .frame(width: 88, height: 88)
                                .scaleEffect(animateSmallCircle ? 0.9 : 1.2)
                                .animation(Animation.easeInOut (duration: 0.4)
                                    .repeatForever(autoreverses: false))
                                .onAppear() { self.animateSmallCircle.toggle() }
                            Image("button_stop")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 88, height: 88)
                        }
                    } else {
                        Image("button_speech")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 88, height: 88)
                    }
                }
                .frame(width: 88, height: 88)
                Spacer()
                Button {
                    isEditing = false
                    isRecording = false
                    if !inputText.isEmpty {
                        requestAISuggest()
                    }
                } label: {
                    Image("button_send")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 57, height: 57)
                }
                .frame(width: 57, height: 57)
            }
//        }
            .padding(.bottom, 48)
            .frame(height: 148)
            .padding(.horizontal, 36)
            .ignoresSafeArea(.keyboard)
        }
    }
}

extension ContentView {
    func requestAISuggest() {
        withAnimation {
            chatHistories.append(.me(message: inputText))
            isSplash = false
            chatHistories.append(.loading)
            speechRecognizer.transcript = ""
        }

        Task {
            do {
                guard let url = URL(string: "https://east-meets-north.citroner.blog/cgi/query?question=\(inputText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
                let urlRequest = URLRequest(url: url)
                let (data, _) = try await URLSession.shared.data(for: urlRequest)
                let aiMessage = try JSONDecoder().decode(AIMessage.self, from: data)
                if case .loading = chatHistories.last {
                    chatHistories.removeLast()
                }
                chatHistories.append(.ai(message: aiMessage))
                inputText = ""
            } catch {
                errorHandling(with: "Network Issue, Please try it later.")
            }
        }
    }
    
    func insertPaper(with message: AIMessage) {
        withAnimation {
            chatHistories.append(.loading)
        }

        print("⭐️: message: \(message)")
        guard let url = URL(string: message.source) else {
//        guard let url = URL(string: "https://arxiv.org/pdf/1706.03762.pdf") else {
//        guard let url = URL(string: "https://arxiv.org/pdf/1810.04805.pdf") else {
            errorHandling(with: "Resource Doesn't Exist, Please try it later.")
            return
        }
        
        if case .loading = chatHistories.last {
            chatHistories.removeLast()
        }
        chatHistories.append(.paper(message: message, url: url))
//        DispatchQueue.global(qos: .userInteractive).async {
//            guard let document = PDFDocument(url: url) else {
//                errorHandling(with: "Invalid URL, Please try it later.")
//                return
//            }
//            DispatchQueue.main.async {
//                if case .loading = chatHistories.last {
//                    chatHistories.removeLast()
//                }
//                chatHistories.append(.paper(message: message, document: document))
//            }
//        }
    }
    
    func errorHandling(with message: String) {
        if case .loading = chatHistories.last {
            chatHistories.removeLast()
        }
        chatHistories.append(.error(message: message))
    }
}

enum Message: Identifiable, Equatable, Hashable {
    case me(message: String)
    case ai(message: AIMessage)
    case paper(message: AIMessage, url: URL)
    case error(message: String)
    case loading

    var id: String {
        switch self {
        case .me(let message):
            return message
        case .ai(let message):
            return message.answer + message.question
        case .paper(let message, _):
            return message.doi
        case .error(let message):
            return message
        case .loading:
            return "loading"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

struct AIMessage: Decodable {
    let question: String
    let answer: String
    let source: String
    let reliability: Double
    let doi: String
    let author: String
    let organization: String
    let publication_date: String
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
