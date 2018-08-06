//
//  ScrollableSegmentedControl.swift
//  ScrollableSegmentedControl
//
//  Created by MArko Satlan on 22/07/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit

class ScrollableSegmentedControl: UIControl {

// MARK: - Properties
    // Open
    open var font = UIFont(name: "Georgia", size: 15) {
        didSet {
            setNeedsLayout()
        }
    }
    open var buttonPadding: CGFloat = 15 {
        didSet {
            setNeedsLayout()
        }
    }
    open var buttonMargin: CGFloat = 15 {
        didSet {
            setNeedsLayout()
        }
    }
    open var selectedSegmentIndex: Int = -1 {
        didSet {
            highlightSelectedSegment()
            calculateAndSetScrollOffset()
            
            // deselect previous button if different button is tapped
            if oldValue != selectedSegmentIndex {
                let previousButton = buttonsArray.filter{$0.tag == oldValue}.first
                previousButton?.isSelected = false
                UIButton.animate(withDuration: 0.3, animations: {
                    previousButton?.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    // Private
    private var buttonTitles: [String] = []
    private var buttonsArray: [UIButton] = []
    private let scrollView = UIScrollView()
    
// MARK: - Methods
    // Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
    }
    
    public init(items: [String]) {
        self.buttonTitles = items
        
        super.init(frame: CGRect.zero)
        
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        createButtons()
    }
    
    public func setItems(_ items: [String]) {
        self.buttonTitles = items
        createButtons()
        setNeedsLayout()
    }
    
    // Layout subviews - set frames
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        updateUI()
        drawSeparatorLine()
        highlightSelectedSegment()
        calculateAndSetScrollOffset()
    }
    
    // Action methods
    @objc private func buttonTapped(_ sender: UIButton) {
        let previousButton = buttonsArray.filter{$0.tag == selectedSegmentIndex}.first
        
        selectedSegmentIndex = sender.tag
        
        if previousButton?.tag != sender.tag {
            sendActions(for: .valueChanged)
            previousButton?.isSelected = false
            UIButton.animate(withDuration: 0.3, animations: {
                previousButton?.transform = CGAffineTransform.identity
            })
        }
 
        sender.isSelected = true
    }
    
// Private
    // Create buttons
    private func createButtons() {
        for button in buttonsArray {
            button.removeFromSuperview()
        }
        buttonsArray.removeAll()
        
        var buttonTag: Int = 0
        
        for title in buttonTitles {
            let button = UIButton(type: .custom)
        
            button.setTitleColor(UIColor.lightGray, for: .normal)
            button.setTitleColor(UIColor.black, for: .selected)
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            button.setTitle(title, for: .normal)
            
            button.tag = buttonTag
            
            buttonTag += 1
            
            buttonsArray.append(button)
        }
    }
    
    private func updateUI() {
        var numberOfPaddings: CGFloat = -1
        var buttonX: CGFloat = buttonMargin
        var contentSizeWidth: CGFloat = 0
        
        // Set button frame
        for button in buttonsArray {
            button.transform = CGAffineTransform.identity
            button.titleLabel?.font = font
            
            let buttonSize = calculateButtonSize(title: (button.titleLabel?.text)!, fontAttributes: [NSAttributedStringKey.font: font!])
            
            button.frame = CGRect(x: buttonX,
                                  y: (frame.size.height - buttonSize.height) / 2,
                                  width: buttonSize.width,
                                  height: buttonSize.height)
            
            buttonX += button.frame.size.width + buttonPadding
            
            scrollView.addSubview(button)
            
            numberOfPaddings += 1
            
            contentSizeWidth += button.frame.size.width
        }
        
        scrollView.contentSize.width = contentSizeWidth + (buttonPadding * (CGFloat(buttonsArray.count) - 1)) + (2 * buttonMargin)
    }
    
    func calculateButtonSize(title: String, fontAttributes: [NSAttributedStringKey : Any]) -> CGSize {
        let buttonSize = CGSize(width: (title.size(withAttributes: fontAttributes).width),
                                height: (title.size(withAttributes: fontAttributes).height))
        return buttonSize
    }
    
    // Draw separator line
    private func drawSeparatorLine() {
        let separatorHeight: CGFloat = 1
        let separatorWidth: CGFloat
        
        if scrollView.contentSize.width <= frame.size.width {
            separatorWidth = frame.size.width
        } else {
            separatorWidth = scrollView.contentSize.width
        }
 
        let separator = UIView(frame: CGRect(x: 0,
                                             y: frame.size.height - separatorHeight,
                                             width: separatorWidth,
                                             height: separatorHeight))
        
        separator.backgroundColor = UIColor.lightGray
 
        addSubview(separator)
    }
    
    private func highlightSelectedSegment() {
        let selectedSegment = buttonsArray.filter{$0.tag == selectedSegmentIndex}.first

        selectedSegment?.isSelected = true
        UIButton.animate(withDuration: 0.3, animations: {
            selectedSegment?.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        })
    }
    
    // MARK: - TODO make selected segment index optional - if user wants to set it to 0, app crashes because there is no selected button(line 191)
    
    private func calculateAndSetScrollOffset() {
        var scrollOffset: CGFloat = 0
        let selectedButton: UIButton? = buttonsArray.filter{$0.tag == selectedSegmentIndex}.first
  
        guard let button = selectedButton else { return scrollOffset = 0 }
        
        let amountToScroll: CGFloat = center.x - button.center.x
        
        // 1. if content size is <= than frame size width; no need for scrolling (i.e. 2 or 3 buttons)
        if scrollView.contentSize.width <= frame.size.width {
            scrollOffset = 0
        } else {
            // 2. needs to scroll to button
            // 2.1. scroll with negative value
            if button.center.x <= center.x {
                scrollOffset = -amountToScroll
                // 2.1.1. pin scroll view offset to container view margin left hand side to avoid scrolling beyond scroll view content size
                if scrollOffset <= 0 {
                    scrollOffset = 0
                } else {
                    // 2.1.2. scroll to button
                    scrollOffset = -amountToScroll
                }
            } else {
                // 2.2. scroll with positive value
                scrollOffset = abs(amountToScroll)
                // 2.2.1. pin scroll view offset to container view margin right hand side avoid scrolling beyond scroll view content size
                if scrollOffset >= scrollView.contentSize.width - frame.size.width {
                    scrollOffset = scrollView.contentSize.width - frame.size.width
                } else {
                    // 2.2.2. scroll to button
                    scrollOffset = abs(amountToScroll)
                }
            }
        }
        scrollView.setContentOffset(CGPoint(x: scrollOffset, y: 0), animated: true)
    }
}
