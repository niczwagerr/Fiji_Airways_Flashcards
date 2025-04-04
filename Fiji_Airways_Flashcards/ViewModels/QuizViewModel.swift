import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {
    // Question management
    @Published var currentQuestionIndex: Int = 0
    @Published var questions: [Question] = []
    @Published var selectedSubject: String? = nil
    @Published var questionCount: Int = 10
    @Published var isQuizActive: Bool = false
    @Published var showingResults: Bool = false
    
    // Answer tracking
    @Published var selectedAnswer: String? = nil
    @Published var userTextAnswer: String = ""
    @Published var hasAnswered: Bool = false
    @Published var isCorrect: Bool = false
    @Published var shuffledAnswers: [String] = []
    
    // Stats
    @Published var correctAnswers: Int = 0
    @Published var reviewQuality: ReviewQuality? = nil
    @Published var showingReviewOptions: Bool = false
    @Published var reviewCompleted: Bool = false
    
    private let questionService = QuestionService.shared
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentQuestionIndex) / CGFloat(questions.count)
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    // MARK: - Setup Methods
    
    func loadSubjects() -> [String] {
        return questionService.getSubjects()
    }
    
    func startQuiz(withSpacedRepetition: Bool = false) {
        if withSpacedRepetition {
            questions = questionService.getDueQuestions(maxCount: questionCount, forSubject: selectedSubject)
        } else {
            questions = questionService.getRandomQuestions(count: questionCount, fromSubject: selectedSubject)
        }
        
        resetQuizState()
        
        if !questions.isEmpty {
            isQuizActive = true
            setupCurrentQuestion()
        }
    }
    
    private func resetQuizState() {
        currentQuestionIndex = 0
        correctAnswers = 0
        hasAnswered = false
        selectedAnswer = nil
        userTextAnswer = ""
        isCorrect = false
        showingResults = false
        showingReviewOptions = false
        reviewCompleted = false
    }
    
    private func setupCurrentQuestion() {
        guard let question = currentQuestion else { return }
        
        hasAnswered = false
        selectedAnswer = nil
        userTextAnswer = ""
        reviewQuality = nil
        showingReviewOptions = false
        reviewCompleted = false
        
        if question.multi_choice {
            // Shuffle answers for multiple choice
            shuffledAnswers = question.allAnswers.shuffled()
        }
    }
    
    // MARK: - Answer Methods
    
    func submitMultipleChoiceAnswer(_ answer: String) {
        guard !hasAnswered, let question = currentQuestion else { return }
        
        selectedAnswer = answer
        hasAnswered = true
        isCorrect = answer == question.answer
        
        if isCorrect {
            correctAnswers += 1
        }
        
        // Show review options after answering
        showingReviewOptions = true
        reviewCompleted = false
    }
    
    func submitTextAnswer() {
        guard !hasAnswered, let question = currentQuestion else { return }
        
        hasAnswered = true
        
        // Case-insensitive comparison
        isCorrect = userTextAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == 
                   question.answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isCorrect {
            correctAnswers += 1
        }
        
        // Show review options after answering
        showingReviewOptions = true
        reviewCompleted = false
    }
    
    func submitReviewQuality(_ quality: ReviewQuality) {
        guard let question = currentQuestion else { return }
        
        // Update spaced repetition data
        questionService.updateReviewData(forQuestion: question.id, withQuality: quality.rawValue)
        
        // Reset review state
        reviewQuality = quality
        showingReviewOptions = false
        reviewCompleted = true
    }
    
    // MARK: - Navigation Methods
    
    func nextQuestion() {
        if isLastQuestion {
            showingResults = true
        } else {
            currentQuestionIndex += 1
            setupCurrentQuestion()
        }
    }
    
    func restartQuiz() {
        resetQuizState()
        if !questions.isEmpty {
            setupCurrentQuestion()
        } else {
            isQuizActive = false
        }
    }
} 