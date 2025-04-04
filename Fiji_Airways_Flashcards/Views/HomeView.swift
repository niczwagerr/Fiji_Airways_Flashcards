import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showingSubjectPicker = false
    @State private var useSpacedRepetition = true
    
    private let questionCounts = [5, 10, 20, 30, 50]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "0066B3"), Color(hex: "004C86")]), 
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo and title
                    VStack(spacing: 16) {
                        Image(systemName: "airplane.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 90)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        Text("Fiji Airways")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("A350 Knowledge Quiz")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 40)
                    
                    // Settings card
                    VStack(alignment: .leading, spacing: 22) {
                        Text("Quiz Settings")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "333333"))
                            .padding(.bottom, 5)
                        
                        // Subject selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Subject")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "555555"))
                            
                            Button(action: {
                                showingSubjectPicker = true
                            }) {
                                HStack {
                                    Text(viewModel.selectedSubject ?? "All Subjects")
                                        .foregroundColor(Color(hex: "333333"))
                                        .font(.system(size: 17))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "0066B3"))
                                }
                                .padding()
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        }
                        
                        // Question count
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Number of Questions")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "555555"))
                            
                            Picker("", selection: $viewModel.questionCount) {
                                ForEach(questionCounts, id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Spaced repetition toggle
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Spaced Repetition")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "555555"))
                                
                                Button(action: {
                                    // Show a tooltip or explanation
                                }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "0066B3"))
                                }
                            }
                            
                            Toggle("", isOn: $useSpacedRepetition)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "0066B3")))
                                .padding(.trailing)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Start button
                    Button(action: {
                        viewModel.startQuiz(withSpacedRepetition: useSpacedRepetition)
                    }) {
                        Text("Start Quiz")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "00A575"), Color(hex: "008561")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "00A575").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSubjectPicker) {
                SubjectPickerView(selectedSubject: $viewModel.selectedSubject)
            }
            .fullScreenCover(isPresented: $viewModel.isQuizActive) {
                QuizView(viewModel: viewModel)
            }
        }
    }
}

struct SubjectPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedSubject: String?
    
    let subjects: [String]
    
    init(selectedSubject: Binding<String?>) {
        self._selectedSubject = selectedSubject
        self.subjects = QuestionService.shared.getSubjects()
    }
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    selectedSubject = nil
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text("All Subjects")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedSubject == nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "0066B3"))
                                .font(.system(size: 16))
                        }
                    }
                    .contentShape(Rectangle())
                    .frame(height: 44)
                }
                
                ForEach(subjects, id: \.self) { subject in
                    Button(action: {
                        selectedSubject = subject
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(subject)
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedSubject == subject {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "0066B3"))
                                    .font(.system(size: 16))
                            }
                        }
                        .contentShape(Rectangle())
                        .frame(height: 44)
                    }
                }
            }
            .navigationTitle("Select Subject")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(Color(hex: "0066B3")))
        }
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    HomeView()
} 