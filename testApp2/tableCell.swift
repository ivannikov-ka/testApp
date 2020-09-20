//
//  tableCell.swift
//  testApp2
//
//  Created by Кирилл Иванников on 17.09.2020.
//  Copyright © 2020 Кирилл Иванников. All rights reserved.
//

import UIKit

class tableCell: UITableViewCell {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personPhoneNumLabel: UILabel!
    @IBOutlet weak var personEmailLabel: UILabel!
    
    
    var cellId: Int!
    var delegate: tapOnCell?
    override func awakeFromNib() {
        super.awakeFromNib()
        personImageView.layer.cornerRadius = personImageView.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true {
            delegate?.getId(id: cellId)
        }
    }
    
    func fillCell(name: String, phoneNum: String, email: String){
        personNameLabel.text = name
        personPhoneNumLabel.text = phoneNum
        personEmailLabel.text = email
    }
    
    
}
