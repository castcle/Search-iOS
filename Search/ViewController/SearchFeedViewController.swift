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
//  SearchFeedViewController.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 23/9/2564 BE.
//

import UIKit
import Core
import Component
import Networking
import Profile
import Authen
import Post
import XLPagerTabStrip

class SearchFeedViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var pageIndex: Int = 0
    var pageTitle: String?
    
    var viewModel = SearchFeedViewModel(stage: .unknow, feedRequest: FeedRequest())
    
    enum FeedCellType {
        case activity
        case header
        case content
        case quote
        case footer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.configureTableView()
        
        self.viewModel.didLoadFeedsFinish = {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getSearchFeed(notification:)), name: .getSearchFeed, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .getSearchFeed, object: nil)
    }
    
    @objc func getSearchFeed(notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let searchText = dict["searchText"] as? String {
                self.viewModel.feedRequest.hashtag = searchText
                self.viewModel.getFeeds()
            }
        }
    }
}

extension SearchFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.feeds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let content = self.viewModel.feeds[section].feedPayload
        if content.isRecast || content.isQuote {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = self.viewModel.feeds[indexPath.section].feedPayload
        if content.isRecast {
            if indexPath.row == 0 {
                return self.renderFeedCell(content: content, cellType: .activity, tableView: tableView, indexPath: indexPath)
            } else if indexPath.row == 1 {
                return self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath)
            } else if indexPath.row == 2 {
                return self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath)
            } else {
                return self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
            }
        } else if content.isQuote {
            if indexPath.row == 0 {
                return self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath)
            } else if indexPath.row == 1 {
                return self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath)
            } else if indexPath.row == 2 {
                return self.renderFeedCell(content: content, cellType: .quote, tableView: tableView, indexPath: indexPath)
            } else {
                return self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
            }
        } else {
            if indexPath.row == 0 {
                return self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath)
            } else if indexPath.row == 1 {
                return self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath)
            } else {
                return self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
            }
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
    
    func renderFeedCell(content: Content, cellType: FeedCellType, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var originalContent = Content()
        if content.isRecast || content.isQuote {
            originalContent = ContentHelper().originalPostToContent(originalPost: content.originalPost)
        }
        
        switch cellType {
        case .activity:
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.activityHeader, for: indexPath as IndexPath) as? ActivityHeaderTableViewCell
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.cellConfig(content: content)
            return cell ?? ActivityHeaderTableViewCell()
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.headerFeed, for: indexPath as IndexPath) as? HeaderTableViewCell
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.delegate = self
            if content.isRecast {
                cell?.content = originalContent
            } else {
                cell?.content = content
            }
            return cell ?? HeaderTableViewCell()
        case .footer:
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.footerFeed, for: indexPath as IndexPath) as? FooterTableViewCell
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.delegate = self
            if content.isRecast {
                cell?.content = originalContent
            } else {
                cell?.content = content
            }
            return cell ?? FooterTableViewCell()
        case .quote:
            return FeedCellHelper().renderQuoteCastCell(content: originalContent, tableView: self.tableView, indexPath: indexPath, isRenderForFeed: true)
        default:
            if content.isRecast {
                return FeedCellHelper().renderFeedCell(content: originalContent, tableView: self.tableView, indexPath: indexPath)
            } else {
                return FeedCellHelper().renderFeedCell(content: content, tableView: self.tableView, indexPath: indexPath)
            }
        }
    }
}

extension SearchFeedViewController: HeaderTableViewCellDelegate {
    func didRemoveSuccess(_ headerTableViewCell: HeaderTableViewCell) {
        // Remove success
    }
    
    func didTabProfile(_ headerTableViewCell: HeaderTableViewCell, author: Author) {
        if author.type == .page {
            ProfileOpener.openProfileDetail(author.type, castcleId: nil, displayName: "", page: Page().initCustom(displayName: author.displayName, castcleId: author.castcleId))
        } else {
            ProfileOpener.openProfileDetail(author.type, castcleId: author.castcleId, displayName: author.displayName, page: nil)
        }
    }
    
    func didAuthen(_ headerTableViewCell: HeaderTableViewCell) {
        Utility.currentViewController().presentPanModal(AuthenOpener.open(.signUpMethod) as! SignUpMethodViewController)
    }
}

extension SearchFeedViewController: FooterTableViewCellDelegate {
    func didTabComment(_ footerTableViewCell: FooterTableViewCell, content: Content) {
        let commentNavi: UINavigationController = UINavigationController(rootViewController: ComponentOpener.open(.comment(CommentViewModel(content: content))))
        commentNavi.modalPresentationStyle = .fullScreen
        commentNavi.modalTransitionStyle = .crossDissolve
        Utility.currentViewController().present(commentNavi, animated: true)
    }
    
    func didTabQuoteCast(_ footerTableViewCell: FooterTableViewCell, content: Content, page: Page) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
            let vc = PostOpener.open(.post(PostViewModel(postType: .quoteCast, content: content, page: page)))
            vc.modalPresentationStyle = .fullScreen
            Utility.currentViewController().present(vc, animated: true, completion: nil)
        }
    }
    
    func didAuthen(_ footerTableViewCell: FooterTableViewCell) {
        Utility.currentViewController().presentPanModal(AuthenOpener.open(.signUpMethod) as! SignUpMethodViewController)
    }
}

extension SearchFeedViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: pageTitle ?? "Tab \(pageIndex)")
    }
}

extension SearchFeedViewController {
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.headerFeed, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.headerFeed)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.footerFeed, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.footerFeed)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.postText, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.postText)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.postLink, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.postLink)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.postLinkPreview, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.postLinkPreview)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.imageX1, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.imageX1)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.imageX2, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.imageX2)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.imageX3, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.imageX3)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.imageXMore, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.imageXMore)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.blog, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.blog)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.blogNoImage, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.blogNoImage)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.activityHeader, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.activityHeader)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteText, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteText)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteLink, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteLink)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteLinkPreview, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteLinkPreview)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteImageX1, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteImageX1)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteImageX2, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteImageX2)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteImageX3, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteImageX3)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteImageXMore, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteImageXMore)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteBlog, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteBlog)
        self.tableView.register(UINib(nibName: ComponentNibVars.TableViewCell.quoteBlogNoImage, bundle: ConfigBundle.component), forCellReuseIdentifier: ComponentNibVars.TableViewCell.quoteBlogNoImage)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
}
