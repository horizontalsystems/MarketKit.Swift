import UIKit
import SnapKit
import MarketKit

class PostCell: UITableViewCell {
    private let sourceLabel = UILabel()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let timestampLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(sourceLabel)
        sourceLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalToSuperview().offset(12)
        }

        sourceLabel.font = .systemFont(ofSize: 12, weight: .medium)

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalTo(sourceLabel.snp.bottom).offset(8)
        }

        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)

        contentView.addSubview(bodyLabel)
        bodyLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        bodyLabel.numberOfLines = 2
        bodyLabel.font = .systemFont(ofSize: 13, weight: .regular)

        contentView.addSubview(timestampLabel)
        timestampLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalTo(bodyLabel.snp.bottom).offset(12)
        }

        timestampLabel.font = .systemFont(ofSize: 10, weight: .regular)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(post: Post) {
        sourceLabel.text = post.source
        titleLabel.text = post.title
        bodyLabel.text = post.body
        let minutesAgo = Int((Date().timeIntervalSince1970 - post.timestamp) / 60)
        timestampLabel.text = "\(minutesAgo) minutes ago"
    }

}
