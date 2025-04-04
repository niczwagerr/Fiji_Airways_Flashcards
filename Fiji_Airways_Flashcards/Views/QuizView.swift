import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F6F8FA")
                    .ignoresSafeArea()
                
                if viewModel.showingResults {
                    ResultsView(viewModel: viewModel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } else if let question = viewModel.currentQuestion {
                    VStack(spacing: 0) {
                        // Header with progress and back button - Always visible at top
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                // Back button moved to the header
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Back")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(Color(hex: "0066B3"))
                                }
                                
                                Spacer()
                                
                                Text("\(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(hex: "555555"))
                            }
                            
                            // Progress bar
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 6)
                                    .foregroundColor(Color(hex: "E5E5E5"))
                                    .cornerRadius(3)
                                
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width * viewModel.progress, height: 6)
                                    .foregroundColor(Color(hex: "0066B3"))
                                    .cornerRadius(3)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                        .background(Color.white)
                        .zIndex(1)
                        
                        // Main Content Area
                        ZStack(alignment: .bottom) {
                            // Scrollable content area
                            ScrollView {
                                VStack(spacing: 24) {
                                    // Question text - Always visible
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Question")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "555555"))
                                        
                                        Text(question.question)
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(Color(hex: "333333"))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(.bottom, 10)
                                        
                                        // Subject tag moved below question
                                        HStack(spacing: 6) {
                                            Image(systemName: "tag.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "0066B3").opacity(0.7))
                                            
                                            Text(question.subjects)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(Color(hex: "555555").opacity(0.8))
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(24)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 16)
                                    
                                    // Answer area
                                    if viewModel.hasAnswered {
                                        // Show answer results
                                        answerResultView(for: question)
                                    } else {
                                        // Show answer input
                                        VStack(alignment: .leading, spacing: 16) {
                                            Text(question.multi_choice ? "Choose the correct answer" : "Enter your answer")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(hex: "555555"))
                                                .padding(.horizontal, 24)
                                            
                                            VStack {
                                                if question.multi_choice {
                                                    multipleChoiceView(for: question)
                                                } else {
                                                    writtenAnswerInputView(for: question)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Add padding at bottom to ensure content is scrollable above the review quality section
                                    if viewModel.hasAnswered && viewModel.showingReviewOptions {
                                        Spacer()
                                            .frame(height: 220) // Approximate height of review quality section
                                    }
                                    
                                    // Navigation buttons
                                    if viewModel.hasAnswered && viewModel.reviewCompleted {
                                        navigationButtons()
                                            .transition(.opacity)
                                            .animation(.easeInOut, value: viewModel.reviewCompleted)
                                            .padding(.bottom, 30)
                                    }
                                }
                                .padding(.bottom, 40)
                            }
                            
                            // Fixed review quality section at bottom when needed
                            if viewModel.hasAnswered && viewModel.showingReviewOptions {
                                VStack(spacing: 0) {
                                    Divider()
                                        .padding(.bottom, 16)
                                    
                                    reviewQualityView()
                                        .padding(.bottom, 24)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                .background(Color.white)
                                .cornerRadius(20, corners: [.topLeft, .topRight])
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                                .transition(.move(edge: .bottom))
                                .animation(.easeInOut, value: viewModel.showingReviewOptions)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "0066B3").opacity(0.7))
                        
                        Text("No questions available")
                            .font(.title)
                            .foregroundColor(Color(hex: "555555"))
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Answer Result View
    private func answerResultView(for question: Question) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Heading
            Text("Answer")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "555555"))
                .padding(.horizontal, 24)
            
            // Result card
            VStack(alignment: .leading, spacing: 16) {
                // User's answer
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your answer:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "555555"))
                    
                    HStack {
                        if question.multi_choice {
                            Text(viewModel.selectedAnswer ?? "")
                                .font(.system(size: 17))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(viewModel.isCorrect ? Color(hex: "E7F7EF") : Color(hex: "FEE7EA"))
                                .cornerRadius(12)
                        } else {
                            Text(viewModel.userTextAnswer)
                                .font(.system(size: 17))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(viewModel.isCorrect ? Color(hex: "E7F7EF") : Color(hex: "FEE7EA"))
                                .cornerRadius(12)
                        }
                        
                        if viewModel.isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "00A575"))
                                .font(.system(size: 20))
                                .padding(.trailing, 12)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "E02D3C"))
                                .font(.system(size: 20))
                                .padding(.trailing, 12)
                        }
                    }
                }
                
                // Show correct answer if user got it wrong
                if !viewModel.isCorrect {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Correct answer:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "555555"))
                        
                        Text(question.answer)
                            .font(.system(size: 17))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "E7F7EF"))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.hasAnswered)
    }
    
    // MARK: - Multiple Choice View
    private func multipleChoiceView(for question: Question) -> some View {
        VStack(spacing: 12) {
            ForEach(viewModel.shuffledAnswers, id: \.self) { answer in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.submitMultipleChoiceAnswer(answer)
                    }
                }) {
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(answerBorderColor(for: answer), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            if viewModel.hasAnswered {
                                if answer == question.answer {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(answerIconBackgroundColor(for: answer))
                                        .clipShape(Circle())
                                } else if answer == viewModel.selectedAnswer {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(answerIconBackgroundColor(for: answer))
                                        .clipShape(Circle())
                                }
                            } else if viewModel.selectedAnswer == answer {
                                Circle()
                                    .fill(Color(hex: "0066B3"))
                                    .frame(width: 12, height: 12)
                            }
                        }
                        .frame(width: 24, height: 24)
                        .padding(.top, 2)
                        
                        Text(answer)
                            .font(.system(size: 17))
                            .foregroundColor(answerTextColor(for: answer))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(answerBackgroundColor(for: answer))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(answerBorderColor(for: answer), lineWidth: viewModel.selectedAnswer == answer && !viewModel.hasAnswered ? 2 : 0)
                    )
                    .shadow(color: Color.black.opacity(viewModel.hasAnswered ? 0 : 0.05), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(viewModel.hasAnswered)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Written Answer Input View
    private func writtenAnswerInputView(for question: Question) -> some View {
        VStack(spacing: 20) {
            TextField("Type your answer", text: $viewModel.userTextAnswer)
                .font(.system(size: 17))
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "0066B3").opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            Button(action: {
                withAnimation {
                    viewModel.submitTextAnswer()
                }
            }) {
                Text("Submit Answer")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        viewModel.userTextAnswer.isEmpty ? 
                            Color(hex: "0066B3").opacity(0.4) : 
                            Color(hex: "0066B3")
                    )
                    .cornerRadius(12)
                    .shadow(color: Color(hex: "0066B3").opacity(0.2), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 24)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(viewModel.userTextAnswer.isEmpty)
        }
    }
    
    // MARK: - Review Quality View
    private func reviewQualityView() -> some View {
        VStack(spacing: 20) {
            Text("How well did you know this?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "333333"))
            
            // Replace HStack with GeometryReader to ensure even spacing
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(ReviewQuality.allCases) { quality in
                        Button(action: {
                            withAnimation {
                                viewModel.submitReviewQuality(quality)
                            }
                        }) {
                            let color: Color = switch quality {
                            case .againHard: Color(hex: "E02D3C")
                            case .hard: Color(hex: "FF9500")
                            case .good: Color(hex: "0066B3")
                            case .easy: Color(hex: "00A575")
                            }
                            
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(color.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle()
                                            .stroke(color, lineWidth: 2)
                                    )
                                    .overlay(
                                        Image(systemName: qualityIcon(for: quality))
                                            .font(.system(size: 24))
                                            .foregroundColor(color)
                                    )
                                
                                Text(quality.description)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "333333"))
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .frame(width: geometry.size.width / CGFloat(ReviewQuality.allCases.count))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
            .frame(height: 110)
        }
    }
    
    private func qualityIcon(for quality: ReviewQuality) -> String {
        switch quality {
        case .againHard: return "exclamationmark.triangle"
        case .hard: return "minus.circle"
        case .good: return "hand.thumbsup"
        case .easy: return "star"
        }
    }
    
    // MARK: - Navigation Buttons
    private func navigationButtons() -> some View {
        Button(action: {
            withAnimation {
                viewModel.nextQuestion()
            }
        }) {
            Text(viewModel.isLastQuestion ? "Finish Quiz" : "Next Question")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "0066B3"), Color(hex: "004C86")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color(hex: "0066B3").opacity(0.3), radius: 6, x: 0, y: 4)
                .padding(.horizontal, 24)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Helper Methods
    private func answerBackgroundColor(for answer: String) -> Color {
        guard viewModel.hasAnswered else { 
            return viewModel.selectedAnswer == answer ? Color(hex: "0066B3").opacity(0.05) : Color.white 
        }
        
        if answer == viewModel.currentQuestion?.answer {
            return Color(hex: "E7F7EF")
        } else if answer == viewModel.selectedAnswer {
            return Color(hex: "FEE7EA")
        }
        
        return Color.white
    }
    
    private func answerTextColor(for answer: String) -> Color {
        if !viewModel.hasAnswered {
            return Color(hex: "333333")
        }
        
        if answer == viewModel.currentQuestion?.answer {
            return Color(hex: "00A575")
        } else if answer == viewModel.selectedAnswer && !viewModel.isCorrect {
            return Color(hex: "E02D3C")
        }
        
        return Color(hex: "333333")
    }
    
    private func answerBorderColor(for answer: String) -> Color {
        if viewModel.hasAnswered {
            if answer == viewModel.currentQuestion?.answer {
                return Color(hex: "00A575")
            } else if answer == viewModel.selectedAnswer {
                return Color(hex: "E02D3C")
            }
            return .clear
        }
        
        return viewModel.selectedAnswer == answer ? Color(hex: "0066B3") : Color(hex: "E5E5E5")
    }
    
    private func answerIconBackgroundColor(for answer: String) -> Color {
        if answer == viewModel.currentQuestion?.answer {
            return Color(hex: "00A575")
        } else if answer == viewModel.selectedAnswer {
            return Color(hex: "E02D3C")
        }
        return .clear
    }
}

// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ResultsView: View {
    @ObservedObject var viewModel: QuizViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E7F7EF"))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(hex: "00A575"))
                }
                
                Text("Quiz Completed!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "333333"))
            }
            
            VStack(spacing: 24) {
                // Score circle
                ZStack {
                    Circle()
                        .stroke(Color(hex: "E5E5E5"), lineWidth: 10)
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.correctAnswers) / CGFloat(viewModel.questions.count))
                        .stroke(
                            scoreColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text("\(viewModel.correctAnswers)/\(viewModel.questions.count)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "333333"))
                        
                        Text("\(scorePercentage)%")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "555555"))
                    }
                }
                
                // Performance text
                Text(performanceMessage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "555555"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                Button(action: {
                    viewModel.restartQuiz()
                }) {
                    Text("Review Again")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "0066B3"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "0066B3"), lineWidth: 2)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: onDismiss) {
                    Text("Back to Home")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "0066B3"), Color(hex: "004C86")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "0066B3").opacity(0.3), radius: 6, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.top, 40)
    }
    
    private var scorePercentage: Int {
        Int((Double(viewModel.correctAnswers) / Double(viewModel.questions.count)) * 100)
    }
    
    private var scoreColor: Color {
        if scorePercentage >= 80 {
            return Color(hex: "00A575")
        } else if scorePercentage >= 60 {
            return Color(hex: "0066B3")
        } else if scorePercentage >= 40 {
            return Color(hex: "FF9500")
        } else {
            return Color(hex: "E02D3C")
        }
    }
    
    private var performanceMessage: String {
        if scorePercentage >= 90 {
            return "Excellent! You've mastered these questions."
        } else if scorePercentage >= 70 {
            return "Great job! You're doing well."
        } else if scorePercentage >= 50 {
            return "Good effort! Keep practicing to improve."
        } else {
            return "You'll do better next time. Keep studying!"
        }
    }
}

// Custom button style with subtle feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    QuizView(viewModel: {
        let vm = QuizViewModel()
        vm.questions = [
            Question(subjects: "AIR CONDITIONING", multi_choice: true, question: "All pack valves of both packs are automatically closed", answer: "When Ditching P/B is set to ON, or during any engine start and the cross bleed valve is open, or the FIRE pb-sw of any engine is pressed, and the crossbleed valve is opened.", wrong_answers: ["When the ditching P/B switch is set to ON or during engine start and all doors closed except L1 door", "During engine start and on the ground, they will remain closed for 2 minutes", "-"])
        ]
        return vm
    }())
} 