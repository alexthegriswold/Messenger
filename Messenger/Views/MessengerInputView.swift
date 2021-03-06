//
//  MessengerInputView.swift
//  Messenger
//
//  Created by Melinda Griswold on 8/31/18.
//  Copyright © 2018 com.MobilePic. All rights reserved.
//

import UIKit

class MessengerInputView: UIView {
    
    //delegate
    weak var delegate: MessengerInputViewDelegate? = nil
    
    //MARK: Views
    let textViewBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = MessengerInputSizeComponents().textViewBackgroundCornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = nil
        textView.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        textView.returnKeyType = .send
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    //Constants
    let backgroundViewLeftMargin = MessengerInputSizeComponents().textViewBackgroundLeftMargin
    let backgroundViewRightMargin = MessengerInputSizeComponents().textViewBackgroundRightMargin
    let textViewLeftMargin = MessengerInputSizeComponents().textViewLeftMargin
    let textViewRightMargin = MessengerInputSizeComponents().textViewRightMargin
    
    //Constraints
    var textViewHeightConstraint: NSLayoutConstraint?
    var backgroundViewHeightConstraint: NSLayoutConstraint?
    var inputViewHeightConstraint: NSLayoutConstraint?
    
    var actionButtonWidthConstraint: NSLayoutConstraint?
    var actionButtonTopConstraint: NSLayoutConstraint?
    
    //Variables
    var textViewHeightMarker: CGFloat = 0
    var textViewLinesCount = 1
    
    var baseTextViewHeight: CGFloat = 0
    var textViewLineHeight: CGFloat = 0
    
    private var parentViewWidth: CGFloat = 0.0
    
    var lastTextViewHeightSettings = (CGFloat(0), false)
    var lastTextViewHeightSettingsForAnimation = (CGFloat(0), false)
    
    //Override view functions
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        textView.delegate = self
        
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        [textViewBackground, textView].forEach { addSubview($0) }
        getTextViewLineHeight()
        setupAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Helper functions
    func setParentViewWidth(width: CGFloat) {
        self.parentViewWidth = width
    }
    
    func getTextViewLineHeight() {
        textView.text = "a"
        let height1 = estimateTextViewHeight(width: 1)
        
        textView.text = "ab"
        let height2 = estimateTextViewHeight(width: 1)
        
        baseTextViewHeight = height1
        textViewLineHeight = height2 - height1
        
        textView.text = ""
    }
    
    //MARK: Auto layout
    func setupAutoLayout() {
        
        textViewHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
    
        backgroundViewHeightConstraint = NSLayoutConstraint(item: textViewBackground, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        
        inputViewHeightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        
        let textViewHeight = estimateTextViewHeight(width: 0)
        changeViewHeights(textViewHeight: textViewHeight, scrollEnabled: false)
        
        self.addConstraint(inputViewHeightConstraint!)
        
        textViewBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: backgroundViewLeftMargin).isActive = true
        textViewBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -backgroundViewRightMargin).isActive = true
        textViewBackground.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textViewBackground.addConstraint(backgroundViewHeightConstraint!)
        
        textView.leadingAnchor.constraint(equalTo: textViewBackground.leadingAnchor, constant: textViewLeftMargin).isActive = true
        textView.trailingAnchor.constraint(equalTo: textViewBackground.trailingAnchor, constant: -textViewRightMargin).isActive = true
        textView.centerYAnchor.constraint(equalTo: textViewBackground.centerYAnchor).isActive = true
        textView.addConstraint(textViewHeightConstraint!)
    }
    
    func changeViewHeights(textViewHeight: CGFloat, scrollEnabled: Bool) {
        
        textViewHeightMarker = textViewHeight
        
        let safeAreaHeight = MessengerInputSizeComponents().safeAreaSize
        let textViewBottomMargin = MessengerInputSizeComponents().textViewBottomMargin
        let textViewMargin: CGFloat = scrollEnabled ? 15 : 4
        let backgroundViewHeight = textViewHeight > 40 ? textViewHeight + textViewMargin : 40
        let inputViewHeight = backgroundViewHeight + textViewBottomMargin
        
        textViewHeightConstraint?.constant = textViewHeight
        backgroundViewHeightConstraint?.constant = backgroundViewHeight
        inputViewHeightConstraint?.constant = inputViewHeight + safeAreaHeight
        
        lastTextViewHeightSettings = (textViewHeight, scrollEnabled)
    }
    
    func startTextViewHideAnimation() {
        lastTextViewHeightSettingsForAnimation = lastTextViewHeightSettings
        changeViewHeights(textViewHeight: baseTextViewHeight, scrollEnabled: false)
    }
    
    func undoTextViewHideAnimation() {
        let height = lastTextViewHeightSettingsForAnimation.0
        let scrollEnabled = lastTextViewHeightSettingsForAnimation.1
        changeViewHeights(textViewHeight: height, scrollEnabled: scrollEnabled)
    }
    
    func estimateTextViewHeight(width: CGFloat) -> CGFloat {
        
        let size = CGSize(width: width, height: 0)
        return textView.sizeThatFits(size).height
    }
}

protocol MessengerInputViewDelegate: class {
    func lineDidUpdate(offset: CGFloat)
    func didHitSend(message: String)
}

extension MessengerInputView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location == NSNotFound {
            return true
        }

        delegate?.didHitSend(message: textView.text)
        self.textView.text = nil
        self.textView.isScrollEnabled = false
        self.changeViewHeights(textViewHeight: baseTextViewHeight, scrollEnabled: false)
        
        return false
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let allMargins = backgroundViewLeftMargin + backgroundViewRightMargin + textViewLeftMargin + textViewRightMargin
        let textViewHeight = estimateTextViewHeight(width: parentViewWidth - allMargins)
        
        if textViewHeight == textViewHeightMarker { return }

        if textViewHeight > textViewHeightMarker && textView.isScrollEnabled { return }
        
        textViewHeightMarker = textViewHeight
        let extraFromBase = baseTextViewHeight - textViewLineHeight
        let numberOfLines = (textViewHeight - extraFromBase)/textViewLineHeight
        
        if numberOfLines > 4 {
            textView.isScrollEnabled = true
            let height = baseTextViewHeight + (textViewLineHeight * 3)
            changeViewHeights(textViewHeight: height, scrollEnabled: true)
        } else {
            textView.isScrollEnabled = false
            changeViewHeights(textViewHeight: textViewHeight, scrollEnabled: false)
        }
    }
}

