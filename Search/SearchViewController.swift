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
    
    func castcleTabbar(didSelectButtonBar button: Int) {
        print(button)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
