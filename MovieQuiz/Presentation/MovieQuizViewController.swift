import UIKit
// MARK: - Lifecycle
final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var quizeLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    private var presenter: MovieQuizPresenter!
    private var statisticService: StatisticServiceProtocol!
    private var alertPresenter: AlertPresenter?
    // private var correctAnswers = 0
    //private var questionFactory: QuestionFactory?
    //private var currentQuestion: QuizQuestion?
    
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        presenter = MovieQuizPresenter(viewController: self)
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(viewController: self)
        //questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        //showLoadingIndicator()
        //questionFactory?.loadData()
        
        let customFont = UIFont(name: "YS Display Medium", size: 20)
        
        textLabel.font = UIFont(name: "YS Display Bold", size: 23)
        counterLabel.font = UIFont(name: "YS Display Medium", size: 20)
        quizeLabel.font = UIFont(name: "YS Display Medium", size: 20)
        yesButton.titleLabel?.font = customFont
        noButton.titleLabel?.font = customFont
        
        
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        //questionFactory?.requestNextQuestion()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
//            self.presenter.resetQuestionIndex()
            self.presenter.restartGame()
            
           // self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(with: model)
    }
    // MARK: - QuestionFactoryDelegate
   
    
    func hideLoadingIndicator() {
           activityIndicator.isHidden = true
       }
    
    // MARK: - Private functions
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            
//            let result = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: "",
//                buttonText: "Сыграть ещё раз"
//            )
//            
//            
//            show(quiz: result)
//            
//        } else {
//            presenter.switchToNextQuestion()
//            //questionFactory?.requestNextQuestion()
//        }
//    }
    
//    private func resetGame() {
//        
//        presenter.resetQuestionIndex()
//        self.presenter.restartGame()
//        //questionFactory?.requestNextQuestion()
//    }
    
    
    
    func show(quiz step: QuizStepViewModel) {
          imageView.layer.borderColor = UIColor.clear.cgColor
          imageView.image = step.image
          textLabel.text = step.question
          counterLabel.text = step.questionNumber
      }
    
    
//    func showAnswerResult(isCorrect: Bool) {
//        imageView.layer.masksToBounds = true
//        imageView.layer.borderWidth = 8
//        imageView.layer.borderColor = isCorrect ? UIColor(named: "ypGreen")?.cgColor : UIColor(named: "ypRed")?.cgColor
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            guard let self = self else { return }
//
//            //self.presenter.questionFactory = self.questionFactory
//            self.showNextQuestionOrResults()
//        }
//    }'
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    
    func show(quiz result: QuizResultsViewModel) {
          let message = presenter.makeResultsMessage()
          
          let alert = UIAlertController(
              title: result.title,
              message: message,
              preferredStyle: .alert)
              
          let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                  guard let self = self else { return }
                  
                  self.presenter.restartGame()
          }
          
          alert.addAction(action)
          
          self.present(alert, animated: true, completion: nil)
      }
    
    
}
