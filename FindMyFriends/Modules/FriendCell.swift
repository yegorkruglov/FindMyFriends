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
    private lazy var frienDImageView: UIImageView = {
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
        return label
    }()
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
         frienDImageView,
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
            
            frienDImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            frienDImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            frienDImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            frienDImageView.widthAnchor.constraint(equalTo: frienDImageView.heightAnchor),
            
            
            pinImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pinImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: frienDImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: pinImageView.leadingAnchor, constant: -16),
            
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            infoLabel.leadingAnchor.constraint(equalTo: frienDImageView.trailingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: pinImageView.leadingAnchor, constant: -16),
        ])
        
        pinImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
