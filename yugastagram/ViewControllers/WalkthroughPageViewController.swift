//
//  WalkthroughPageViewController.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/24.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController,UIPageViewControllerDataSource {
  
    var pageContent = ["Learn to build Full Instagram","Built using Swift4 for frontend Firebase for Server","Learn to build this app at zeroLaunch.co"]
    var pageImage = ["background1","background2","background3"]
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if let startingVC = viewControllerAtIndex(index: 0){
            setViewControllers([startingVC], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        }
        dataSource = self
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughViewController).index
        index += 1
        return viewControllerAtIndex(index:index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughViewController).index
        index -= 1
        return viewControllerAtIndex(index:index)
    }
    
    func viewControllerAtIndex(index:Int) -> WalkthroughViewController? {
        if index < 0 || index >= pageContent.count {
            return nil
        }
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            pageContentVC.content = pageContent[index]
            pageContentVC.index = index
            pageContentVC.imageFileName = pageImage[index]
            return pageContentVC
        }
        return nil
    }
    
    func forward(index: Int) {
        if let nextVC = viewControllerAtIndex(index: index + 1) {
            setViewControllers([nextVC], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        }
    }
    
}
