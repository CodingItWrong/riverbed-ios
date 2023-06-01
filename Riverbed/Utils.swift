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

func checkConditions(fieldValues: [String: FieldValue?],
                     conditions: [Condition]?,
                     elements: [Element]) -> Bool {
    guard let conditions = conditions else {
        return true
    }

    return conditions.allSatisfy { (condition) in
        guard let field = condition.field,
              let query = condition.query,
              field != "" else {
            return true
        }

        let fieldObject = elements.first { $0.id == field }
        guard let dataType = fieldObject?.attributes.dataType else {
            return true
        }
        var value: FieldValue?
        if let tempValue = fieldValues[field] {
            value = tempValue // attempt to handle a double optional
        }
        return query.match(value: value, dataType: dataType, options: condition.options)
    }
}

func domain(for urlString: String) -> String? {
    guard let url = URL(string: urlString),
          let hostName = getHostName(for: url) else { return urlString }

    if hostName.hasPrefix("www.") {
        return String(hostName.dropFirst(4))
    } else {
        return hostName
    }
}

private func getHostName(for url: URL) -> String? {
    if #available(iOS 16, *) {
        return url.host(percentEncoded: false)
    } else {
        return url.host
    }
}
