import UIKit
import Combine

final class LocationRequestViewController: UIViewController {
    
    private let viewModel: LocationRequestViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Elements
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Access to your location is required to provide distance data. If previously acces was not granted, check your device settings for this app and relaunch."
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private lazy var accessButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Access Location", for: .normal)
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    self?.accessButtonPressed()
                }),
            for: .touchUpInside
        )
        return button
    }()
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
            ),
            for: .touchUpInside
        )
        button.setTitleColor(.lightGray, for: .normal)
        return button
    }()
    
    // MARK: - Initializers
    
    init(viewModel: LocationRequestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Private Methods

private extension LocationRequestViewController {
    
    func setup() {
        view.backgroundColor = .white
        addSubviews()
        makeConstraints()
    }
    
    func addSubviews() {
        [infoLabel, accessButton, settingsButton].forEach { subview in
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -20),
            infoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            accessButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
            accessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            settingsButton.topAnchor.constraint(equalTo: accessButton.bottomAnchor, constant: 16),
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    func accessButtonPressed() {
        viewModel.didPressAccessButton()
    }
}
