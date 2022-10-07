import Foundation
import ObjectMapper

public struct Transform {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    public static let stringToDecimalTransform: TransformOf<Decimal, String> = TransformOf(fromJSON: { string -> Decimal? in
        guard let string = string else {
            return nil
        }
        return Decimal(string: string)
    }, toJSON: { (value: Decimal?) in
        guard let value = value else {
            return nil
        }
        return value.description
    })

    public static let stringToIntTransform: TransformOf<Int, String> = TransformOf(fromJSON: { string -> Int? in
        guard let string = string else {
            return nil
        }
        return Int(string)
    }, toJSON: { (value: Int?) in
        guard let value = value else {
            return nil
        }
        return value.description
    })

    public static let doubleToDecimalTransform: TransformOf<Decimal, Double> = TransformOf(fromJSON: { double -> Decimal? in
        guard let double = double else {
            return nil
        }
        return Decimal(double)
    }, toJSON: { (value: Decimal?) in
        guard let value = value else {
            return nil
        }
        return (value as NSDecimalNumber).doubleValue
    })

    public static let stringToDateTransform: TransformOf<Date, String> = TransformOf(fromJSON: { string -> Date? in
        guard let string = string else {
            return nil
        }
        return dateFormatter.date(from: string)
    }, toJSON: { (value: Date?) in
        guard let value = value else {
            return nil
        }
        return dateFormatter.string(from: value)
    })

}
