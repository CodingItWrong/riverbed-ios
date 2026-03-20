@testable import Riverbed
import Foundation

class MockColumnStore: ColumnStore {
    var allResult: Result<[Column], Error>?
    var cardsResults: [String: Result<[Card], Error>] = [:]
    var createResult: Result<Column, Error>?
    var updateResult: Result<Void, Error>?
    var deleteResult: Result<Void, Error>?

    func all(for board: Board, completion: @escaping (Result<[Column], Error>) -> Void) {
        if let result = allResult { completion(result) }
    }

    func cards(for column: Column, completion: @escaping (Result<[Card], Error>) -> Void) {
        if let result = cardsResults[column.id] { completion(result) }
    }

    func create(on board: Board, completion: @escaping (Result<Column, Error>) -> Void) {
        if let result = createResult { completion(result) }
    }

    func update(_ column: Column,
                with updatedAttributes: Column.Attributes,
                completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = updateResult { completion(result) }
    }

    func updateDisplayOrders(of columns: [Column],
                             completion: @escaping (Result<[Column], Error>) -> Void) {
        // not needed for current tests
    }

    func delete(_ column: Column, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = deleteResult { completion(result) }
    }
}
