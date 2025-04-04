# Fiji Airways Flashcards

A SwiftUI-based aviation knowledge quiz app specifically designed for Fiji Airways pilots, featuring spaced repetition learning for A350 systems knowledge.

## Features

- **Multiple Choice & Written Answer Questions**: Supports both question types for comprehensive learning
- **Spaced Repetition Learning**: Implements the SM-2 algorithm for optimized review scheduling
- **Subject Filtering**: Focus on specific aircraft systems (Air Conditioning, Hydraulics, etc.)
- **Customizable Sessions**: Choose the number of questions per review session
- **Performance Tracking**: Track your progress with review statistics

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of UI and business logic
- **UserDefaults**: Persistent storage for review data

### Key Components
- **QuestionService**: Manages loading and filtering of questions
- **QuizViewModel**: Controls quiz flow and user interaction logic
- **Spaced Repetition**: Implementation of the SM-2 algorithm

## Getting Started

1. Clone the repository
2. Open the project in Xcode 15+ 
3. Build and run on iOS 16.0+ device or simulator

## JSON Question Format

```json
{
  "subjects": "AIR CONDITIONING",
  "multi_choice": true,
  "question": "All pack valves of both packs are automatically closed",
  "answer": "When Ditching P/B is set to ON, or during any engine start and the cross bleed valve is open...",
  "wrong_answers": [
    "When the ditching P/B switch is set to ON or during engine start and all doors closed except L1 door",
    "During engine start and on the ground, they will remain closed for 2 minutes",
    "-"
  ]
}
```

## License

Fiji Airways proprietary software. All rights reserved.

## Credits

Developed for Fiji Airways by [Your Name] 