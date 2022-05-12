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
//  SearchResualViewModel.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 14/10/2564 BE.
//

import Foundation
import Core
import Networking
import RealmSwift
import SwiftyJSON

final public class SearchResualViewModel {

    var searchText: String = ""
    var isShowRecent: Bool = false
    var recentSearch: Results<RecentSearch>!
    var searchResualState: SearchResualState = .unknow
    private var searchRepository: SearchRepository = SearchRepositoryImpl()
    var searchRequest: SearchRequest = SearchRequest()
    var suggestions: Suggestion = Suggestion()
    let tokenHelper: TokenHelper = TokenHelper()
    var searchFeedState: SearchFeedState = .unknow
    var notification: Notification.Name = .getSearchFeedNotification()

    // MARK: - Output
    var didGetSuggestionFinish: (() -> Void)?

    public init(state: SearchResualState = .unknow, textSearch: String = "", searchFeedState: SearchFeedState = .unknow) {
        self.searchResualState = state
        self.searchText = textSearch
        self.searchRequest.keyword = textSearch
        self.searchFeedState = searchFeedState
        do {
            let realm = try Realm()
            self.recentSearch = realm.objects(RecentSearch.self)
        } catch {}
        self.tokenHelper.delegate = self
    }

    func getSuggestion() {
        self.searchRequest.keyword = self.searchText
        self.searchRepository.getSuggestion(searchRequest: self.searchRequest) { (success, response, isRefreshToken) in
            if success {
                do {
                    let rawJson = try response.mapJSON()
                    let json = JSON(rawJson)
                    self.suggestions = Suggestion(json: json)
                    self.didGetSuggestionFinish?()
                } catch {}
            } else {
                if isRefreshToken {
                    self.tokenHelper.refreshToken()
                }
            }
        }
    }

    func addRecentSearch(value: String) {
        do {
            let realm = try Realm()
            try realm.write {
                let valueSearch = RecentSearch()
                valueSearch.value = value
                realm.add(valueSearch, update: .modified)
            }
        } catch {}
    }
}

extension SearchResualViewModel: TokenHelperDelegate {
    public func didRefreshTokenFinish() {
        self.getSuggestion()
    }
}
