import RxSwift
import HsToolKit
import Alamofire
import ObjectMapper

class DefiYieldProvider {
    private let baseUrl = "https://api.safe.defiyield.app"

    private let networkManager: NetworkManager
    private let apiKey: String?

    init(networkManager: NetworkManager, apiKey: String?) {
        self.networkManager = networkManager
        self.apiKey = apiKey
    }

}

extension DefiYieldProvider {

    func auditReportsSingle(addresses: [String]) -> Single<[Auditor]> {
        let parameters: Parameters = [
            "addresses": addresses
        ]

        let headers = apiKey.map { HTTPHeaders([HTTPHeader.authorization(bearerToken: $0)]) }
        let url = "\(baseUrl)/audit/address"
        let request = networkManager.session.request(url, method: .post, parameters: parameters, headers: headers)
        let single: Single<[AuditInfo]> = networkManager.single(request: request)

        return single.map { auditInfos in
            guard let info = auditInfos.first else {
                return []
            }

            var partners = [Int: Partner]()
            var audits = [Int: [PartnerAudit]]()

            for audit in info.partnerAudits {
                let partnerId = audit.partner.id
                partners[partnerId] = audit.partner
                var partnerAudits = audits[partnerId] ?? [PartnerAudit]()
                partnerAudits.append(audit)
                audits[partnerId] = partnerAudits
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            return partners.compactMap { id, partner -> Auditor? in
                guard let partnerAudits = audits[id] else {
                    return nil
                }

                let reports = partnerAudits.compactMap { audit -> AuditReport? in
                    guard let date = dateFormatter.date(from: audit.date) else {
                        return nil
                    }

                    return AuditReport(
                            name: audit.name,
                            date: date,
                            issues: audit.techIssues ?? 0,
                            link: "https://files.safe.defiyield.app/\(audit.auditLink)"
                    )
                }

                return Auditor(name: partner.name, reports: reports)
            }
        }
    }

}

extension DefiYieldProvider {

    struct AuditInfo: ImmutableMappable {
        let partnerAudits: [PartnerAudit]

        init(map: Map) throws {
            partnerAudits = try map.value("partnerAudits")
        }
    }

    struct PartnerAudit: ImmutableMappable {
        let name: String
        let date: String
        let techIssues: Int?
        let auditLink: String
        let partner: Partner

        init(map: Map) throws {
            name = try map.value("name")
            date = try map.value("date")
            techIssues = try? map.value("tech_issues")
            auditLink = try map.value("audit_link")
            partner = try map.value("partner")
        }
    }

    struct Partner: ImmutableMappable {
        let id: Int
        let name: String

        init(map: Map) throws {
            id = try map.value("id")
            name = try map.value("name")
        }
    }

}
