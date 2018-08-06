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
    open var buttonSpacing: CGFloat = 15 {
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
                let button = buttonsArray.filter{$0.tag == oldValue}.first
                if let previousButton = button {
                    previousButton.isSelected = false
                    UIButton.animate(withDuration: 0.3, animations: {
                        previousButton.transform = CGAffineTransform.identity
                    })
                }
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
        
        setUp()
        drawSeparatorLine()
    }
    
    public init(items: [String]) {
        self.buttonTitles = items
        
        super.init(frame: CGRect.zero)
        
        setUp()
        createButtons()
        drawSeparatorLine()
    }
    
    public func setItems(_ items: [String]) {
        self.buttonTitles = items
        createButtons()
        setNeedsLayout()
    }
    
    // Layout subviews - set frames
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        
        updateUI()
        highlightSelectedSegment()
        calculateAndSetScrollOffset()
    }
    
    // Action methods
    @objc private func buttonTapped(_ sender: UIButton) {
        let button = buttonsArray.filter{$0.tag == selectedSegmentIndex}.first
        
        selectedSegmentIndex = sender.tag
        
        if let previousButton = button {
            if previousButton.tag != sender.tag {
                sendActions(for: .valueChanged)
                previousButton.isSelected = false
                UIButton.animate(withDuration: 0.3, animations: {
                    previousButton.transform = CGAffineTransform.identity
                })
            }
        }
        
        sender.isSelected = true
    }
    
    // Private
    // Set up
    private func setUp() {
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
    }
    
    // Create buttons
    private func createButtons() {
        for button in buttonsArray {
            button.removeFromSuperview()
        }
        buttonsArray.removeAll()
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .custom)
        
            button.setTitleColor(UIColor.lightGray, for: .normal)
            button.setTitleColor(UIColor.black, for: .selected)
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            button.setTitle(title, for: .normal)
            
            button.tag = index
            
            buttonsArray.append(button)
            
            scrollView.addSubview(button)
        }
    }
    
    private func updateUI() {
        var buttonX: CGFloat = buttonMargin
        var contentSizeWidth: CGFloat = 0
        
        // Set button frame
        for button in buttonsArray {
            button.transform = CGAffineTransform.identity
            button.titleLabel?.font = font
            
            let buttonSize = calculateButtonSize(title: (button.titleLabel?.text)!, fontAttributes: [NSAttributedStringKey.font: font!])
            
            button.frame = CGRect(x: buttonX,
                                  y: 0,
                                  width: buttonSize.width,
                                  height: scrollView.frame.size.height)
            
            buttonX += button.frame.size.width + buttonSpacing
            
            contentSizeWidth += button.frame.size.width
        }
        
        scrollView.contentSize.width = buttonX
    }
    
    func calculateButtonSize(title: String, fontAttributes: [NSAttributedStringKey : Any]) -> CGSize {
        return title.size(withAttributes: fontAttributes)
    }
    
    // Draw separator line
    private func drawSeparatorLine() {
        let separatorHeight: CGFloat = 1

        let separator = UIView(frame: CGRect(x: 0,
                                             y: frame.size.height - separatorHeight,
                                             width: frame.size.width,
                                             height: separatorHeight))
        
        separator.backgroundColor = UIColor.lightGray
 
        addSubview(separator)
    }
    
    private func highlightSelectedSegment() {
        let segment = buttonsArray.filter{$0.tag == selectedSegmentIndex}.first

        if let selectedSegment = segment {
            selectedSegment.isSelected = true
            UIButton.animate(withDuration: 0.3, animations: {
                selectedSegment.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            })
        }
    }

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
