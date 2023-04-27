import UIKit
import SnapKit
import MarketKit

class PostsController: UIViewController {
    private let tableView = UITableView()

    private var posts = [Post]()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Posts"

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.register(PostCell.self, forCellReuseIdentifier: String(describing: PostCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        syncPosts()
    }

    private func syncPosts() {
        Task { [weak self] in
            self?.posts = try await Singleton.instance.kit.posts()
            self?.tableView.reloadData()
        }
    }

}

extension PostsController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: String(describing: PostCell.self), for: indexPath)
    }

}

extension PostsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        130
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostCell {
            cell.bind(post: posts[indexPath.row])
        }
    }

}
