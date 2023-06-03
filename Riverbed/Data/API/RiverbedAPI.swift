import Foundation

struct RiverbedAPI {
    struct RequestBody<T>: Codable where T: Codable {
        let data: T
    }

    struct Response<T>: Codable where T: Codable {
        let data: T
    }

    static let accessToken = "6dS9tQyWGS5FZ9L5w00mWmelbj1VfE4U2-enMm6oKOU"
    private static let baseURL = URL(string: "http://localhost:3000/")

    static func boardsURL() -> URL {
        url(boardsPath())
    }

    static func boardURL(_ board: Board) -> URL {
        url(boardPath(board))
    }

    static func cardsURL() -> URL {
        url(cardsPath())
    }

    static func cardsURL(for board: Board) -> URL {
        url(cardsPath(board))
    }

    static func cardURL(for card: Card) -> URL {
        cardURL(for: card.id)
    }

    static func cardURL(for cardId: String) -> URL {
        url(cardPath(cardId))
    }

    static func columnsURL(for board: Board) -> URL {
        url(columnsPath(board))
    }

    static func elementsURL(for board: Board) -> URL {
        url(elementsPath(board))
    }

    static func elementURL(for element: Element) -> URL {
        url(elementPath(element))
    }

    // MARK: - private

    private static func url(_ path: String) -> URL {
        URL(string: path, relativeTo: baseURL)!
    }

    private static func boardsPath() -> String {
        "/boards"
    }

    private static func boardPath(_ board: Board) -> String {
        joinPathSegments(boardsPath(), board.id)
    }

    private static func cardsPath() -> String {
        "/cards"
    }

    private static func cardsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "cards")
    }

    private static func cardPath(_ cardId: String) -> String {
        joinPathSegments("/cards", cardId)
    }

    private static func columnsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "columns")
    }

    private static func elementPath(_ element: Element) -> String {
        joinPathSegments("/elements", element.id)
    }

    private static func elementsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "elements")
    }

    private static func joinPathSegments(_ pathSegments: String...) -> String {
        pathSegments.joined(separator: "/")
    }
}
