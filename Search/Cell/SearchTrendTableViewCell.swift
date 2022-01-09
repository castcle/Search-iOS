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
//  SearchTrendTableViewCell.swift
//  Search
//
//  Created by Castcle Co., Ltd. on 23/9/2564 BE.
//

import UIKit
import Core
import Networking

class SearchTrendTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var trendLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var nextIcon: UIImageView!
    @IBOutlet var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = UIFont.asset(.bold, fontSize: .overline)
        self.titleLabel.textColor = UIColor.Asset.lightGray
        self.trendLabel.font = UIFont.asset(.bold, fontSize: .body)
        self.trendLabel.textColor = UIColor.Asset.white
        self.countLabel.font = UIFont.asset(.bold, fontSize: .overline)
        self.countLabel.textColor = UIColor.Asset.lightGray
        
        self.nextIcon.image = UIImage.init(icon: .castcle(.next), size: CGSize(width: 25, height: 25), textColor: UIColor.Asset.lightGray)
        self.lineView.backgroundColor = UIColor.Asset.darkGraphiteBlue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(hastag: Hashtag) {
        self.titleLabel.text = "\(hastag.rank). \(Localization.searchTopTrends.trending.text)"
        self.trendLabel.text = hastag.name
        self.countLabel.text = "\(String.displayCount(count: hastag.count)) \(Localization.searchTopTrends.cast.text)"
    }
}
