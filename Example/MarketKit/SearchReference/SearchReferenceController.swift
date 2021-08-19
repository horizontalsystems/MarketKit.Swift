import UIKit
import SnapKit
import MarketKit

class SearchReferenceController: UIViewController {
    private let textField = UITextField()
    private let label = UILabel()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search by Reference"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onTapAddToken))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(onTapClose))

        view.backgroundColor = .systemBackground

        let textFieldWrapper = UIView()

        view.addSubview(textFieldWrapper)
        textFieldWrapper.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().inset(16)
            maker.top.equalTo(view.safeAreaLayoutGuide).inset(16)
        }

        textFieldWrapper.layer.borderWidth = 1
        textFieldWrapper.layer.borderColor = UIColor.systemFill.cgColor
        textFieldWrapper.layer.cornerRadius = 8

        textFieldWrapper.addSubview(textField)
        textField.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(12)
        }

        textField.placeholder = "Reference"

        let button = UIButton()

        view.addSubview(button)
        button.snp.makeConstraints { maker in
            maker.leading.equalTo(textFieldWrapper.snp.trailing).offset(16)
            maker.trailing.equalToSuperview().inset(16)
            maker.top.bottom.equalTo(textFieldWrapper)
        }

        button.setTitle("Search", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(onTapSearch), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)

        view.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalTo(textFieldWrapper.snp.bottom).offset(24)
        }

        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
    }

    @objc private func onTapClose() {
        dismiss(animated: true)
    }

    @objc private func onTapAddToken() {
        let type = "erc20"
        let contractAddress = "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984"
        let uid = "custom_\(type)_\(contractAddress)"
        let name = "Uniswap"
        let code = "UNI"
        let decimal = 18

        let platform = Platform(type: type, value: contractAddress, coinUid: uid)
        let coin = Coin(uid: uid, name: name, code: code, decimal: decimal)

        do {
            try Singleton.instance.kit.save(coin: coin, platform: platform)
            label.text = "Successfully saved \(name) coin"
        } catch {
            label.text = "Could not save \(name) coin: \(error)"
        }
    }

    @objc private func onTapSearch() {
        guard let reference = textField.text?.trimmingCharacters(in: .whitespaces), !reference.isEmpty else {
            label.text = "Reference is empty"
            return
        }

        do {
            if let platformWithCoin = try Singleton.instance.kit.platformWithCoin(reference: reference) {
                label.text = "\(platformWithCoin.platform)\n\n\(platformWithCoin.coin)"
            } else {
                label.text = "Not found"
            }
        } catch {
            label.text = error.localizedDescription
        }
    }

}
