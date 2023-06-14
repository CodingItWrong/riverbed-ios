import Foundation

typealias AttachmentCompletion = (NSSecureCoding?, Error?) -> Void

protocol Attachment {
    var registeredTypeIdentifiers: [String] { get }

    func hasItemConformingToTypeIdentifier(_: String) -> Bool

    func loadItem(forTypeIdentifier: String, completion: AttachmentCompletion?)
}

extension NSItemProvider: Attachment {
    func loadItem(forTypeIdentifier typeIdentifier: String, completion: AttachmentCompletion?) {
        self.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { (value, error) in
            completion?(value, error)
        }
    }
}
