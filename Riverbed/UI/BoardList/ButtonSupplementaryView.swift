import UIKit

class ButtonSupplementaryView: UICollectionReusableView {
    let button = UIButton()
    static let reuseIdentifier = "button-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension ButtonSupplementaryView {
    func configure() {
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            button.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }
}
