import UIKit
import SnapKit
import MarketKit

class MarketSearchCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let codeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalToSuperview().offset(12)
        }

        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)

        contentView.addSubview(codeLabel)
        codeLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        codeLabel.font = .systemFont(ofSize: 12, weight: .medium)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(coin: Coin) {
        nameLabel.text = coin.name
        codeLabel.text = coin.code

    }

}
