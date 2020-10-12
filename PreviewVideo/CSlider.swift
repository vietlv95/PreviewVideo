//
//  CSlider.swift
//  PreviewVideo
//
//  Created by VietLV on 10/12/20.
//

import UIKit

protocol CSliderDelegate: class {
    func csliderWillBeginChangeValue(_ slider: CSlider)
    func csliderDidChangedValue(_ slider: CSlider)
    func csliderDidEndChangeValue(_ slider: CSlider)
}

private struct Const {
    static let thumbWidth: CGFloat = 15
}

class CSlider: UIView {

    // MARK: - Public
    weak var delegate: CSliderDelegate?

    var value: CGFloat = 0 {
        didSet {
            updateViewLayout(value: value)
        }
    }

    var thumbColor = UIColor.white {
        didSet {
            thumbView.backgroundColor = thumbColor
        }
    }

    var leftColor = UIColor.gray {
        didSet {
            leftView.backgroundColor = leftColor
        }
    }

    var rightColor =  UIColor.gray {
        didSet {
            backgroundView.backgroundColor = rightColor
        }
    }

    // MARK: - Views
    private var thumbView: UIView!
    private var backgroundView: UIView!
    private var leftView: UIView!

    // MARK: - Variables
    private var leftViewWidthConstraint: NSLayoutConstraint!

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }

    private func customInit() {
        initBackgroundView()
        initLeftView()
        initThumbView()
        addGesture()
    }

    private func initBackgroundView() {
        backgroundView = UIView()
        backgroundView.backgroundColor = thumbColor
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.thumbWidth / 2),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.thumbWidth / 2),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 3)
        ])
    }

    private func initLeftView() {
        leftView = UIView()
        leftView.backgroundColor = leftColor
        addSubview(leftView)
        leftView.translatesAutoresizingMaskIntoConstraints = false
        leftViewWidthConstraint = leftView.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            leftView.heightAnchor.constraint(equalToConstant: 3),
            leftView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.thumbWidth / 2),
            leftView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            leftViewWidthConstraint
        ])
    }

    private func initThumbView() {
        thumbView = UIView()
        thumbView.layer.cornerRadius = Const.thumbWidth / 2
        thumbView.backgroundColor = rightColor
        addSubview(thumbView)
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: -Const.thumbWidth / 2),
            thumbView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor, constant: 0),
            thumbView.widthAnchor.constraint(equalToConstant: Const.thumbWidth),
            thumbView.heightAnchor.constraint(equalToConstant: Const.thumbWidth)
        ])
    }


    private func addGesture() {
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(thumbImageViewPanGestureAction(_:)))
        thumbView.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAction(_:)))
        addGestureRecognizer(tapGesture)
    }

    // MARK: - Helper
    @objc func thumbImageViewPanGestureAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            delegate?.csliderWillBeginChangeValue(self)
        case .changed:
            let translation = gesture.translation(in: self)
            gesture.setTranslation(.zero, in: self)
            let newValue = (self.leftViewWidthConstraint.constant + translation.x) / backgroundView.frame.width
            self.value = CGFloat.maximum(0, CGFloat.minimum(1, newValue))
            delegate?.csliderDidChangedValue(self)
        case .ended, .cancelled:
            delegate?.csliderDidEndChangeValue(self)
        default:
            break
        }
    }

    @objc func tapGestureAction(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let locationOnBackgroundView = self.convert(location, to: backgroundView)
        let newValue = locationOnBackgroundView.x / backgroundView.frame.width
        self.value = CGFloat.maximum(0, CGFloat.minimum(1, newValue))
        delegate?.csliderDidChangedValue(self)
    }

    private func updateViewLayout(value: CGFloat) {
        let width = value * self.backgroundView.frame.width
        leftViewWidthConstraint.constant = width
        layoutIfNeeded()
    }
}
