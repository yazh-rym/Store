//
//  OnBoardingPageViewController.swift
//  Tryon
//
//  Created by Udayakumar N on 22/05/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit

protocol OnBoardingPageViewControllerDelegate: class {
    func onBoardingPageViewController(_ onBoardingPageViewController: OnBoardingPageViewController, didUpdatePageCount count: Int)
    func onBoardingPageViewController(_ onBoardingPageViewController: OnBoardingPageViewController, didUpdatePageIndex index: Int)
}

class OnBoardingPageViewController: UIPageViewController {
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.pageViewController(storyboardId: "Image1ViewController", screenName: "OnBoardingScreen1"),
                self.pageViewController(storyboardId: "Image2ViewController", screenName: "OnBoardingScreen2"),
                self.pageViewController(storyboardId: "Image3ViewController", screenName: "OnBoardingScreen3")]
    }()
    
    weak var onBoardingDelegate: OnBoardingPageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        onBoardingDelegate?.onBoardingPageViewController(self, didUpdatePageCount: orderedViewControllers.count)
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func pageViewController(storyboardId: String, screenName: String) -> UIViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(storyboardId)") as! OnBoardingPageController
        viewController.scrollDirection = .left
        viewController.onBoardingPageDelegate = self
        viewController.screenName = screenName
        
        return viewController
    }
}

extension OnBoardingPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        
        guard previousIndex >= 0 else {
            //User is on the first view controller and do not allow to the last view controller
            return nil
            
            // User is on the first view controller and swiped left to loop to the last view controller.
            //return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            // User is on the last view controller and do not allow to the first view controller
            return nil
            
            // User is on the last view controller and swiped right to loop to the first view controller.
            //return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

extension OnBoardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            onBoardingDelegate?.onBoardingPageViewController(self, didUpdatePageIndex: index)
        }
    }
}

extension OnBoardingPageViewController: OnBoardingPageDelegate {
    func onBoardingPageDidDisplay(_ viewController: OnBoardingPageController) {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return
        }
        
        let nextIndex = viewControllerIndex + 1
        let previousIndex = viewControllerIndex - 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        if nextIndex < orderedViewControllersCount {
            let viewController = orderedViewControllers[nextIndex] as! OnBoardingPageController
            viewController.scrollDirection = .right
        }
        
        if previousIndex >= 0 {
            let viewController = orderedViewControllers[previousIndex] as! OnBoardingPageController
            viewController.scrollDirection = .left
        }
    }
}
