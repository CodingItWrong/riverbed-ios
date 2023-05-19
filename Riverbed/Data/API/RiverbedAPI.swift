import Foundation

struct RiverbedAPI {
    struct Response<T>: Codable where T: Codable {
        let data: T
    }

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

    static func columnsURL(for board: Board) -> URL {
        url(columnsPath(board))
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

    private static func columnsPath(_ board: Board) -> String {
        joinPathSegments(boardPath(board), "columns")
    }

    private static func joinPathSegments(_ pathSegments: String...) -> String {
        pathSegments.joined(separator: "/")
    }
}
