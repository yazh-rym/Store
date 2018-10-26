//
//  OnBoardingController.swift
//  Tryon
//
//  Created by Udayakumar N on 22/05/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Material


class OnBoardingController: UIViewController {
    
    // MARK: - Class Variables
    let model = TryonModel.sharedInstance
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBAction func getStartedDidTap(_ sender: RaisedButton) {
        model.showOnBoarding = false
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func skipDidTap(_ sender: UIButton) {
        model.showOnBoarding = false
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onBoardingPageViewController = segue.destination as? OnBoardingPageViewController {
            onBoardingPageViewController.onBoardingDelegate = self
        }
    }
}

extension OnBoardingController: OnBoardingPageViewControllerDelegate {
    func onBoardingPageViewController(_ onBoardingPageViewController: OnBoardingPageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func onBoardingPageViewController(_ onBoardingPageViewController: OnBoardingPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}
