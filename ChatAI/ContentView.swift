//
//  ContentView.swift
//  ChatAI
//
//  Created by John Reichel on 2/27/23.
//

import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    init() {
        
    }
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "")
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                Image("chatgpt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                Text("ChatGPT Messenger")
                    .font(.title3)
                    .frame(width: 150, height: 50)
            }
            .padding(.bottom, 50)
            
            ForEach(models, id: \.self) { string in
                Text(string)
                    .padding(.bottom, 10)
            }
            
            Spacer()
            HStack {
                TextField("Type here...", text: $text)
                Button("Send") {
                    send()
                }
            }
        }
        .onAppear {
            viewModel.setup()
        }
        .padding()
    }
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        models.append("Me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                self.text = ""
                self.models.append("ChatGPT: " + response)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
