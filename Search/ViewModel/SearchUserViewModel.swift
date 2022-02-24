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
//  SearchUserViewModel.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 24/1/2565 BE.
//

import Networking
import SwiftyJSON

public protocol SearchUserViewModelDelegate {
    func didSearchUserSuccess()
}

public enum SearchUserStage {
    case searchUser
    case unknow
}

final public class SearchUserViewModel {
    
    public var delegate: SearchUserViewModelDelegate?
    private var searchRepository: SearchRepository = SearchRepositoryImpl()
    var searchRequest: SearchRequest = SearchRequest()
    let tokenHelper: TokenHelper = TokenHelper()
    var users: [UserInfo] = []
    var meta: Meta = Meta()
    var searchUserLoaded: Bool = false
    var searchUserCanLoad: Bool = true
    var stage: SearchUserStage = .unknow
    var notification: Notification.Name? = nil
    
    private func searchUser() {
        if self.searchRequest.keyword.isEmpty {
            return
        }
        self.searchRepository.searchUser(searchRequest: self.searchRequest) { (success, response, isRefreshToken) in
            if success {
                do {
                    let rawJson = try response.mapJSON()
                    let json = JSON(rawJson)
                    let payload = json[ContentShelfKey.payload.rawValue].arrayValue
                    let meta: Meta = Meta(json: JSON(json[ContentShelfKey.meta.rawValue].dictionaryValue))

                    if meta.resultCount < self.searchRequest.maxResults {
                        self.searchUserCanLoad = false
                    }
                    
                    payload.forEach { content in
                        self.users.append(UserInfo(json: content))
                    }

                    self.meta = meta
                    self.searchUserLoaded = true
                    self.delegate?.didSearchUserSuccess()
                } catch {}
            } else {
                if isRefreshToken {
                    self.tokenHelper.refreshToken()
                }
            }
        }
    }
    
    public init(noti: Notification.Name?, stage: SearchUserStage = .unknow, searchRequest: SearchRequest = SearchRequest()) {
        self.stage = stage
        self.searchRequest = searchRequest
        self.searchRequest.maxResults = 25
        self.notification = noti
        
        if self.stage != .unknow {
            self.searchUser()
        }
        self.tokenHelper.delegate = self
    }
    
    func reloadData(with keywoard: String = "") {
        if !keywoard.isEmpty {
            self.searchRequest.keyword = keywoard
        }
        
        self.users = []
        self.searchUserLoaded = false
        self.searchUserCanLoad = true
        self.searchRequest.maxResults = 25
        self.searchRequest.untilId = ""
        self.stage = .searchUser
        self.searchUser()
    }
    
    func searchUserMore() {
        self.searchRequest.maxResults = 25
        self.searchRequest.untilId = self.meta.oldestId
        self.searchUser()
    }
}

extension SearchUserViewModel: TokenHelperDelegate {
    public func didRefreshTokenFinish() {
        if self.stage != .unknow {
            self.searchUser()
        }
    }
}
