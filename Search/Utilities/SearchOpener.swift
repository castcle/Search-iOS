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
//  SearchOpener.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 6/7/2564 BE.
//

import UIKit
import Core

public enum SearchScene {
    case search
    case searchResult(SearchResualViewModel)
    case searchFeed(SearchFeedViewModel)
    case searchUser(SearchUserViewModel)
}

public struct SearchOpener {
    public static func open(_ searchScene: SearchScene) -> UIViewController {
        switch searchScene {
        case .search:
            let storyboard: UIStoryboard = UIStoryboard(name: SearchNibVars.Storyboard.search, bundle: ConfigBundle.search)
            let vc = storyboard.instantiateViewController(withIdentifier: SearchNibVars.ViewController.search)
            return vc
        case .searchResult(let viewModel):
            let storyboard: UIStoryboard = UIStoryboard(name: SearchNibVars.Storyboard.search, bundle: ConfigBundle.search)
            let vc = storyboard.instantiateViewController(withIdentifier: SearchNibVars.ViewController.searchResult) as? SearchResultViewController
            vc?.viewModel = viewModel
            return vc ?? SearchResultViewController()
        case .searchFeed(let viewModel):
            let storyboard: UIStoryboard = UIStoryboard(name: SearchNibVars.Storyboard.search, bundle: ConfigBundle.search)
            let vc = storyboard.instantiateViewController(withIdentifier: SearchNibVars.ViewController.searchFeed) as? SearchFeedViewController
            vc?.viewModel = viewModel
            return vc ?? SearchFeedViewController()
        case .searchUser(let viewModel):
            let storyboard: UIStoryboard = UIStoryboard(name: SearchNibVars.Storyboard.search, bundle: ConfigBundle.search)
            let vc = storyboard.instantiateViewController(withIdentifier: SearchNibVars.ViewController.searchUser) as? SearchUserViewController
            vc?.viewModel = viewModel
            return vc ?? SearchUserViewController()
        }
    }
}
