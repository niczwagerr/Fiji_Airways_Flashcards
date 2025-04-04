import Foundation

class QuestionService {
    static let shared = QuestionService()
    
    private init() {}
    
    // Load questions from the JSON file
    func loadQuestions() -> [Question] {
        guard let url = Bundle.main.url(forResource: "A350_Questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load questions file")
            return []
        }
        
        do {
            let questions = try JSONDecoder().decode([Question].self, from: data)
            return questions
        } catch {
            print("Failed to decode questions: \(error)")
            return []
        }
    }
    
    // Get unique subjects from all questions
    func getSubjects() -> [String] {
        let questions = loadQuestions()
        let subjects = Set(questions.map { $0.subjects })
        return Array(subjects).sorted()
    }
    
    // Filter questions by subject
    func getQuestions(forSubject subject: String?) -> [Question] {
        let questions = loadQuestions()
        guard let subject = subject else {
            return questions
        }
        return questions.filter { $0.subjects == subject }
    }
    
    // Get a random subset of questions
    func getRandomQuestions(count: Int, fromSubject subject: String? = nil) -> [Question] {
        let filteredQuestions = getQuestions(forSubject: subject)
        guard !filteredQuestions.isEmpty else { return [] }
        
        let shuffled = filteredQuestions.shuffled()
        let questionCount = min(count, filteredQuestions.count)
        return Array(shuffled.prefix(questionCount))
    }
}

// MARK: - Review Data Management
extension QuestionService {
    private var reviewDataKey: String { "com.fijiairways.flashcards.reviewData" }
    
    // Save review data to UserDefaults
    func saveReviewData(_ reviewData: [String: ReviewData]) {
        do {
            let data = try JSONEncoder().encode(reviewData)
            UserDefaults.standard.set(data, forKey: reviewDataKey)
        } catch {
            print("Failed to save review data: \(error)")
        }
    }
    
    // Load review data from UserDefaults
    func loadReviewData() -> [String: ReviewData] {
        guard let data = UserDefaults.standard.data(forKey: reviewDataKey) else {
            return [:]
        }
        
        do {
            let reviewData = try JSONDecoder().decode([String: ReviewData].self, from: data)
            return reviewData
        } catch {
            print("Failed to load review data: \(error)")
            return [:]
        }
    }
    
    // Update review data for a question
    func updateReviewData(forQuestion questionId: String, withQuality quality: Int) {
        var reviewData = loadReviewData()
        
        if var questionReviewData = reviewData[questionId] {
            questionReviewData.updateReviewData(quality: quality)
            reviewData[questionId] = questionReviewData
        } else {
            var newReviewData = ReviewData(questionId: questionId)
            newReviewData.updateReviewData(quality: quality)
            reviewData[questionId] = newReviewData
        }
        
        saveReviewData(reviewData)
    }
    
    // Get due questions for review
    func getDueQuestions(maxCount: Int = Int.max, forSubject subject: String? = nil) -> [Question] {
        let allQuestions = getQuestions(forSubject: subject)
        let reviewData = loadReviewData()
        
        var dueQuestions: [Question] = []
        
        // Questions that have been reviewed and are due
        for question in allQuestions {
            if let data = reviewData[question.id], data.isDue() {
                dueQuestions.append(question)
            }
        }
        
        // Questions that have never been reviewed
        let reviewedQuestionIds = Set(reviewData.keys)
        let unreviewedQuestions = allQuestions.filter { !reviewedQuestionIds.contains($0.id) }
        
        dueQuestions.append(contentsOf: unreviewedQuestions)
        
        // Shuffle and limit the count
        return Array(dueQuestions.shuffled().prefix(maxCount))
    }
} 