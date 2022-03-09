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
//  SearchViewController.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 6/7/2564 BE.
//

import UIKit
import Core
import Networking
import Defaults

class SearchViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var viewModel = SearchViewModel()
    
    enum SearchViewControllerSection: Int, CaseIterable {
        case search = 0
        case trendingHeader
        case trending
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.configureTableView()
        self.viewModel.getTopTrends()
        
        self.viewModel.didLoadTopTrendFinish = {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavBar()
        self.tableView.reloadData()
        Defaults[.screenId] = ScreenId.search.rawValue
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EngagementHelper().sendCastcleAnalytic(event: .onScreenView, screen: .search)
    }
    
    func setupNavBar() {
        self.customNavigationBar(.primary, title: Localization.searchTopTrends.title.text, textColor: UIColor.Asset.lightBlue, leftBarButton: .logo)
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.searchTextField, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.searchTextField)
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.searchTitle, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.searchTitle)
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.searchTrend, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.searchTrend)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchViewControllerSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SearchViewControllerSection.trending.rawValue {
            return self.viewModel.topTrend.hashtags.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SearchViewControllerSection.search.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.searchTextField, for: indexPath as IndexPath) as? SearchTextFieldTableViewCell
            cell?.configCell()
            cell?.backgroundColor = UIColor.Asset.darkGray
            return cell ?? SearchTextFieldTableViewCell()
        case SearchViewControllerSection.trendingHeader.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.searchTitle, for: indexPath as IndexPath) as? SearchHeaderTableViewCell
            cell?.backgroundColor = UIColor.clear
            cell?.configCell()
            return cell ?? SearchHeaderTableViewCell()
        case SearchViewControllerSection.trending.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.searchTrend, for: indexPath as IndexPath) as? SearchTrendTableViewCell
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.configCell(hastag: self.viewModel.topTrend.hashtags[indexPath.row])
            return cell ?? SearchTrendTableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SearchViewControllerSection.trending.rawValue {
            let vc = SearchOpener.open(.searchResult(SearchResualViewModel(state: .resualt, textSearch: self.viewModel.topTrend.hashtags[indexPath.row].slug, searchFeedState: .getFeed)))
            Utility.currentViewController().navigationController?.pushViewController(vc, animated: true)
        }
    }
}
