//
//  SearchViewController.swift
//  Search
//
//  Created by Tanakorn Phoochaliaw on 6/7/2564 BE.
//

import UIKit
import Component

class SearchViewController: UIViewController, CastcleTabbarDeleDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.customNavigationBar(.secondary, title: "For You", rightBarButton: [.menu])
        SearchViewController.castcleTabbarDelegate = self
    }
    
    func castcleTabbar(didSelectButtonBar button: BarButtonActionType) {
        print(button)
    }
}
