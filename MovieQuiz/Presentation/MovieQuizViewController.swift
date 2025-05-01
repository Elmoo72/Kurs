import UIKit
// MARK: - Lifecycle
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var quizeLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    private var statisticService: StatisticServiceProtocol!
    private var alertPresenter: AlertPresenter?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
            
            statisticService = StatisticService()
            alertPresenter = AlertPresenter(viewController: self)
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            
            showLoadingIndicator()
            questionFactory?.loadData()
            
            let customFont = UIFont(name: "YS Display Medium", size: 20)
            
            textLabel.font = UIFont(name: "YS Display Bold", size: 23)
            counterLabel.font = UIFont(name: "YS Display Medium", size: 20)
            quizeLabel.font = UIFont(name: "YS Display Medium", size: 20)
            yesButton.titleLabel?.font = customFont
            noButton.titleLabel?.font = customFont
        
        
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory?.requestNextQuestion()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        print(givenAnswer)
        print(correctAnswers)
        
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(with: model)
    }
        // MARK: - QuestionFactoryDelegate
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
            }
        }
        func didLoadDataFromServer() {
            activityIndicator.isHidden = true
            questionFactory?.requestNextQuestion()
        }
        
        func didFailToLoadData(with error: Error){
            hideLoadingIndicator()
            showNetworkError(message: error.localizedDescription)
        }
        
        private func hideLoadingIndicator() {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    
        // MARK: - Private functions
        private func showNextQuestionOrResults() {
            if currentQuestionIndex == questionsAmount - 1 {
                
                let result = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: "",
                    buttonText: "Сыграть ещё раз"
                )
                
                
                show(quiz: result)
                
            } else {
                currentQuestionIndex += 1
                questionFactory?.requestNextQuestion()
            }
        }
        
        private func resetGame() {
            
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
        
        private func convert(model: QuizQuestion) -> QuizStepViewModel {
            return QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
            )
        }
        
        private func show(quiz step: QuizStepViewModel) {
            imageView.layer.borderWidth = 0
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        }
        
        private func showAnswerResult(isCorrect: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor(named: "ypGreen")?.cgColor : UIColor(named: "ypRed")?.cgColor
        }
        
        private func show(quiz result: QuizResultsViewModel) {
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yy HH:mm"
            let formattedDate = formatter.string(from: statisticService.bestGame.date)
            
            
            let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(formattedDate))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
            
            
            let alertModel = AlertModel(
                title: result.title,
                message: message,
                buttonText: result.buttonText,
                completion: { [weak self] in
                    self?.resetGame()
                }
            )
            
            
            alertPresenter?.showAlert(with: alertModel)
        }
    }


