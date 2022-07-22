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
//  SearchTextFieldTableViewCell.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 23/9/2564 BE.
//

import UIKit
import Core

class SearchTextFieldTableViewCell: UITableViewCell {

    @IBOutlet var searchView: UIView!
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var searchTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.searchView.custom(color: UIColor.Asset.cellBackground, cornerRadius: 18, borderWidth: 1, borderColor: UIColor.Asset.darkGraphiteBlue)
        self.searchImage.image = UIImage.init(icon: .castcle(.search), size: CGSize(width: 25, height: 25), textColor: UIColor.Asset.white)
        self.searchTextField.font = UIFont.asset(.contentRegular, fontSize: .overline)
        self.searchTextField.textColor = UIColor.Asset.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configCell() {
        self.searchTextField.placeholder = Localization.SearchTopTrends.placeholder.text
    }

    @IBAction func searchAction(_ sender: Any) {
        let viewController = SearchOpener.open(.searchResult(SearchResualViewModel(state: .initial)))
        Utility.currentViewController().navigationController?.pushViewController(viewController, animated: false)
    }
}
