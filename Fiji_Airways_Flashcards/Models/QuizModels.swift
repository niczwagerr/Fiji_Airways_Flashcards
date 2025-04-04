import Foundation

// Model to match the JSON structure
struct Question: Identifiable, Codable {
    let subjects: String
    let multi_choice: Bool
    let question: String
    let answer: String
    let wrong_answers: [String]
    
    // Computed property to generate a unique ID for each question
    var id: String {
        return question
    }
    
    // Computed property to get all answers (correct + wrong) for multiple choice
    var allAnswers: [String] {
        var answers = [answer]
        answers.append(contentsOf: wrong_answers.filter { $0 != "-" })
        return answers
    }
}

// Model to track review history for spaced repetition
struct ReviewData: Codable {
    let questionId: String
    var lastReviewed: Date
    var interval: Int // Days until next review
    var easeFactor: Double // SM-2 algorithm ease factor
    var reviewCount: Int
    
    init(questionId: String) {
        self.questionId = questionId
        self.lastReviewed = Date()
        self.interval = 1
        self.easeFactor = 2.5 // Default ease factor in SM-2
        self.reviewCount = 0
    }
    
    // SM-2 algorithm implementation
    mutating func updateReviewData(quality: Int) {
        reviewCount += 1
        
        // Calculate new ease factor (minimum 1.3)
        easeFactor = max(1.3, easeFactor + (0.1 - (5 - Double(quality)) * (0.08 + (5 - Double(quality)) * 0.02)))
        
        // Calculate new interval
        if reviewCount == 1 {
            interval = 1
        } else if reviewCount == 2 {
            interval = 6
        } else {
            interval = Int(Double(interval) * easeFactor)
        }
        
        lastReviewed = Date()
    }
    
    // Check if question is due for review
    func isDue() -> Bool {
        let calendar = Calendar.current
        let nextReviewDate = calendar.date(byAdding: .day, value: interval, to: lastReviewed)!
        return Date() >= nextReviewDate
    }
}

// Enum for quality ratings in spaced repetition
enum ReviewQuality: Int, CaseIterable, Identifiable {
    case againHard = 0
    case hard = 1
    case good = 3
    case easy = 5
    
    var id: Int { self.rawValue }
    
    var description: String {
        switch self {
        case .againHard: return "Very Hard"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }
} 