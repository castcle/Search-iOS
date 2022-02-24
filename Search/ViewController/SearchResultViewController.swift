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
//  Created by Castcle Co., Ltd. on 23/9/2564 BE.
//

import UIKit
import Core
import Profile
import Defaults
import XLPagerTabStrip

class SearchResultViewController: ButtonBarPagerTabStripViewController, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var searchContainerView: UIView!
    @IBOutlet var resultView: UIView!
    @IBOutlet var clearButton: UIButton!
    
    enum SearchResultViewControllerSection: Int, CaseIterable {
        case recentHeader = 0
        case recent
        case keyword
        case follow
        case hastag
    }
    
    var viewModel = SearchResualViewModel()
    var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupButtonBar()
    }
    
    private func setupButtonBar() {
        settings.style.buttonBarBackgroundColor = UIColor.Asset.darkGraphiteBlue
        settings.style.buttonBarItemBackgroundColor = UIColor.Asset.darkGraphiteBlue
        settings.style.selectedBarBackgroundColor = UIColor.Asset.white
        settings.style.buttonBarItemTitleColor = UIColor.Asset.white
        settings.style.selectedBarHeight = 4
        settings.style.buttonBarItemFont = UIFont.asset(.bold, fontSize: .body)
        settings.style.buttonBarHeight = 60.0
        
        self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = UIColor.Asset.lightGray
            newCell?.label.textColor = UIColor.Asset.white
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.hideKeyboardWhenTapped()
        self.configureTableView()
        self.searchView.custom(color: UIColor.Asset.darkGray, cornerRadius: 18, borderWidth: 1, borderColor: UIColor.Asset.darkGraphiteBlue)
        self.searchImage.image = UIImage.init(icon: .castcle(.search), size: CGSize(width: 25, height: 25), textColor: UIColor.Asset.white)
        self.searchTextField.font = UIFont.asset(.regular, fontSize: .overline)
        self.searchTextField.textColor = UIColor.Asset.white
        self.searchContainerView.backgroundColor = UIColor.Asset.darkGray
        self.clearButton.setImage(UIImage.init(icon: .castcle(.incorrect), size: CGSize(width: 15, height: 15), textColor: UIColor.Asset.white).withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.searchTextField.delegate = self
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        self.updateUI()
        
        self.viewModel.didGetSuggestionFinish = {
            if !self.viewModel.suggestions.keyword.isEmpty || !self.viewModel.suggestions.follows.isEmpty || !self.viewModel.suggestions.hashtags.isEmpty {
                self.tableView.reloadData()
            }
        }
    }
    
    private func updateUI() {
        if self.viewModel.searchResualState == .resualt {
            self.tableView.isHidden = true
            self.resultView.isHidden = false
            self.searchTextField.text = self.viewModel.searchText
        } else {
            self.tableView.isHidden = false
            self.resultView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavBar()
        Defaults[.screenId] = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.viewModel.searchResualState == .initial {
            self.viewModel.isShowRecent = true
            self.searchTextField.becomeFirstResponder()
        }
    }
    
    func setupNavBar() {
        if self.viewModel.searchResualState == .initial {
            self.customNavigationBar(.secondary, title: Localization.searchSuggestion.title.text, animated: false)
        } else {
            self.customNavigationBar(.secondary, title: Localization.searchSuggestion.title.text, animated: true)
        }
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.recentSearchHeader, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.recentSearchHeader)
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.recentSearch, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.recentSearch)
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.suggestionUser, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.suggestionUser)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.timer?.invalidate()
        
        let searchValue = textField.text ?? ""
        if self.viewModel.searchResualState == .initial {
            self.tableView.isHidden = true
            if !(searchValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                self.viewModel.addRecentSearch(value: searchValue.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        if !(searchValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            self.sendSearch(keyword: searchValue.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text!.isEmpty {
            self.clearButton.isHidden = true
            self.viewModel.searchResualState = .initial
            self.tableView.reloadData()
        } else {
            self.clearButton.isHidden = false
            if textField.text!.hasPrefix("#") {
                self.viewModel.searchResualState = .hastag
            } else {
                self.viewModel.searchResualState = .suggest
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        self.timer?.invalidate()

        let currentText = textField.text ?? ""
        if (currentText as NSString).replacingCharacters(in: range, with: string).count >= 1 {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSearch), userInfo: nil, repeats: false)
        }
        
        return true
    }

    @objc func performSearch() {
        if self.viewModel.searchResualState != .resualt {
            self.viewModel.searchText = self.searchTextField.text ?? ""
            self.viewModel.getSuggestion()
        }
    }
    
    private func sendSearch(keyword: String) {
        self.viewModel.searchText = keyword
        let searchDataDict: [String: String] = ["searchText": keyword]
        let searchUdid: String = self.viewModel.notification.rawValue
        UserDefaults.standard.set(keyword, forKey: searchUdid)
        NotificationCenter.default.post(name: self.viewModel.notification, object: nil, userInfo: searchDataDict)
        self.viewModel.searchResualState = .resualt
        self.updateUI()
        self.viewModel.addRecentSearch(value: keyword)
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let vc1 = SearchOpener.open(.searchFeed(SearchFeedViewModel(searchSection: .trend, noti: self.viewModel.notification, stage: self.viewModel.searchFeedStage, searchRequest:  self.viewModel.searchRequest))) as? SearchFeedViewController
        vc1?.pageIndex = 0
        vc1?.pageTitle = Localization.searchResult.trend.text
        let trend = vc1 ?? SearchFeedViewController()
        
        let vc2 = SearchOpener.open(.searchFeed(SearchFeedViewModel(searchSection: .lastest, noti: self.viewModel.notification, stage: self.viewModel.searchFeedStage, searchRequest:  self.viewModel.searchRequest))) as? SearchFeedViewController
        vc2?.pageIndex = 1
        vc2?.pageTitle = Localization.searchResult.lastest.text
        let lastest = vc2 ?? SearchFeedViewController()
        
        let vc3 = SearchOpener.open(.searchFeed(SearchFeedViewModel(searchSection: .photo, noti: self.viewModel.notification, stage: self.viewModel.searchFeedStage, searchRequest:  self.viewModel.searchRequest))) as? SearchFeedViewController
        vc3?.pageIndex = 2
        vc3?.pageTitle = Localization.searchResult.photo.text
        let photo = vc3 ?? SearchFeedViewController()
        
        let vc4 = SearchOpener.open(.searchUser(SearchUserViewModel(noti: self.viewModel.notification, searchRequest: self.viewModel.searchRequest))) as? SearchUserViewController
        vc4?.pageIndex = 3
        vc4?.pageTitle = Localization.searchResult.people.text
        let people = vc4 ?? SearchFeedViewController()

        return [trend, lastest, photo, people]
    }
    
    @IBAction func clearAction(_ sender: Any) {
        self.clearButton.isHidden = true
        self.searchTextField.text = ""
        self.viewModel.searchResualState = .initial
        self.tableView.reloadData()
    }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchResultViewControllerSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SearchResultViewControllerSection.recentHeader.rawValue:
            if self.viewModel.searchResualState == .initial && self.viewModel.recentSearch.count != 0 {
                return 1
            } else {
                return 0
            }
        case SearchResultViewControllerSection.recent.rawValue:
            if self.viewModel.searchResualState == .initial && self.viewModel.recentSearch.count != 0 {
                return self.viewModel.recentSearch.count
            } else {
                return 0
            }
        case SearchResultViewControllerSection.keyword.rawValue:
            if self.viewModel.searchResualState == .suggest {
                return self.viewModel.suggestions.keyword.count
            } else {
                return 0
            }
        case SearchResultViewControllerSection.follow.rawValue:
            if self.viewModel.searchResualState == .suggest {
                return self.viewModel.suggestions.follows.count
            } else {
                return 0
            }
        case SearchResultViewControllerSection.hastag.rawValue:
            if self.viewModel.searchResualState == .hastag {
                return self.viewModel.suggestions.hashtags.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SearchResultViewControllerSection.recentHeader.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.recentSearchHeader, for: indexPath as IndexPath) as? RecentHeaderSearchTableViewCell
            cell?.backgroundColor = UIColor.Asset.darkGraphiteBlue
            cell?.configCell(display: Localization.searchSuggestion.lastest.text)
            return cell ?? RecentHeaderSearchTableViewCell()
        case SearchResultViewControllerSection.recent.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.recentSearch, for: indexPath as IndexPath) as? RecentSearchTableViewCell
            let recentSearch = self.viewModel.recentSearch[indexPath.row]
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.configCell(display: recentSearch.value)
            return cell ?? RecentSearchTableViewCell()
        case SearchResultViewControllerSection.keyword.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.recentSearch, for: indexPath as IndexPath) as? RecentSearchTableViewCell
            let keyword = self.viewModel.suggestions.keyword[indexPath.row]
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.configCell(display: keyword.text)
            return cell ?? RecentSearchTableViewCell()
        case SearchResultViewControllerSection.follow.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.suggestionUser, for: indexPath as IndexPath) as? SuggestionUserTableViewCell
            let follow = self.viewModel.suggestions.follows[indexPath.row]
            cell?.backgroundColor = UIColor.Asset.darkGraphiteBlue
            cell?.configCell(follow: follow)
            return cell ?? SuggestionUserTableViewCell()
        case SearchResultViewControllerSection.hastag.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.recentSearch, for: indexPath as IndexPath) as? RecentSearchTableViewCell
            let hashtag = self.viewModel.suggestions.hashtags[indexPath.row]
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.configCell(display: hashtag.name)
            return cell ?? RecentSearchTableViewCell()
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SearchResultViewControllerSection.recent.rawValue:
            let recentSearch = self.viewModel.recentSearch[indexPath.row]
            self.sendSearch(keyword: recentSearch.value)
        case SearchResultViewControllerSection.keyword.rawValue:
            let keyword = self.viewModel.suggestions.keyword[indexPath.row]
            self.sendSearch(keyword: keyword.text)
        case SearchResultViewControllerSection.follow.rawValue:
            let follow = self.viewModel.suggestions.follows[indexPath.row]
            ProfileOpener.openProfileDetail(follow.type, castcleId: follow.castcleId, displayName: follow.displayName)
        case SearchResultViewControllerSection.hastag.rawValue:
            let hashtag = self.viewModel.suggestions.hashtags[indexPath.row]
            self.sendSearch(keyword: hashtag.name)
        default:
            return
        }
    }
}
