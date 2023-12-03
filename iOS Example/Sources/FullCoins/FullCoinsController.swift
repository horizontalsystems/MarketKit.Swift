import Combine
import MarketKit
import SnapKit
import UIKit

class FullCoinsController: UIViewController {
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()

    private var currentFilter: String = ""

    private var fullCoins = [FullCoin]()
    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Full Coins"

        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.register(FullCoinCell.self, forCellReuseIdentifier: String(describing: FullCoinCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        Singleton.instance.kit.fullCoinsUpdatedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.syncCoins()
            }
            .store(in: &cancellables)

        syncCoins()
    }

    private func syncCoins() {
        do {
            fullCoins = try Singleton.instance.kit.fullCoins(filter: currentFilter)
            tableView.reloadData()
        } catch {
            print("Failed to sync coins: \(error)")
        }
    }
}

extension FullCoinsController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        fullCoins.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: String(describing: FullCoinCell.self), for: indexPath)
    }
}

extension FullCoinsController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? FullCoinCell {
            cell.bind(fullCoin: fullCoins[indexPath.row])
        }
    }
}

extension FullCoinsController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        let filter = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""

        if filter != currentFilter {
            currentFilter = filter
            syncCoins()
        }
    }
}
