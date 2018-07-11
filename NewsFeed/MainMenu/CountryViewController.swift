//
//  CountryViewController.swift
//  NewsFeed
//
//  Created by MArko Satlan on 19/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit

protocol CountryViewControllerDelegate: class {
    func countryViewController(_ controller: CountryViewController, didSelectLanguage language: String)
}

class CountryViewController: UIViewController {

// MARK: - Properties
    weak var delegate: CountryViewControllerDelegate?
    
// MARK: - @IBOutlet
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rsButton: CustomButton!
    @IBOutlet weak var siButton: CustomButton!
    @IBOutlet weak var deButton: CustomButton!
    @IBOutlet weak var frButton: CustomButton!
    @IBOutlet weak var gbButton: CustomButton!
    @IBOutlet weak var usButton: CustomButton!
    @IBOutlet weak var selectionView: UIView!
    
// MARK: - @IBAction
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonTapped(_ sender: CustomButton) {
        var country = ""
        
        switch sender.tag {
        case 1:
            country = "rs"
        case 2:
            country = "si"
        case 3:
            country = "de"
        case 4:
            country = "fr"
        case 5:
            country = "gb"
        case 6:
            country = "us"
        default:
            break
        }
        
        if let language = ServerRequest.Language(rawValue: country) {
            delegate?.countryViewController(self, didSelectLanguage: language.rawValue)
            dismiss(animated: true, completion: nil)
        }
    }
    
// MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        selectionView.layer.cornerRadius = 7
        label.font = UIFont.georgia(ofSize: 17)
        label.text = "Select country to show news"
        
        configureButtons()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

// MARK: - init    
   required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
// MARK: - Methods
    private func configureButtons() {
        rsButton.setTitle("Srbija", for: .normal)
        siButton.setTitle("Slovenija", for: .normal)
        deButton.setTitle("Deutschland", for: .normal)
        frButton.setTitle("France", for: .normal)
        gbButton.setTitle("Great Britain", for: .normal)
        usButton.setTitle("United States", for: .normal)
    }
}

extension CountryViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return EntryAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ClosingAnimationController()
    }
}

extension CountryViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
