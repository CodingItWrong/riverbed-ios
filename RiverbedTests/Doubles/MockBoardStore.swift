@testable import Riverbed
import Foundation

class MockBoardStore: BoardStore {
    enum Call: Equatable {
        case update (board: Riverbed.Board, attributes: Riverbed.Board.Attributes)
        case delete (board: Riverbed.Board)
    }
    
    var calls: [Call] = []
    
    var allResult: Result<[Riverbed.Board], any Error>? = nil
    var createResult: Result<Riverbed.Board, any Error>? = nil
    var updateResult: Result<Riverbed.Board, any Error>? = nil
    var deleteResult: Result<Void, any Error>? = nil

    func all(completion: @escaping (Result<[Riverbed.Board], any Error>) -> Void) {
        if let result = allResult {
            completion(result)
        }
    }
    
    func create(completion: @escaping (Result<Riverbed.Board, any Error>) -> Void) {
        if let result = createResult {
            completion(result)
        }
    }
    
    func update(_ board: Riverbed.Board,
                with updatedAttributes: Riverbed.Board.Attributes,
                completion: @escaping (Result<Riverbed.Board, any Error>) -> Void) {
        calls.append(.update(board: board, attributes: updatedAttributes))
        
        if let result = updateResult {
            completion(result)
        }
    }
    
    func delete(_ board: Riverbed.Board,
                completion: @escaping (Result<Void, any Error>) -> Void) {
        calls.append(.delete(board: board))
        
        if let result = deleteResult {
            completion(result)
        }
    }

}
