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
import Farming
import XLPagerTabStrip

class SearchFeedViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var pageIndex: Int = 0
    var pageTitle: String?

    var viewModel = SearchFeedViewModel(searchSection: .none, noti: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.configureTableView()
        self.viewModel.delegate = self
        self.tableView.coreRefresh.addHeadRefresh(animator: FastAnimator()) {
            self.tableView.coreRefresh.resetNoMore()
            self.tableView.isScrollEnabled = false
            self.viewModel.searchLoaded = false
            self.tableView.reloadData()
            self.viewModel.reloadData()
        }

        self.tableView.coreRefresh.addFootRefresh(animator: NormalFooterAnimator()) {
            if self.viewModel.searchCanLoad {
                self.viewModel.getSearchContent()
            } else {
                self.tableView.coreRefresh.noticeNoMoreData()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
        if let dict = notification.userInfo as NSDictionary?, let searchText = dict["searchText"] as? String {
            self.viewModel.reloadData(with: searchText)
            self.tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: true)
            self.tableView.isScrollEnabled = false
            self.tableView.reloadData()
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
                if content.participate.recasted || ContentHelper.shared.isReportContent(contentId: content.id) {
                    if content.isShowContentReport && content.referencedCasts.type == .quoted {
                        return 5
                    } else if content.isShowContentReport && content.referencedCasts.type != .quoted {
                        return 4
                    } else {
                        return 1
                    }
                } else {
                    if content.referencedCasts.type == .recasted || content.referencedCasts.type == .quoted {
                        return 4
                    } else {
                        return 3
                    }
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
                return self.getContentCellWithContent(content: content, tableView: tableView, indexPath: indexPath)[indexPath.row]
            }
        } else {
            return FeedCellHelper().renderSkeletonCell(tableView: tableView, indexPath: indexPath)
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

    private func getContentCellWithContent(content: Content, tableView: UITableView, indexPath: IndexPath) -> [UITableViewCell] {
        if content.participate.recasted || ContentHelper.shared.isReportContent(contentId: content.id) {
            if content.isShowContentReport && content.referencedCasts.type == .quoted {
                return [
                    self.renderFeedCell(content: content, cellType: .activity, tableView: tableView, indexPath: indexPath),
                    self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath),
                    self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath),
                    self.renderFeedCell(content: content, cellType: .quote, tableView: tableView, indexPath: indexPath),
                    self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
                ]
            } else if content.isShowContentReport && content.referencedCasts.type != .quoted {
                return [
                    self.renderFeedCell(content: content, cellType: .activity, tableView: tableView, indexPath: indexPath),
                    self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath),
                    self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath),
                    self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
                ]
            } else {
                return [
                    self.renderFeedCell(content: content, cellType: .report, tableView: tableView, indexPath: indexPath)
                ]
            }
        } else if content.referencedCasts.type == .recasted {
            return [
                self.renderFeedCell(content: content, cellType: .activity, tableView: tableView, indexPath: indexPath),
                self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath),
                self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath),
                self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
            ]
        } else if content.referencedCasts.type == .quoted {
            return [
                self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath),
                self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath),
                self.renderFeedCell(content: content, cellType: .quote, tableView: tableView, indexPath: indexPath),
                self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
            ]
        } else {
            return [
                self.renderFeedCell(content: content, cellType: .header, tableView: tableView, indexPath: indexPath),
                self.renderFeedCell(content: content, cellType: .content, tableView: tableView, indexPath: indexPath),
                self.renderFeedCell(content: content, cellType: .footer, tableView: tableView, indexPath: indexPath)
            ]
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
            cell?.backgroundColor = UIColor.Asset.cellBackground
            cell?.cellConfig(content: content)
            return cell ?? ActivityHeaderTableViewCell()
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.headerFeed, for: indexPath as IndexPath) as? HeaderTableViewCell
            cell?.backgroundColor = UIColor.Asset.cellBackground
            cell?.delegate = self
            if content.referencedCasts.type == .recasted {
                cell?.configCell(type: .content, content: originalContent, isDefaultContent: false)
            } else {
                cell?.configCell(type: .content, content: content, isDefaultContent: false)
            }
            return cell ?? HeaderTableViewCell()
        case .footer:
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.footerFeed, for: indexPath as IndexPath) as? FooterTableViewCell
            cell?.backgroundColor = UIColor.Asset.cellBackground
            cell?.delegate = self
            if content.referencedCasts.type == .recasted {
                cell?.configCell(content: originalContent, isCommentView: false)
            } else {
                cell?.configCell(content: content, isCommentView: false)
            }
            return cell ?? FooterTableViewCell()
        case .quote:
            return FeedCellHelper().renderQuoteCastCell(content: originalContent, tableView: self.tableView, indexPath: indexPath, isRenderForFeed: true)
        case .report:
            let cell = tableView.dequeueReusableCell(withIdentifier: ComponentNibVars.TableViewCell.report, for: indexPath as IndexPath) as? ReportTableViewCell
            cell?.backgroundColor = UIColor.Asset.cellBackground
            cell?.delegate = self
            return cell ?? ReportTableViewCell()
        default:
            return self.renderContentCell(content: content, originalContent: originalContent, tableView: tableView, indexPath: indexPath)
        }
    }

    private func renderContentCell(content: Content, originalContent: Content, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if content.referencedCasts.type == .recasted {
            if originalContent.type == .long && !content.isOriginalExpand {
                return FeedCellHelper().renderLongCastCell(content: originalContent, tableView: tableView, indexPath: indexPath)
            } else {
                return FeedCellHelper().renderFeedCell(content: originalContent, tableView: tableView, indexPath: indexPath)
            }
        } else {
            if content.type == .long && !content.isExpand {
                return FeedCellHelper().renderLongCastCell(content: content, tableView: tableView, indexPath: indexPath)
            } else {
                return FeedCellHelper().renderFeedCell(content: content, tableView: tableView, indexPath: indexPath)
            }
        }
    }
}

extension SearchFeedViewController: SearchFeedViewModelDelegate {
    func didGetContentSuccess() {
        self.tableView.coreRefresh.endHeaderRefresh()
        self.tableView.coreRefresh.endLoadingMore()
        self.tableView.isScrollEnabled = true
        self.tableView.reloadData()
    }
}

extension SearchFeedViewController: HeaderTableViewCellDelegate {
    func didRemoveSuccess(_ headerTableViewCell: HeaderTableViewCell) {
        // Remove success
    }

    func didReport(_ headerTableViewCell: HeaderTableViewCell, contentId: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let reportDict: [String: Any] = [
                JsonKey.castcleId.rawValue: "",
                JsonKey.contentId.rawValue: contentId
            ]
            NotificationCenter.default.post(name: .openReportDelegate, object: nil, userInfo: reportDict)
        }
    }
}

extension SearchFeedViewController: FooterTableViewCellDelegate {
    func didTabQuoteCast(_ footerTableViewCell: FooterTableViewCell, content: Content, page: PageRealm) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let viewController = PostOpener.open(.post(PostViewModel(postType: .quoteCast, content: content, page: page)))
            viewController.modalPresentationStyle = .fullScreen
            Utility.currentViewController().present(viewController, animated: true, completion: nil)
        }
    }
}

extension SearchFeedViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: pageTitle ?? "Tab \(pageIndex)")
    }
}

extension SearchFeedViewController: ReportTableViewCellDelegate {
    func didTabView(_ reportTableViewCell: ReportTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: reportTableViewCell) {
            self.viewModel.searchContents[indexPath.section].isShowContentReport = true
            self.tableView.reloadData()
        }
    }
}
