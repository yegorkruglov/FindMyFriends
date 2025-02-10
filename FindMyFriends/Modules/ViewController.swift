//
//  ViewController.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import UIKit
import Combine

final class ViewController: UIViewController {
    
    // MARK: - external depandecies
    
    private let viewModel: ViewModel
    
    // MARK: - publishers
    
    private var cancellables: Set<AnyCancellable> = []
    private var selectedFriendPublisher = PassthroughSubject<UUID?, Never>()
    
    // MARK: - ui
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
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
    private lazy var pinnedFriendsTableView: UITableView = {
        let tableView = SelfSizingTableView()
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.identifier)
        tableView.delegate = self
        return tableView
    }()
    private lazy var allFriendsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.identifier)
        tableView.delegate = self
        return tableView
    }()
    private lazy var pinnedViewHeightConstraint: NSLayoutConstraint = {
        pinnedView.heightAnchor.constraint(equalToConstant: 80)
    }()
    
    // MARK: - data sources
    
    private lazy var pinnedFriendsDataSource = UITableViewDiffableDataSource<Section, ProcessedFriendData>(tableView: pinnedFriendsTableView)
    { [weak self] tableView, indexPath, itemIdentifier in
        guard
            let self,
            let cell = pinnedFriendsTableView.dequeueReusableCell(withIdentifier: FriendCell.identifier, for: indexPath)
                as? FriendCell
        else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configureWith(friendData: itemIdentifier)
        
        return cell
    }
    private lazy var allFriendsDataSource = UITableViewDiffableDataSource<Section, ProcessedFriendData>(tableView: allFriendsTableView)
    { [weak self] tableView, indexPath, itemIdentifier in
        guard
            let self,
            let cell = allFriendsTableView.dequeueReusableCell(withIdentifier: FriendCell.identifier, for: indexPath)
                as? FriendCell
        else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.configureWith(friendData: itemIdentifier)
        
        return cell
    }
    
    // MARK: -  initializers
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
}

// MARK: -  private methods

private extension ViewController {
    
    func setup() {
        addSubviews()
        setupSubviews()
        makeConstraints()
    }
    
    func addSubviews() {
        [activityIndicator,
         pinnedView,
         allFriendsTableView]
            .forEach { subview in
                view.addSubview(subview)
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        
        
        [infoLabel,
         pinnedFriendsTableView].forEach { subview in
            pinnedView.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupSubviews() {
        view.backgroundColor = .systemGray6
        
        pinnedView.isHidden = true
        
        configureAllFriendsTableView()
        
        confugurePinnedFriendsTableView()
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
            
            pinnedFriendsTableView.topAnchor.constraint(equalTo: pinnedView.topAnchor),
            pinnedFriendsTableView.leadingAnchor.constraint(equalTo: pinnedView.leadingAnchor),
            pinnedFriendsTableView.trailingAnchor.constraint(equalTo: pinnedView.trailingAnchor),
            pinnedFriendsTableView.bottomAnchor.constraint(equalTo: pinnedView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            allFriendsTableView.topAnchor.constraint(equalTo: pinnedView.bottomAnchor),
            allFriendsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            allFriendsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            allFriendsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func bind() {
        let input = ViewModel.Input(
            selectedFriendPublisher: selectedFriendPublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.bind(input)
        
        handleFriendsPublisher(output.processedDataPublisher)
    }
    
    func configureAllFriendsTableView() {
        allFriendsTableView.isHidden = true
        allFriendsTableView.backgroundColor = .systemBackground
        allFriendsTableView.allowsMultipleSelection = true
        allFriendsTableView.layer.cornerRadius = 20
        allFriendsTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProcessedFriendData>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        allFriendsDataSource.apply(snapshot)
    }
    
    func confugurePinnedFriendsTableView() {
        pinnedFriendsTableView.isHidden = true
        pinnedFriendsTableView.layer.cornerRadius = 20
        pinnedFriendsTableView.separatorStyle = .none
        pinnedFriendsTableView.allowsSelection = true
        pinnedFriendsTableView.isScrollEnabled = false
        pinnedFriendsTableView.backgroundColor = .clear
        pinnedFriendsTableView.rowHeight = 100
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProcessedFriendData>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        pinnedFriendsDataSource.apply(snapshot)
    }
    
    func handleFriendsPublisher( _ publisher: AnyPublisher<[ProcessedFriendData], Never>) {
        publisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] friends in
                self?.activityIndicator.stopAnimating()
                self?.allFriendsTableView.isHidden = false
                self?.pinnedView.isHidden = false
                self?.displayFriends(friends)
            }
            .store(in: &cancellables)
    }
    
    func displayFriends(_ allFriends: [ProcessedFriendData]) {
        var pinnedSnapshot = NSDiffableDataSourceSnapshot<Section, ProcessedFriendData>()
        pinnedSnapshot.appendSections([.main])
        pinnedSnapshot.appendItems(allFriends.filter { $0.isPinned} )
        pinnedSnapshot.reloadItems(allFriends.filter { $0.isPinned} )
        pinnedFriendsDataSource.apply(pinnedSnapshot, animatingDifferences: false)
        shoudDisplayPinned(!pinnedSnapshot.itemIdentifiers.isEmpty)
        
        var allFriendsSnapshot = NSDiffableDataSourceSnapshot<Section, ProcessedFriendData>()
        allFriendsSnapshot.appendSections([.main])
        allFriendsSnapshot.appendItems(allFriends, toSection: .main)
        allFriendsSnapshot.reloadItems(allFriends)
        allFriendsDataSource.apply(allFriendsSnapshot, animatingDifferences: false)
    }
    
    func shoudDisplayPinned(_ bool: Bool) {
        pinnedViewHeightConstraint.isActive = !bool
        pinnedFriendsTableView.isHidden = !bool
        infoLabel.isHidden = bool
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataSource = tableView == allFriendsTableView
        ? allFriendsDataSource
        : pinnedFriendsDataSource
        guard let id = dataSource.itemIdentifier(for: indexPath)?.id else { return }
        
        selectedFriendPublisher.send(id)
    }
}

enum Section: String {
    case main
}
