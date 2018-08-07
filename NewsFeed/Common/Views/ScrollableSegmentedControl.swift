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
            setScrollOffset()
      
            // deselect previous button if different button is tapped
            if oldValue != selectedSegmentIndex {
                if let previousButton = (buttonsArray.filter{$0.tag == oldValue}.first) {
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
    private let separatorLine = UIView()
    
// MARK: - Methods
    // Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    public init(items: [String]) {
        self.buttonTitles = items
        
        super.init(frame: CGRect.zero)
        
        setUp()
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
        
        scrollView.frame = bounds
        
        separatorLine.frame = CGRect(x: 0,
                                     y: frame.size.height - 1,
                                     width: frame.size.width,
                                     height: 1)
        
        updateUI()
        highlightSelectedSegment()
        setScrollOffset()
    }
    
    // Action methods
    @objc private func buttonTapped(_ sender: UIButton) {
        if let previousButton = (buttonsArray.filter{$0.tag == selectedSegmentIndex}.first) {
            if previousButton.tag != sender.tag {
                sendActions(for: .valueChanged)
                previousButton.isSelected = false
                UIButton.animate(withDuration: 0.3, animations: {
                    previousButton.transform = CGAffineTransform.identity
                })
            }
        }
        
        selectedSegmentIndex = sender.tag
        
        sender.isSelected = true
    }
    
    // Private
    // Set up
    private func setUp() {
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        drawSeparatorLine()
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
        }
        
        scrollView.contentSize.width = buttonX - buttonSpacing + buttonMargin
    }
    
    func calculateButtonSize(title: String, fontAttributes: [NSAttributedStringKey : Any]) -> CGSize {
        return title.size(withAttributes: fontAttributes)
    }
    
    // Draw separator line
    private func drawSeparatorLine() {
        separatorLine.backgroundColor = UIColor.lightGray
 
        addSubview(separatorLine)
    }
    
    private func highlightSelectedSegment() {
        if let selectedSegment = (buttonsArray.filter{$0.tag == selectedSegmentIndex}.first) {
            selectedSegment.isSelected = true
            UIButton.animate(withDuration: 0.3, animations: {
                selectedSegment.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            })
        }
    }

    private func setScrollOffset() {
        guard scrollView.contentSize.width > scrollView.frame.width,
              let selectedButton = (buttonsArray.filter{$0.tag == selectedSegmentIndex}.first) else { return }
        
        var scrollOffset: CGFloat = selectedButton.center.x - center.x
        let minOffset: CGFloat = 0
        let maxOffset: CGFloat = scrollView.contentSize.width - frame.size.width
        
        if scrollOffset <= minOffset {
            scrollOffset = minOffset
        } else if scrollOffset > maxOffset {
            scrollOffset = maxOffset
        } 
 
        scrollView.setContentOffset(CGPoint(x: scrollOffset, y: 0), animated: true)
    }
}
