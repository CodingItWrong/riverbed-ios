import Foundation

func print(jsonData: Data?) {
    guard let jsonData = jsonData else {
        return
    }

    if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    }
}

func print(codable: Codable?) {
    guard let codable = codable else {
        return
    }

    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(codable)
        print(jsonData: data)
    } catch {
        print("error encoding")
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

func getInitialValues(forElements elements: [Element]) -> [String: FieldValue?] {
    let fieldsWithInitialValues = elements.filter { (element) in
        element.attributes.elementType == .field &&
        element.attributes.initialValue != nil
    }

    var initialFieldValues = [String: FieldValue?]()
    fieldsWithInitialValues.forEach { (field) in
        guard let initialValue = field.attributes.initialValue,
              let dataType = field.attributes.dataType else { return }

        let resolvedValue = initialValue.call(fieldDataType: dataType,
                                              specificValue: field.attributes.options?.initialSpecificValue)
        initialFieldValues[field.id] = resolvedValue
    }

    return initialFieldValues
}

func apply(actions: [Action],
           to fieldValues: [String: FieldValue?],
           elements: [Element]) -> [String: FieldValue?] {
    var newFieldValues = fieldValues
    actions.forEach { (action) in
        newFieldValues = action.call(elements: elements, fieldValues: newFieldValues)
    }
    return newFieldValues
}

func isValidEmail(_ emailString: String) -> Bool {
    let pattern = "^[^@\\s]+@[^@\\s]+\\.[A-Za-z]+$"
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        preconditionFailure("Invalid regex")
    }
    return regex.numberOfMatches(in: emailString,
                                 options: [],
                                 range: NSRange(location: 0,
                                                length: emailString.count)) > 0
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

func isPlatformMac() -> Bool {
    return ProcessInfo.processInfo.isiOSAppOnMac
}
