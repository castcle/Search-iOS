//  Copyright (c) 2021, Castcle and/or its affiliates. All rights reserved.
//  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
//
//  This code is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 only, as
//  published by the Free Software Foundation.
//
//  This code is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
//  version 3 for more details (a copy is included in the LICENSE file that
//  accompanied this code).
//
//  You should have received a copy of the GNU General Public License version
//  3 along with this work; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
//
//  Please contact Castcle, 22 Phet Kasem 47/2 Alley, Bang Khae, Bangkok,
//  Thailand 10160, or visit www.castcle.com if you need additional information
//  or have any questions.
//
//  SearchResultViewController.swift
//  Search
//
//  Created by Tanakorn Phoochaliaw on 23/9/2564 BE.
//

import UIKit
import Core
import Defaults
import XLPagerTabStrip

class SearchResultViewController: ButtonBarPagerTabStripViewController, UITextFieldDelegate {

    @IBOutlet var searchView: UIView!
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var searchContainerView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var emptyTitleLabel: UILabel!
    @IBOutlet var emptyDetailLabel: UILabel!
    @IBOutlet var clearButton: UIButton!
    
    enum SearchViewControllerSection: Int, CaseIterable {
        case search = 0
        case trendingHeader
        case trending
    }
    
    var isSearch: Bool = true
    var searchText: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settings.style.buttonBarBackgroundColor = UIColor.Asset.darkGraphiteBlue
        settings.style.buttonBarItemBackgroundColor = UIColor.Asset.darkGraphiteBlue
        settings.style.selectedBarBackgroundColor = UIColor.Asset.white
        settings.style.buttonBarItemTitleColor = UIColor.Asset.white
        settings.style.selectedBarHeight = 4
        settings.style.buttonBarItemFont = UIFont.asset(.medium, fontSize: .body)
        settings.style.buttonBarHeight = 60.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.hideKeyboardWhenTapped()
        self.setupNavBar()
        self.searchView.custom(color: UIColor.Asset.darkGray, cornerRadius: 18, borderWidth: 1, borderColor: UIColor.Asset.darkGraphiteBlue)
        self.searchImage.image = UIImage.init(icon: .castcle(.search), size: CGSize(width: 25, height: 25), textColor: UIColor.Asset.white)
        self.searchTextField.font = UIFont.asset(.regular, fontSize: .overline)
        self.searchTextField.textColor = UIColor.Asset.white
        self.searchContainerView.backgroundColor = UIColor.Asset.darkGray
        self.emptyTitleLabel.font = UIFont.asset(.regular, fontSize: .body)
        self.emptyTitleLabel.textColor = UIColor.Asset.white
        self.emptyDetailLabel.font = UIFont.asset(.regular, fontSize: .body)
        self.emptyDetailLabel.textColor = UIColor.Asset.lightGray
        self.clearButton.setImage(UIImage.init(icon: .castcle(.incorrect), size: CGSize(width: 15, height: 15), textColor: UIColor.Asset.white).withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.searchTextField.delegate = self
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = UIColor.Asset.lightGray
            newCell?.label.textColor = UIColor.Asset.white
        }
        
        if isSearch {
            self.buttonBarView.isHidden = true
            self.containerView.isHidden = true
            self.clearButton.isHidden = true
            self.emptyView.isHidden = true
        } else {
            self.buttonBarView.isHidden = false
            self.containerView.isHidden = false
            self.clearButton.isHidden = false
            self.emptyView.isHidden = true
            self.searchTextField.text = self.searchText
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults[.screenId] = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isSearch {
            self.searchTextField.becomeFirstResponder()
        }
    }
    
    func setupNavBar() {
        self.customNavigationBar(.secondary, title: "Search", animated: !self.isSearch)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.isSearch {
            self.emptyView.isHidden = false
        }
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text!.isEmpty {
            self.clearButton.isHidden = true
        } else {
            self.clearButton.isHidden = false
        }
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let vc1 = SearchOpener.open(.searchFeed) as? SearchFeedViewController
        vc1?.pageIndex = 0
        vc1?.pageTitle = "Treand"
        let child_1 = vc1 ?? SearchFeedViewController()
        
        let vc2 = SearchOpener.open(.searchFeed) as? SearchFeedViewController
        vc2?.pageIndex = 1
        vc2?.pageTitle = "Lastest"
        let child_2 = vc2 ?? SearchFeedViewController()
        
        let vc3 = SearchOpener.open(.searchFeed) as? SearchFeedViewController
        vc3?.pageIndex = 2
        vc3?.pageTitle = "Photo"
        let child_3 = vc3 ?? SearchFeedViewController()
        
        let vc4 = SearchOpener.open(.searchFeed) as? SearchFeedViewController
        vc4?.pageIndex = 3
        vc4?.pageTitle = "People"
        let child_4 = vc4 ?? SearchFeedViewController()

        return [child_1, child_2, child_3, child_4]
    }
    
    @IBAction func clearAction(_ sender: Any) {
        self.clearButton.isHidden = true
        self.searchTextField.text = ""
    }
}