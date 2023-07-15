import Foundation

struct RiverbedAPI {
#if targetEnvironment(simulator)
    private static let baseURL = URL(string: "http://localhost:3000/")
//    private static let baseURL = URL(string: "https://api.riverbed.app/")
#else
//    private static let baseURL = URL(string: "http://localhost:3000/")
    private static let baseURL = URL(string: "https://api.riverbed.app/")
#endif

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

    static func columnsURL() -> URL {
        url(columnsPath())
    }

    static func columnsURL(for board: Board) -> URL {
        url(columnsPath(board))
    }

    static func columnURL(for columnId: String) -> URL {
        url(columnPath(columnId))
    }

    static func elementsURL() -> URL {
        url(elementsPath())
    }

    static func elementsURL(for board: Board) -> URL {
        url(elementsPath(board))
    }

    static func elementURL(for element: Element) -> URL {
        url(elementPath(element))
    }

    static func tokensURL() -> URL {
        url(tokensPath())
    }

    static func userURL(for userId: String) -> URL {
        url(userPath(userId))
    }

    static func webhookURL() -> URL {
        url(webhookPath())
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

    private static func columnsPath() -> String {
        "/columns"
    }

    private static func columnsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "columns")
    }

    private static func columnPath(_ columnId: String) -> String {
        joinPathSegments(columnsPath(), columnId)
    }

    private static func elementPath(_ element: Element) -> String {
        joinPathSegments("/elements", element.id)
    }

    private static func elementsPath() -> String {
        "/elements"
    }

    private static func elementsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "elements")
    }

    private static func tokensPath() -> String {
        "/oauth/token"
    }

    private static func userPath(_ userId: String) -> String {
        joinPathSegments("/users", userId)
    }

    private static func webhookPath() -> String {
        "/shares"
    }

    private static func joinPathSegments(_ pathSegments: String...) -> String {
        pathSegments.joined(separator: "/")
    }
}
