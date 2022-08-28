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
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var questionCountSelection = "5"
    @State private var questionCount = ["5", "10", "15", "20"]
    
    var body: some View {
        NavigationView {
            List {
                SettingsView(minimumMultiplication: $minimumMultiplication, maximumMultiplication: $maximumMultiplication, questionCountSelection: $questionCountSelection, questionCount: $questionCount)
                
                QuestionsView(questionCountSelection: $questionCountSelection, maximumMultiplication: $maximumMultiplication, minimumMultiplication: $minimumMultiplication, showingAlert: $showingAlert, alertTitle: $alertTitle, alertMessage: $alertMessage, questions: $questions, currentQuestion: $currentQuestion, currentQuestionLocation: $currentQuestionLocation, answer: $answer, gameStarted: $gameStarted)
            }
            .navigationTitle("Multitainment")
            .listStyle(.grouped)
            .toolbar {
                Button("Start", action: startGame)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}

            } message: {
                Text(alertMessage)
            }
        }
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
}

struct SettingsView: View {
    @Binding var minimumMultiplication: Int
    @Binding var maximumMultiplication: Int
    
    @Binding var questionCountSelection: String
    @Binding var questionCount: [String]
    
    var body: some View {
        // Minimum and maximum multiplication tables
        Section {
            Stepper("From \(minimumMultiplication)", value: $minimumMultiplication, in: 1...20)
                .onChange(of: minimumMultiplication) { _ in
                    if minimumMultiplication >= maximumMultiplication { minimumMultiplication -= 1 }
                }
            Stepper("To \(maximumMultiplication)", value: $maximumMultiplication, in: 1...20)
                .onChange(of: maximumMultiplication) { _ in
                    if minimumMultiplication >= maximumMultiplication { maximumMultiplication += 1 }
                }
        } header: {
            Text("Multiplication tables")
        }
        // Number of questions per round
        Section {
            Picker("Number of questions", selection: $questionCountSelection) {
                ForEach(questionCount, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Number of questions")
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


    var body: some View {
        Section {
            Text(currentQuestion)
                .font(.headline)
                .onChange(of: currentQuestion) { _ in
                    print("text: \(currentQuestion)")
                }
            TextField("Enter your answer", value: $answer, format: .number)
                .keyboardType(.numberPad)
                .focused($isInputActive)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()

                        Button("Done") {
                            isInputActive = false
                            continueGame()
                        }
                    }
                }
        }
    }
    
    func showResults() {
        alertTitle = "You won!"
        alertMessage = "You answered \(questionCountSelection) questions correctly and got \(mistakes) mistakes."
        showingAlert = true
    }
    
    func isCorrect() -> Bool {
        let expression = NSExpression(format: currentQuestion)
        let value = expression.expressionValue(with: nil, context: nil) as? Int
        
        // Display an alert if incorrect
        if (answer ?? 0) != value {
            alertTitle = "Incorrect"
            alertMessage = "Try again!"
            showingAlert = true
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
        
        // Checks if answer is correct
        if isCorrect() {
            currentQuestionLocation += 1

            // Checks if this is the last question
            if currentQuestion == (questions.last) {
                showResults()
                resetGame()
                return
            }
            currentQuestion = questions[currentQuestionLocation]
        } else {
            // If the answer is wrong, add a mistake and exit.
            mistakes += 1
            return
        
        }
        answer = nil
    }
    
    func resetGame() {
        questions.removeAll()
        mistakes = 0
        answer = nil
        currentQuestion = ""
        currentQuestionLocation = 0
        gameStarted = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
