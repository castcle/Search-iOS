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
    
    var viewModel = SearchFeedViewModel(searchSection: .none, noti: nil)
    
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
        
        self.viewModel.delegate = self
        self.tableView.cr.addHeadRefresh(animator: FastAnimator()) {
            self.tableView.cr.resetNoMore()
            self.tableView.isScrollEnabled = false
            self.viewModel.searchLoaded = false
            self.tableView.reloadData()
            self.viewModel.reloadData()
        }
        
        self.tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            if self.viewModel.searchCanLoad {
                self.viewModel.getSearchContent()
            } else {
                self.tableView.cr.noticeNoMoreData()
            }
        }
        
        if !self.viewModel.searchLoaded {
            self.tableView.isScrollEnabled = false
            if let searchUdid: String = self.viewModel.notification?.rawValue, let keyword: String = UserDefaults.standard.string(forKey: searchUdid) {
                self.viewModel.reloadData(with: keyword)
            }
        } else {
            self.tableView.isScrollEnabled = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getSearchFeed(notification:)), name: self.viewModel.notification, object: nil)
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: SearchNibVars.TableViewCell.searchNotFound, bundle: ConfigBundle.search), forCellReuseIdentifier: SearchNibVars.TableViewCell.searchNotFound)
        self.tableView.registerFeedCell()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    @objc func getSearchFeed(notification: NSNotification) {
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

extension SearchFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.viewModel.searchLoaded {
            if self.viewModel.searchContents.isEmpty {
                return 1
            } else {
                return self.viewModel.searchContents.count
            }
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.searchLoaded {
            if self.viewModel.searchContents.isEmpty {
                return 1
            } else {
                let content = self.viewModel.searchContents[section]
                if content.referencedCasts.type == .recasted || content.referencedCasts.type == .quoted {
                    return 4
                } else {
                    return 3
                }
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.viewModel.searchLoaded {
            if self.viewModel.searchContents.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: SearchNibVars.TableViewCell.searchNotFound, for: indexPath as IndexPath) as? SearchNotFoundTableViewCell
                cell?.backgroundColor = UIColor.Asset.darkGraphiteBlue
                cell?.configCell()
                return cell ?? SearchNotFoundTableViewCell()
            } else {
                let content = self.viewModel.searchContents[indexPath.section]
                if content.referencedCasts.type == .recasted {
                    if indexPath.row == 0 {
                        return self.renderFeedCell(content: content, cellType: .activity, tableView: tableView, indexPath: indexPath)
                    } else if indexPath.row == 1 {
                        return self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath)
                    } else if indexPath.row == 2 {
                        return self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath)
                    } else {
                        return self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
                    }
                } else if content.referencedCasts.type == .quoted {
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.skeleton, for: indexPath as IndexPath) as? SkeletonFeedTableViewCell
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.configCell()
            return cell ?? SkeletonFeedTableViewCell()
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
        if self.viewModel.searchLoaded {
            var originalContent = Content()
            let content = self.viewModel.searchContents[indexPath.section]
            if content.referencedCasts.type == .recasted || content.referencedCasts.type == .quoted {
                if let tempContent = ContentHelper.shared.getContentRef(id: content.referencedCasts.id) {
                    originalContent = tempContent
                }
            }
            
            if content.referencedCasts.type == .recasted {
                if originalContent.type == .long && indexPath.row == 2 {
                    self.viewModel.searchContents[indexPath.section].isOriginalExpand.toggle()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else {
                if content.type == .long && indexPath.row == 1 {
                    self.viewModel.searchContents[indexPath.section].isExpand.toggle()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func renderFeedCell(content: Content, cellType: FeedCellType, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var originalContent = Content()
        if content.referencedCasts.type == .recasted || content.referencedCasts.type == .quoted {
            if let tempContent = ContentHelper.shared.getContentRef(id: content.referencedCasts.id) {
                originalContent = tempContent
            }
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
            if content.referencedCasts.type == .recasted {
                cell?.configCell(feedType: .content, content: originalContent)
            } else {
                cell?.configCell(feedType: .content, content: originalContent)
            }
            return cell ?? HeaderTableViewCell()
        case .footer:
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.footerFeed, for: indexPath as IndexPath) as? FooterTableViewCell
            cell?.backgroundColor = UIColor.Asset.darkGray
            cell?.delegate = self
            if content.referencedCasts.type == .recasted {
                cell?.content = originalContent
            } else {
                cell?.content = content
            }
            return cell ?? FooterTableViewCell()
        case .quote:
            return FeedCellHelper().renderQuoteCastCell(content: originalContent, tableView: self.tableView, indexPath: indexPath, isRenderForFeed: true)
        default:
            if content.referencedCasts.type == .recasted {
                if originalContent.type == .long && !content.isOriginalExpand {
                    return FeedCellHelper().renderLongCastCell(content: originalContent, tableView: self.tableView, indexPath: indexPath)
                } else {
                    return FeedCellHelper().renderFeedCell(content: originalContent, tableView: self.tableView, indexPath: indexPath)
                }
            } else {
                if content.type == .long && !content.isExpand {
                    return FeedCellHelper().renderLongCastCell(content: content, tableView: self.tableView, indexPath: indexPath)
                } else {
                    return FeedCellHelper().renderFeedCell(content: content, tableView: self.tableView, indexPath: indexPath)
                }
            }
        }
    }
}

extension SearchFeedViewController: SearchFeedViewModelDelegate {
    func didGetContentSuccess() {
        self.tableView.cr.endHeaderRefresh()
        self.tableView.cr.endLoadingMore()
        self.tableView.isScrollEnabled = true
        self.tableView.reloadData()
    }
}

extension SearchFeedViewController: HeaderTableViewCellDelegate {
    func didRemoveSuccess(_ headerTableViewCell: HeaderTableViewCell) {
        // Remove success
    }
    
    func didTabProfile(_ headerTableViewCell: HeaderTableViewCell, author: Author) {
        if author.type == .page {
            ProfileOpener.openProfileDetail(author.type, castcleId: nil, displayName: "", page: Page().initCustom(id: author.id, displayName: author.displayName, castcleId: author.castcleId, avatar: author.avatar.thumbnail, cover: ""))
        } else {
            ProfileOpener.openProfileDetail(author.type, castcleId: author.castcleId, displayName: author.displayName, page: nil)
        }
    }
    
    func didAuthen(_ headerTableViewCell: HeaderTableViewCell) {
        Utility.currentViewController().presentPanModal(AuthenOpener.open(.signUpMethod) as! SignUpMethodViewController)
    }
    
    func didReportSuccess(_ headerTableViewCell: HeaderTableViewCell) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
            Utility.currentViewController().navigationController?.pushViewController(ComponentOpener.open(.reportSuccess(true, "")), animated: true)
        }
        
        if let indexPath = self.tableView.indexPath(for: headerTableViewCell) {
            UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.viewModel.searchContents.remove(at: indexPath.section)
                self.tableView.reloadData()
            })
        }
    }
}

extension SearchFeedViewController: FooterTableViewCellDelegate {
    func didTabComment(_ footerTableViewCell: FooterTableViewCell, content: Content) {
        Utility.currentViewController().navigationController?.pushViewController(ComponentOpener.open(.comment(CommentViewModel(content: content))), animated: true)
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
