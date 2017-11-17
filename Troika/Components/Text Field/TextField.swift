//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class TextField: UIView {

    // MARK: - Internal properties

    private let eyeImage = UIImage(frameworkImageNamed: "view")!.withRenderingMode(.alwaysTemplate)
    private let clearTextIcon = UIImage(frameworkImageNamed: "remove")!.withRenderingMode(.alwaysTemplate)

    private lazy var typeLabel: Label = {
        let label = Label(style: .detail(.stone))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: clearTextIcon.size.width, height: clearTextIcon.size.height))
        button.setImage(clearTextIcon, for: .normal)
        button.imageView?.tintColor = .stone
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()

    private lazy var showPasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(eyeImage, for: .normal)
        button.imageView?.tintColor = .stone
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(showHidePassword), for: .touchUpInside)
        return button
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.body
        textField.textColor = .licorice
        textField.tintColor = .secondaryBlue
        textField.delegate = self
        textField.rightViewMode = .whileEditing
        textField.rightView = clearButton
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private let underlineHeight: CGFloat = 2
    private let animationDuration: Double = 0.3

    private lazy var underline: UIView = {
        let view = UIView()
        view.backgroundColor = .stone
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Setup

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        isAccessibilityElement = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        addSubview(typeLabel)
        addSubview(textField)
        addSubview(showPasswordButton)
        addSubview(underline)
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        typeLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true

        textField.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: .mediumSpacing).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor).isActive = true

        showPasswordButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        showPasswordButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
        showPasswordButton.heightAnchor.constraint(equalToConstant: eyeImage.size.height).isActive = true

        if (model?.type.isSecureMode)! {
            showPasswordButton.widthAnchor.constraint(equalToConstant: eyeImage.size.width).isActive = true
        } else {
            showPasswordButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
        }

        underline.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        underline.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        underline.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: .mediumSpacing).isActive = true
        underline.heightAnchor.constraint(equalToConstant: underlineHeight).isActive = true
        underline.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        typeLabel.transform = transform.translatedBy(x: 0, y: typeLabel.frame.height)
    }

    // MARK: - Dependency injection

    public var model: TextFieldModel? {
        didSet {
            guard let model = model else {
                return
            }

            typeLabel.text = model.type.typeText
            textField.isSecureTextEntry = model.type.isSecureMode
            showPasswordButton.isHidden = !model.type.isSecureMode
            accessibilityLabel = model.accessibilityLabel
            textField.placeholder = model.type.typeText
            textField.keyboardType = model.type.keyBoardStyle

            if model.type.isSecureMode {
                textField.rightViewMode = .never
            }
        }
    }

    // MARK: - Actions

    @objc private func showHidePassword(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            sender.imageView?.tintColor = .secondaryBlue
            textField.isSecureTextEntry = false
        } else {
            sender.imageView?.tintColor = .stone
            textField.isSecureTextEntry = true
        }
    }

    @objc private func clearTapped() {
        textField.text = ""
        textFieldDidChange()
    }

    @objc private func textFieldDidChange() {

        if let text = textField.text, !text.isEmpty {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.typeLabel.transform = CGAffineTransform.identity
                self.typeLabel.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.typeLabel.transform = self.typeLabel.transform.translatedBy(x: 0, y: self.typeLabel.frame.height)
                self.typeLabel.alpha = 0
            })
        }
    }

    @objc private func handleTap() {
        textField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension TextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: animationDuration) {
            self.underline.backgroundColor = .secondaryBlue
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: animationDuration) {
            self.underline.backgroundColor = .stone
        }
    }
}