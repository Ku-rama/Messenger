//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Makwana Bhavin on 10/06/22.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        return iv
    }()
    
    public let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "The weeknd"
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "This is the first message."
        label.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: userImageView.topAnchor).isActive =  true
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10).isActive =  true
        userNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive =  true
        userNameLabel.heightAnchor.constraint(equalToConstant: 20).isActive =  true
        userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10).isActive =  true
        userMessageLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10).isActive =  true
        userMessageLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive =  true
        userMessageLabel.heightAnchor.constraint(equalToConstant: 20).isActive =  true
    }
    
    public func configure(with model: Conversation){
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageMamager.shared.downloadUrl(for: path) { [weak self] result in
            switch result{
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url)
                }
                
            case .failure(let error):
                print("Failed to get Image url, \(error)")
            }
        }
        
    }
    

}
