import UIKit
import SnapKit
import MarketKit

class CoinCategoryCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().inset(16)
            maker.top.equalToSuperview().offset(12)
        }

        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)

        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        descriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(coinCategory: CoinCategory) {
        nameLabel.text = coinCategory.name
        descriptionLabel.text = coinCategory.descriptions.keys.joined(separator: ", ")
    }

}
