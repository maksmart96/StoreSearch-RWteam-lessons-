//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by  Максим Мартынов on 25.05.2021.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?
    enum AnimationStyle {
        case slide
        case fade
    }
    var dismissStyle = AnimationStyle.fade
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      modalPresentationStyle = .custom
      transitioningDelegate = self
    }
    
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        
        popupView.layer.cornerRadius = 10
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if searchResult != nil {
            updateUI()
        }
    }
 
    
    // MARK:- Actions
    @IBAction func close() {
        dismissStyle = .slide
      dismiss(animated: true, completion: nil)
    }
    @IBAction func openInStore() {
      if let url = URL(string: searchResult.storeURL) {
        UIApplication.shared.open(url, options: [:],
                              completionHandler: nil)
    } }
    
    func updateUI() {
    nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Artist name isEmpty")
        } else {
            artistNameLabel.text = searchResult.artist
        }
        kindLabel.text = searchResult.kind
        genreLabel.text = searchResult.genre
       
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        
        // Show price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        let priceText: String
        if searchResult.price == 0 {
          priceText = NSLocalizedString("Free", comment: "searchResult price = 0")
        } else if let text = formatter.string(
                  from: searchResult.price as NSNumber) {
          priceText = text
        } else {
          priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
  func presentationController(
     forPresented presented: UIViewController,
     presenting: UIViewController?, source: UIViewController) ->
     UIPresentationController? {
    return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
  }
    func animationController(forPresented presented:
         UIViewController, presenting: UIViewController,
         source: UIViewController) ->
         UIViewControllerAnimatedTransitioning? {
      return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
  }
}

extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return (touch.view === self.view)
} }
