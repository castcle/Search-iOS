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
//  Localizable.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 9/1/2565 BE.
//

import Core

extension Localization {

    // MARK: - Search (Top Trends)
    public enum SearchTopTrends {
        case title
        case placeholder
        case topTen
        case trending
        case cast

        public var text: String {
            switch self {
            case .title:
                return "search_top_trends_title".localized(bundle: ConfigBundle.search)
            case .placeholder:
                return "search_top_trends_placeholder".localized(bundle: ConfigBundle.search)
            case .topTen:
                return "search_top_trends_top_ten".localized(bundle: ConfigBundle.search)
            case .trending:
                return "search_top_trends_trending".localized(bundle: ConfigBundle.search)
            case .cast:
                return "search_top_trends_cast".localized(bundle: ConfigBundle.search)
            }
        }
    }

    // MARK: - Search (Suggestion)
    public enum SearchSuggestion {
        case title
        case lastest

        public var text: String {
            switch self {
            case .title:
                return "search_suggestion_title".localized(bundle: ConfigBundle.search)
            case .lastest:
                return "search_suggestion_lastest".localized(bundle: ConfigBundle.search)
            }
        }
    }

    // MARK: - Search (Result)
    public enum SearchResult {
        case trend
        case lastest
        case photo
        case people

        public var text: String {
            switch self {
            case .trend:
                return "search_result_trend".localized(bundle: ConfigBundle.search)
            case .lastest:
                return "search_result_lastest".localized(bundle: ConfigBundle.search)
            case .photo:
                return "search_result_photo".localized(bundle: ConfigBundle.search)
            case .people:
                return "search_result_people".localized(bundle: ConfigBundle.search)
            }
        }
    }

    // MARK: - Search (Not found)
    public enum SearchNotFound {
        case headline
        case description

        public var text: String {
            switch self {
            case .headline:
                return "search_not_found_headline".localized(bundle: ConfigBundle.search)
            case .description:
                return "search_not_found_description".localized(bundle: ConfigBundle.search)
            }
        }
    }
}
