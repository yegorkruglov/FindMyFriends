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
    
    private lazy var dataSource = UITableViewDiffableDataSource<Section, User>(tableView: allUsersTableView)
    { [weak self] tableView, indexPath, itemIdentifier in
        guard
            let self,
            let cell = allUsersTableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath)
                as? UserCell
        else { return UITableViewCell() }
        
        cell.configureWith(user: itemIdentifier)
        return cell
    }
    
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
         allUsersTableView]
            .forEach { subview in
                view.addSubview(subview)
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        
    }
    
    func setupSubviews() {
        view.backgroundColor = .systemGray6
        
        allUsersTableView.isHidden = true
        allUsersTableView.rowHeight = 100
        allUsersTableView.backgroundColor = .systemGray6
        allUsersTableView.separatorStyle = .none
        allUsersTableView.allowsMultipleSelection = true
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            allUsersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
                self?.displayUsers(users)
            }
            .store(in: &cancellables)
    }
    
    func makeAllUsersDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
        
        allUsersTableView.dataSource = dataSource
    }
    
    func displayUsers(_ users: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users, toSection: .main)
        dataSource.apply(snapshot)
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let count = tableView.indexPathsForSelectedRows?.count,
            count > 3
        else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

enum Section: String {
    case main
}
