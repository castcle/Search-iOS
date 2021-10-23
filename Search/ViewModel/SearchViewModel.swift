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
//  SearchViewModel.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 12/10/2564 BE.
//

import Foundation
import Networking
import SwiftyJSON

final class SearchViewModel {
   
    private var searchRepository: SearchRepository = SearchRepositoryImpl()
    var searchRequest: SearchRequest = SearchRequest()
    let tokenHelper: TokenHelper = TokenHelper()
    var topTrend: TopTrend = TopTrend()
    
    public func getTopTrends() {
        self.searchRepository.getTopTrends(searchRequest: self.searchRequest)  { (success, response, isRefreshToken) in
            if success {
                do {
                    let rawJson = try response.mapJSON()
                    let json = JSON(rawJson)
                    self.topTrend = TopTrend(json: json)
                    self.didLoadTopTrendFinish?()
                } catch {
                    
                }
            } else {
                if isRefreshToken {
                    self.tokenHelper.refreshToken()
                }
            }
        }
    }
    
    //MARK: Output
    var didLoadTopTrendFinish: (() -> ())?
    
    public init() {
        self.getTopTrends()
        self.tokenHelper.delegate = self
    }
}

extension SearchViewModel: TokenHelperDelegate {
    public func didRefreshTokenFinish() {
        self.getTopTrends()
    }
}
