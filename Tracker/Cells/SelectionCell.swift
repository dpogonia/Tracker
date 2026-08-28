import UIKit

final class SelectionCell: UICollectionViewCell {
    static let reuseIdentifier = "SelectionCell"

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(colorView)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetAppearance()
    }

    func configureEmoji(_ emoji: String, isSelected: Bool) {
        resetAppearance()
        emojiLabel.isHidden = false
        colorView.isHidden = true
        emojiLabel.text = emoji
        contentView.backgroundColor = isSelected ? .ypLightGray : .clear
    }

    func configureColor(_ color: UIColor, isSelected: Bool) {
        resetAppearance()
        emojiLabel.isHidden = true
        colorView.isHidden = false
        colorView.backgroundColor = color
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        }
    }

    private func resetAppearance() {
        emojiLabel.text = nil
        emojiLabel.isHidden = true
        colorView.isHidden = true
        colorView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
