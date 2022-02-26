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
//  SearchUserViewController.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 24/1/2565 BE.
//

import UIKit
import Core
import Component
import Profile
import XLPagerTabStrip

class SearchUserViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var pageIndex: Int = 0
    var pageTitle: String?
    
    var viewModel = SearchUserViewModel(noti: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.configureTableView()
        self.viewModel.delegate = self
        self.tableView.cr.addHeadRefresh(animator: FastAnimator()) {
            self.tableView.cr.resetNoMore()
            self.tableView.isScrollEnabled = false
            self.viewModel.searchUserLoaded = false
            self.tableView.reloadData()
            self.viewModel.reloadData()
        }
        
        self.tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            if self.viewModel.searchUserCanLoad {
                self.viewModel.searchUserMore()
            } else {
                self.tableView.cr.noticeNoMoreData()
            }
        }
        
        if !self.viewModel.searchUserLoaded {
            self.tableView.isScrollEnabled = false
            if let searchUdid: String = self.viewModel.notification?.rawValue, let keyword: String = UserDefaults.standard.string(forKey: searchUdid) {
                self.viewModel.reloadData(with: keyword)
            } else {
                if !self.viewModel.searchRequest.keyword.isEmpty {
                    self.viewModel.reloadData(with: "")
                }
            }
            
        } else {
            self.tableView.isScrollEnabled = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getSearchUser(notification:)), name: self.viewModel.notification, object: nil)
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.searchNotFound, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.searchNotFound)
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.userSearch, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.userSearch)
        self.tableView.registerFeedCell()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    @objc func getSearchUser(notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let searchText = dict["searchText"] as? String {
                self.viewModel.reloadData(with: searchText)
                self.tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: true)
                self.tableView.isScrollEnabled = false
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.viewModel.searchUserLoaded {
            if self.viewModel.users.isEmpty {
                return 1
            } else {
                return self.viewModel.users.count
            }
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.viewModel.searchUserLoaded {
            if self.viewModel.users.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.searchNotFound, for: indexPath as IndexPath) as? SearchNotFoundTableViewCell
                cell?.backgroundColor = UIColor.Asset.darkGraphiteBlue
                cell?.configCell()
                return cell ?? SearchNotFoundTableViewCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.userSearch, for: indexPath as IndexPath) as? UserSearchTableViewCell
                cell?.backgroundColor = UIColor.Asset.darkGray
                cell?.configCell(user: self.viewModel.users[indexPath.section])
                return cell ?? UserSearchTableViewCell()
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.skeleton, for: indexPath as IndexPath) as? SkeletonUserTableViewCell
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.configCell()
            return cell ?? SkeletonUserTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 5))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.viewModel.searchUserLoaded {
            let user = self.viewModel.users[indexPath.section]
            ProfileOpener.openProfileDetail(user.type, castcleId: user.castcleId, displayName: user.displayName)
        }
    }
}

extension SearchUserViewController: SearchUserViewModelDelegate {
    func didSearchUserSuccess() {
        self.tableView.cr.endHeaderRefresh()
        self.tableView.cr.endLoadingMore()
        self.tableView.isScrollEnabled = true
        self.tableView.reloadData()
    }
}

extension SearchUserViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: pageTitle ?? "Tab \(pageIndex)")
    }
}
