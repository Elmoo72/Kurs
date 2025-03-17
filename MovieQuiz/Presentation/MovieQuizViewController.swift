import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var quizeLabel: UILabel!
   
    @IBOutlet private var imageView: UIImageView!
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex] // 1
        let givenAnswer = true// 2
        print(givenAnswer) //  проверка
        print(correctAnswers)
        
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // 3
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Задержка 1 секунда
                self.showNextQuestionOrResults()
            }
        }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex] // 1
        let givenAnswer = false // 2
        
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // 3
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showNextQuestionOrResults()
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customFont = UIFont(name: "YS Display Medium", size: 20)
        
        textLabel.font = UIFont(name: "YS Display Bold", size: 23)
        counterLabel.font = UIFont(name: "YS Display Medium", size: 20)
        quizeLabel.font = UIFont(name: "YS Display Medium", size: 20)
        yesButton.titleLabel?.font = customFont
        noButton.titleLabel?.font = customFont
        DispatchQueue.main.async {
               let firstQuestion = self.questions[self.currentQuestionIndex]
               let viewModel = self.convert(model: firstQuestion)
               self.show(quiz: viewModel)
           }
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0

    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    struct QuizQuestion{
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    private func show(quiz step: QuizStepViewModel) { //обновление интерфейса для нового вопроса
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        
        counterLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8 // 2
        imageView.layer.borderColor = isCorrect ? UIColor(named: "ypGreen")?.cgColor : UIColor(named: "ypRed")?.cgColor
    }

    private func show(quiz result: QuizResultsViewModel) {   // финальный результат
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResults() {                      //логика перехода
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10" // 1
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel) // 3
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {   // конвертатор
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)") // 4
        return questionStep
    }
    
    
}
