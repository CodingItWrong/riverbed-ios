import Foundation

func print(jsonData: Data?) {
    guard let jsonData = jsonData else {
        return
    }

    if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    }
}

func singularizeOptionality<T>(_ value: T??) -> T? {
    if let nestedOptional: T? = value {
        return nestedOptional
    } else {
        let singleOptional: T? = nil
        return singleOptional
    }
    // alternative: return value ?? nil
    // see https://stackoverflow.com/a/33049398/477480
}
