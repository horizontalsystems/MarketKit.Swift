import UIKit
import SnapKit
import MarketKit

class FullCoinCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let codeLabel = UILabel()
    private let platformsLabel = UILabel()

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

        contentView.addSubview(codeLabel)
        codeLabel.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().inset(16)
            maker.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        codeLabel.font = .systemFont(ofSize: 12, weight: .regular)

        contentView.addSubview(platformsLabel)
        platformsLabel.snp.makeConstraints { maker in
            maker.trailing.equalToSuperview().inset(16)
            maker.top.equalToSuperview().offset(12)
        }

        platformsLabel.numberOfLines = 0
        platformsLabel.textAlignment = .right
        platformsLabel.font = .systemFont(ofSize: 10, weight: .regular)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(fullCoin: FullCoin) {
        let coin = fullCoin.coin
        nameLabel.text = coin.name
        codeLabel.text = "\(coin.code), mcr: \(coin.marketCapRank.map { "\($0)" } ?? "n/a"), cgi: \(coin.coinGeckoId.map { "\($0)" } ?? "n/a")"
        platformsLabel.text = "\(fullCoin.tokens.count)"
    }

}
