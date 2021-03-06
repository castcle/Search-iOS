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
//  RecentHeaderSearchTableViewCell.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 14/10/2564 BE.
//

import UIKit
import Core

protocol RecentHeaderSearchTableViewCellDelegate: AnyObject {
    func didClearAll(_ recentHeaderSearchTableViewCell: RecentHeaderSearchTableViewCell)
}

class RecentHeaderSearchTableViewCell: UITableViewCell {

    @IBOutlet var displayLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var lineView: UIView!

    public var delegate: RecentHeaderSearchTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.displayLabel.font = UIFont.asset(.regular, fontSize: .overline)
        self.displayLabel.textColor = UIColor.Asset.white
        self.lineView.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.actionButton.setImage(UIImage.init(icon: .castcle(.incorrect), size: CGSize(width: 15, height: 15), textColor: UIColor.Asset.white).withRenderingMode(.alwaysOriginal), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configCell(display: String) {
        self.displayLabel.text = display
    }

    @IBAction func cellAction(_ sender: Any) {
        self.delegate?.didClearAll(self)
    }
}
