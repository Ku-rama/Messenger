//
//  ConvoTableViewCell.swift
//  Messenger
//
//  Created by Makwana Bhavin on 12/06/22.
//

import UIKit

class ConvoTableViewCell: UITableViewCell {
    
    static let identifier = "ConvoTableViewCell"
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle")
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
