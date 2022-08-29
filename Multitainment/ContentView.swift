//
//  ContentView.swift
//  Multitainment
//
//  Created by Nick on 2022-08-26.
//

import SwiftUI

struct ContentView: View {
    @State private var minimumMultiplication = 2
    @State private var maximumMultiplication = 12
    @State private var questions = [String]()
    @State private var currentQuestion = ""
    @State private var currentQuestionLocation = 0
    @State private var answer: Int?
    @State private var gameStarted = false
    @State private var isVerified = false
    @State var isCorrect = false
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var questionCountSelection = "5"
    @State private var questionCount = ["5", "10", "15", "20"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Multitainment")
                    .font(.largeTitle.weight(.heavy))
                SettingsView(minimumMultiplication: $minimumMultiplication, maximumMultiplication: $maximumMultiplication, questionCountSelection: $questionCountSelection, questionCount: $questionCount)
                Divider()
                    .padding()
                Spacer()
                
                QuestionsView(questionCountSelection: $questionCountSelection, maximumMultiplication: $maximumMultiplication, minimumMultiplication: $minimumMultiplication, showingAlert: $showingAlert, alertTitle: $alertTitle, alertMessage: $alertMessage, questions: $questions, currentQuestion: $currentQuestion, currentQuestionLocation: $currentQuestionLocation, answer: $answer, gameStarted: $gameStarted, isVerified: $isVerified, isCorrect: $isCorrect)
                Spacer()
            }
            .listStyle(.grouped)
            .toolbar {
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .background(LinearGradient(
                colors: [.purple, .mint],
                startPoint: .top,
                endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
        }
        .foregroundColor(.white)
    }
    

}

struct SettingsView: View {
    @Binding var minimumMultiplication: Int
    @Binding var maximumMultiplication: Int
    
    @Binding var questionCountSelection: String
    @Binding var questionCount: [String]
    
    var body: some View {
        Group {
            // Minimum and maximum multiplication tables
            Section {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .shadow(radius: 5)

                    VStack {
                        Stepper("From \(minimumMultiplication)", value: $minimumMultiplication, in: 1...20)
                            .onChange(of: minimumMultiplication) { _ in
                                if minimumMultiplication >= maximumMultiplication { minimumMultiplication -= 1 }
                            }
                        Stepper("To \(maximumMultiplication)", value: $maximumMultiplication, in: 1...20)
                            .onChange(of: maximumMultiplication) { _ in
                                if minimumMultiplication >= maximumMultiplication { maximumMultiplication += 1 }
                            }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 10)
                    .padding(.all, 10)
                }
                .fixedSize(horizontal: false, vertical: true)
            } header: {
                Text("Multiplication tables")
                    .font(.headline)
            }
            .padding(.horizontal)

            // Number of questions per round
                Section {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .shadow(radius: 5)
                        
                        Picker("Number of questions", selection: $questionCountSelection) {
                            ForEach(questionCount, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(10)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                } header: {
                    Text("Number of questions")
                        .font(.headline)
                }
        }
    }
}

struct QuestionsView: View {

    @State private var mistakes = 0
    
    @FocusState var isInputActive: Bool
    
    @Binding var questionCountSelection: String
    @Binding var maximumMultiplication: Int
    @Binding var minimumMultiplication: Int
    @Binding var showingAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    @Binding var questions: [String]
    @Binding var currentQuestion: String
    @Binding var currentQuestionLocation: Int
    @Binding var answer: Int?
    @Binding var gameStarted: Bool
    @Binding var isVerified: Bool
    @Binding var isCorrect: Bool


    var body: some View {
        VStack {
            Spacer()
            Text(currentQuestion == "" ? "Press Start to start" : currentQuestion)
                .font(.title.bold())
                .onChange(of: currentQuestion) { _ in
                    print("text: \(currentQuestion)")
                }
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(isVerified ? (isCorrect ? .green : .red) : .white)
                    .animation(.default, value: isVerified)
                    .animation(.default, value: isCorrect)
                    .shadow(radius: 5)

                
                TextField("Enter your answer", value: $answer, format: .number)
                    .keyboardType(.numberPad)
                    .focused($isInputActive)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()

                            Button("Done") {
                                isInputActive = false
                            }
                            .foregroundColor(.none)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.horizontal)
                    .foregroundColor(.black)
            }
            .fixedSize(horizontal: true, vertical: true)
            
            Spacer()
            // Button will display and execute Continue if the game started and is verified, Verify if not and start otherwise.
            Button(gameStarted ? (isVerified && isCorrect ? "Continue" : "Verify") : "Start", action: gameStarted ? continueGame : startGame)
                .frame(minWidth: 0, maxWidth: .infinity)
                .font(.system(size: 18))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white, lineWidth: 2)
                )
                .padding()
                .shadow(radius: 5)

        }
        .padding(.horizontal)
    }
    
    func startGame() {
        questions.removeAll()
        gameStarted = true
        
        // Repeats for number of questions
        for _ in 0..<(Int(questionCountSelection) ?? 5) {
            // question is the question generator
            let question = "\(Int.random(in: minimumMultiplication...maximumMultiplication)) * \(Int.random(in: 1...12))"
            questions.append(question)
            
            currentQuestion = questions[currentQuestionLocation]
        }
    }
    
    func showResults() {
        alertTitle = "You won!"
        alertMessage = "You answered \(questionCountSelection) questions correctly and got \(mistakes) mistakes."
        showingAlert = true
    }
    
    func verifyAnswer() -> Bool {
        let expression = NSExpression(format: currentQuestion)
        let value = expression.expressionValue(with: nil, context: nil) as? Int
        
        // Display an alert if incorrect
        if (answer ?? 0) != value {

            return false
        }
        return true
    }
    
    func continueGame() {
        // Checks if the game started
        if !gameStarted {
            alertTitle = "Game not started"
            alertMessage = "Press the start button at the top right to start the game!"
            showingAlert = true
            answer = nil
            return
        }
        
        // Checks if answer has been verified
        if isVerified {
            if !isCorrect {
                isVerified = false
                return
            }
            currentQuestionLocation += 1

            // Checks if this is the last question
            if currentQuestion == (questions.last) {
                showResults()
                resetGame()
                return
            }
            currentQuestion = questions[currentQuestionLocation]
            answer = nil
            isVerified = false
            isCorrect = false
            return
        }
        isCorrect = verifyAnswer()
        
        // Checks if answer is correct
        if isCorrect {
            isVerified = true
        } else {
            // If the answer is wrong, add a mistake.
            mistakes += 1
            isVerified = true
        }
    }
    
    func resetGame() {
        questions.removeAll()
        mistakes = 0
        answer = nil
        currentQuestion = ""
        currentQuestionLocation = 0
        gameStarted = false
        isVerified = false
        isCorrect = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
