import Foundation

struct RiverbedAPI {
    struct Response<T>: Codable where T: Codable {
        let data: T
    }

    static let accessToken = "nKDTc2UUqkascU0g9XzIOGaXF70X1PvYWAHKU2vz2oU"

    private static let baseURL = URL(string: "http://localhost:3000/")

    static func boardsURL() -> URL {
        url(boardsPath())
    }

    static func boardURL(_ board: Board) -> URL {
        url(boardPath(board))
    }

    static func cardsURL(for board: Board) -> URL {
        url(cardsPath(board))
    }

    static func cardURL(for card: Card) -> URL {
        url(cardPath(card))
    }

    static func columnsURL(for board: Board) -> URL {
        url(columnsPath(board))
    }

    static func elementsURL(for board: Board) -> URL {
        url(elementsPath(board))
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

    private static func cardsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "cards")
    }

    private static func cardPath(_ card: Card) -> String {
        joinPathSegments("/cards", card.id)
    }

    private static func columnsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "columns")
    }

    private static func elementsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "elements")
    }

    private static func joinPathSegments(_ pathSegments: String...) -> String {
        pathSegments.joined(separator: "/")
    }
}
