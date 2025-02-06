//
//  ViewController.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import UIKit
import Combine

final class ViewController: UIViewController {
    private let viewModel: ViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private lazy var allUsersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var allUsersDataSource = UITableViewDiffableDataSource<Section, User>(tableView: allUsersTableView)
    { [weak self] tableView, indexPath, itemIdentifier in
        guard
            let self,
            let cell = allUsersTableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath)
                as? UserCell
        else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.configureWith(user: itemIdentifier)
        cell.configureSelected(tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false)
        
        return cell
    }
    
    private lazy var pinnedUsersTableView: UITableView = {
        let tableView = SelfSizingTableView()
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        return tableView
    }()
    
    private lazy var pinnedUsersDataSource = UITableViewDiffableDataSource<Section, User>(tableView: pinnedUsersTableView)
    { [weak self] tableView, indexPath, itemIdentifier in
        guard
            let self,
            let cell = pinnedUsersTableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath)
                as? UserCell
        else { return UITableViewCell() }
        
        cell.configureWith(user: itemIdentifier)
        
        return cell
    }
    
    private lazy var pinnedView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.text = "Tap up to three friends in the list to pin them to the top. Or pin one to see distance relatively to other friends."
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var pinnedViewHeightConstraint: NSLayoutConstraint = {
        pinnedView.heightAnchor.constraint(equalToConstant: 80)
    }()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
}

private extension ViewController {
    
    func setup() {
        addSubviews()
        setupSubviews()
        makeConstraints()
    }
    
    func addSubviews() {
        [activityIndicator,
         pinnedView,
         allUsersTableView]
            .forEach { subview in
                view.addSubview(subview)
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        
        
        [infoLabel,
         pinnedUsersTableView].forEach { subview in
            pinnedView.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupSubviews() {
        view.backgroundColor = .systemGray6
        
        pinnedView.isHidden = true
        
        allUsersTableView.isHidden = true
        allUsersTableView.backgroundColor = .systemBackground
        allUsersTableView.allowsMultipleSelection = true
        allUsersTableView.layer.cornerRadius = 20
        allUsersTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        pinnedUsersTableView.isHidden = true
        pinnedUsersTableView.layer.cornerRadius = 20
        pinnedUsersTableView.separatorStyle = .none
        pinnedUsersTableView.allowsSelection = false
        pinnedUsersTableView.isScrollEnabled = false
        pinnedUsersTableView.backgroundColor = .clear
        pinnedUsersTableView.rowHeight = 100
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        pinnedUsersDataSource.apply(snapshot)
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            pinnedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pinnedView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pinnedView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pinnedViewHeightConstraint,
            
            infoLabel.topAnchor.constraint(equalTo: pinnedView.topAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: pinnedView.bottomAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: pinnedView.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: pinnedView.trailingAnchor),
            
            pinnedUsersTableView.topAnchor.constraint(equalTo: pinnedView.topAnchor),
            pinnedUsersTableView.leadingAnchor.constraint(equalTo: pinnedView.leadingAnchor),
            pinnedUsersTableView.trailingAnchor.constraint(equalTo: pinnedView.trailingAnchor),
            pinnedUsersTableView.bottomAnchor.constraint(equalTo: pinnedView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            allUsersTableView.topAnchor.constraint(equalTo: pinnedView.bottomAnchor),
            allUsersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            allUsersTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            allUsersTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func bind() {
        viewModel.viewDidLoad()
        
        viewModel.usersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.activityIndicator.stopAnimating()
                self?.allUsersTableView.isHidden = false
                self?.pinnedView.isHidden = false
                self?.displayAllUsers(users)
            }
            .store(in: &cancellables)
    }
    
    func displayAllUsers(_ users: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users, toSection: .main)
        allUsersDataSource.apply(snapshot)
    }
    
    func shoudDisplayPinned(_ bool: Bool) {
        pinnedViewHeightConstraint.isActive = !bool
        pinnedUsersTableView.isHidden = !bool
        infoLabel.isHidden = bool
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let count = tableView.indexPathsForSelectedRows?.count,
            count > 3
        else {
            if let user = allUsersDataSource.itemIdentifier(for: indexPath) {
                var snapshot = pinnedUsersDataSource.snapshot()
                snapshot.appendItems([user], toSection: .main)
                pinnedUsersDataSource.apply(snapshot)
            }
            if let cell = tableView.cellForRow(at: indexPath) as? UserCell {
                cell.configureSelected(true)
            }
            shoudDisplayPinned(true)
    
            // сохранить пины в vm
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let count = tableView.indexPathsForSelectedRows?.count ?? 0
        
        guard let userToRemove = allUsersDataSource.itemIdentifier(for: indexPath) else { return }
        
        var snapshot = pinnedUsersDataSource.snapshot()
        snapshot.deleteItems([userToRemove])
        
        pinnedUsersDataSource.apply(snapshot)
        
        if let cell = tableView.cellForRow(at: indexPath) as? UserCell {
            cell.configureSelected(false)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        if count == 0 {
            shoudDisplayPinned(false)
        }
    }
}

enum Section: String {
    case main
}
