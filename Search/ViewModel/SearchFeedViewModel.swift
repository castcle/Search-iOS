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
//  SearchFeedViewModel.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 25/9/2564 BE.
//

import Core
import Foundation
import Networking
import SwiftyJSON

public enum SearchFeedStage {
    case getFeed
    case unknow
}

final public class SearchFeedViewModel {
   
    private var searchRepository: SearchRepository = SearchRepositoryImpl()
    var searchRequest: SearchRequest = SearchRequest()
    let tokenHelper: TokenHelper = TokenHelper()
    var searchContents: [Content] = []
    var meta: Meta = Meta()
    var searchLoaded: Bool = false
    var searchCanLoad: Bool = true
    var stage: SearchFeedStage = .unknow
    var searchSection: SearchSection

    func searchTrend() {
        self.searchRepository.searchTrend(searchRequest: self.searchRequest) { (success, response, isRefreshToken) in
            if success {
                do {
                    let rawJson = try response.mapJSON()
                    let json = JSON(rawJson)
                    let shelf = ContentShelf(json: json)
                    if shelf.meta.resultCount < self.searchRequest.maxResults {
                        self.searchCanLoad = false
                    }
                    self.searchContents.append(contentsOf: shelf.contents)
                    self.meta = shelf.meta
                    self.searchLoaded = true
                    self.didLoadFeedsFinish?()
                } catch {}
            } else {
                if isRefreshToken {
                    self.tokenHelper.refreshToken()
                }
            }
        }
    }
    
    func searchRecent() {
        self.searchRepository.searchRecent(searchRequest: self.searchRequest) { (success, response, isRefreshToken) in
            if success {
                do {
                    let rawJson = try response.mapJSON()
                    let json = JSON(rawJson)
                    let shelf = ContentShelf(json: json)
                    if shelf.meta.resultCount < self.searchRequest.maxResults {
                        self.searchCanLoad = false
                    }
                    self.searchContents.append(contentsOf: shelf.contents)
                    self.meta = shelf.meta
                    self.searchLoaded = true
                    self.didLoadFeedsFinish?()
                } catch {}
            } else {
                if isRefreshToken {
                    self.tokenHelper.refreshToken()
                }
            }
        }
    }
    
    //MARK: Output
    var didLoadFeedsFinish: (() -> ())?
    
    public init(searchSection: SearchSection, stage: SearchFeedStage = .unknow, searchRequest: SearchRequest = SearchRequest()) {
        self.stage = stage
        self.searchRequest = searchRequest
        self.searchRequest.maxResults = 5
        self.searchSection = searchSection
        if self.stage != .unknow {
            if self.searchSection == .trend {
                self.searchTrend()
            } else if self.searchSection == .lastest {
                self.searchRecent()
            } else if self.searchSection == .photo {
                self.searchRequest.type = .photo
                self.searchTrend()
            }
        }
        self.tokenHelper.delegate = self
    }
    
    func reloadData(with keywoard: String = "") {
        if !keywoard.isEmpty {
            self.searchRequest.keyword = keywoard
        }
        
        self.searchRequest.maxResults = 5
        self.searchLoaded = false
        self.searchCanLoad = true
        self.searchRequest.untilId = ""
        if self.stage != .unknow {
            if self.searchSection == .trend {
                self.searchTrend()
            } else if self.searchSection == .lastest {
                self.searchRecent()
            } else if self.searchSection == .photo {
                self.searchRequest.type = .photo
                self.searchTrend()
            }
        }
    }
}

extension SearchFeedViewModel: TokenHelperDelegate {
    public func didRefreshTokenFinish() {
        if self.stage != .unknow {
            if self.searchSection == .trend {
                self.searchTrend()
            } else if self.searchSection == .lastest {
                self.searchRecent()
            } else if self.searchSection == .photo {
                self.searchRequest.type = .photo
                self.searchTrend()
            }
        }
    }
}
