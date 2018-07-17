//
//  RoundedShadowBtn.swift
//  CoreML
//
//  Created by MacBook Pro on 7/15/18.
//  Copyright © 2018 Bassyouni. All rights reserved.
//

import UIKit

class RoundedShadowBtn: UIButton {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }

}
