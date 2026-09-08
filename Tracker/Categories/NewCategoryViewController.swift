import UIKit

final class NewCategoryViewController: UIViewController {
    private let onSave: (String) -> Void

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .ypBlackDay
        textField.backgroundColor = .backgroundDay
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.rightViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let limitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()

    init(onSave: @escaping (String) -> Void) {
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(limitLabel)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            limitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            limitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func updateDoneButton() {
        let hasName = !(nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        doneButton.isEnabled = hasName
        doneButton.backgroundColor = hasName ? .ypBlackDay : .ypGray
    }

    @objc
    private func nameChanged() {
        updateDoneButton()
    }

    @objc
    private func doneTapped() {
        guard let title = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else { return }
        onSave(title)
        dismiss(animated: true)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else { return true }
        let updated = current.replacingCharacters(in: textRange, with: string)
        let isOverLimit = updated.count > 38
        limitLabel.isHidden = !isOverLimit
        return !isOverLimit
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
