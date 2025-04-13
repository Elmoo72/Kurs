import UIKit
struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        let currentAccuracy = total != 0 ? Double(correct) / Double(total) : 0.0
        let otherAccuracy = another.total != 0 ? Double(another.correct) / Double(another.total) : 0.0
        
        if currentAccuracy == otherAccuracy {
            // Если точность одинакова, сравниваем по дате (более свежий результат лучше)
            return date > another.date
        }
        return currentAccuracy > otherAccuracy
    }
    
}
