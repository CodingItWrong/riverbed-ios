import Foundation

func print(jsonData: Data?) {
    guard let jsonData = jsonData else {
        return
    }

    if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    }
}
