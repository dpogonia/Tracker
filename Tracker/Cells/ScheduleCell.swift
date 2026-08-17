import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func scheduleCell(_ cell: ScheduleCell, didChangeValue isOn: Bool, for day: WeekDay)
}

final class ScheduleCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleCell"

    weak var delegate: ScheduleCellDelegate?

    private var day: WeekDay?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlue
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return daySwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(daySwitch)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(day: WeekDay, isOn: Bool) {
        self.day = day
        titleLabel.text = day.name
        daySwitch.isOn = isOn
    }

    @objc
    private func switchChanged() {
        guard let day else { return }
        delegate?.scheduleCell(self, didChangeValue: daySwitch.isOn, for: day)
    }
}
