//
//  UserCell.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import UIKit

final class UserCell: UITableViewCell {
    static var identifier: String { String(describing: Self.self) }
    
    private lazy var backgrndView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
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
    
    func configureWith(user: User) {
        nameLabel.text = user.name
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
         nameLabel,
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
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            pinImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            pinImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            pinImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
}
