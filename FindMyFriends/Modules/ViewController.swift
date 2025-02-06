//
//  ViewController.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import UIKit
import Combine

final class ViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private let viewModel: ViewModel
    
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
        [activityIndicator].forEach { subview in
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
    }
    
    func setupSubviews() {
        view.backgroundColor = .systemGray6
    }
    
    func makeConstraints() {
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func bind() {
        viewModel.viewDidLoad()
        
        viewModel.usersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                print($0)
                self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
    }
}

