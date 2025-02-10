//
//  FrinedCell.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import UIKit

final class FriendCell: UITableViewCell {
    static var identifier: String { String(describing: Self.self) }
    
    private lazy var backgrndView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private lazy var friendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.image = UIImage(systemName: "person")
        return imageView
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.text = "Distance from you: unknown"
        label.numberOfLines = 0
        return label
    }()
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var friendImageSize: CGFloat = contentView.frame.height 
    private lazy var pinImageSize: CGFloat = contentView.frame.height * 0.6
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(friendData: ProcessedFriendData) {
        nameLabel.text = friendData.name
        infoLabel.text = friendData.message
        configureSelected(friendData.isPinned)
    }
    
    func configureSelected(_ bool: Bool) {
        pinImageView.image = bool
        ? UIImage(systemName: "pin.slash")
        : nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
    }
    
    private func setup() {
        backgroundColor = .clear
        backgrndView.layer.cornerRadius = 20
        
        [backgrndView,
         friendImageView,
         nameLabel,
         infoLabel,
         pinImageView]
            .forEach { subview in
                contentView.addSubview(subview)
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        
        NSLayoutConstraint.activate([
            backgrndView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            backgrndView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            backgrndView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgrndView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            friendImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            friendImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: friendImageSize),
            friendImageView.widthAnchor.constraint(equalToConstant: friendImageSize),
            
            pinImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pinImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pinImageView.heightAnchor.constraint(equalToConstant: pinImageSize),
            pinImageView.widthAnchor.constraint(equalToConstant: pinImageSize),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: pinImageView.leadingAnchor, constant: -16),
            
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            infoLabel.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: pinImageView.leadingAnchor, constant: -16),
        ])
    }
}
