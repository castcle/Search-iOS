//
//  SearchFeedViewController.swift
//  Search
//
//  Created by Tanakorn Phoochaliaw on 23/9/2564 BE.
//

import UIKit
import XLPagerTabStrip

class SearchFeedViewController: UIViewController {

    var pageIndex: Int = 0
    var pageTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
    }
}

extension SearchFeedViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: pageTitle ?? "Tab \(pageIndex)")
    }
}
