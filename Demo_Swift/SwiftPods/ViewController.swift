//
//  ViewController.swift
//  SwiftPods
//
//  Created by mlibai on 2016/11/29.
//  Copyright © 2016年 mlibai. All rights reserved.
//

import UIKit

import XZMenuView

class ViewController: UIViewController {

    @IBOutlet weak var menuWrapperView: UIView!
    var menuView: XZMenuView!
    weak var pageViewController: UIPageViewController!
    var items = ["新闻联播", "焦点访谈", "生活圈梦想星搭档", "人口", "了不起的挑战", "客从何处来", "中国味道", "我爱妈妈", "挑战不可能", "出彩中国人", "等着我", "舞出我人生", "吉尼斯中国之夜", "今日说法", "人与自然", "撒贝宁时间", "喜乐街"];
    var viewControllers = [Int: UIViewController]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.menuView = XZMenuView(frame: self.menuWrapperView.bounds);
        menuView.dataSource = self;
        menuView.delegate = self;
        menuView.indicatorStyle = .default;
        menuView.indicatorPosition = .bottom;
        menuView.indicatorColor = UIColor.orange;
        self.menuWrapperView.addSubview(menuView);
        
        self.pageViewController.setViewControllers([self.viewController(at: 0)!], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil);
        menuView.setSelectedIndex(0, animated: false);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UIPageViewController" {
            self.pageViewController = segue.destination as! UIPageViewController;
            pageViewController.delegate = self;
            pageViewController.dataSource = self;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewController(at page: Int?) -> UIViewController? {
        if let page = page {
            if page < items.count && page >= 0 {
                var vc = self.viewControllers[page];
                if vc == nil {
                    vc = UIViewController();
                    vc!.view.backgroundColor = UIColor(red: CGFloat(arc4random()) / CGFloat(UInt32.max), green: CGFloat(arc4random()) / CGFloat(UInt32.max), blue: CGFloat(arc4random()) / CGFloat(UInt32.max), alpha: 1.0);
                    viewControllers[page] = vc;
                }
                return vc;
            }
        }
        return nil;
    }
    
    func page(of viewController: UIViewController?) -> Int? {
        if let tmp = viewController {
            for (page, vc) in viewControllers {
                if vc == tmp {
                    return page;
                }
            }
        }
        return nil;
    }
}

extension ViewController: XZMenuViewDelegate, XZMenuViewDataSource {
    func numberOfItems(in meunView: XZMenuView) -> Int {
        return items.count;
    }
    
    func menuView(_ menuView: XZMenuView, viewForItemAt index: Int, reusing reusingView: UIView?) -> UIView? {
        var menuItemView: XZPlainMenuItemView? = reusingView as! XZPlainMenuItemView? ;
        
        if menuItemView == nil {
            menuItemView = XZPlainMenuItemView(transitionOptions: [.scale, .color])
            menuItemView!.setTextColor(UIColor.black, for: .normal);
            menuItemView!.setTextColor(UIColor.orange, for: .selected);
        }
        
        menuItemView!.textLabel.text = items[index];
        return menuItemView;
    }
    
    func menuView(_ menuView: XZMenuView, widthForItemAt index: Int) -> CGFloat {
        let item = items[index];
        let count: Double = Double(item.characters.count);
        let width = (count * 17.0 + 20.0);
        return CGFloat(width);
    }
}

extension ViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let page = self.page(of: viewController) {
            return self.viewController(at: page - 1);
        }
        return nil;
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let page = self.page(of: viewController) {
            return self.viewController(at: page + 1);
        }
        return nil;
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.menuView.beginTransition(pageViewController.viewControllers?.first?.view);
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.menuView.endTransition();
        if finished && completed {
            self.menuView.setSelectedIndex(UInt(self.page(of: pageViewController.viewControllers?.last)!), animated: true);
        }
    }
}

