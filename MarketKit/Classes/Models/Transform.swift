import Foundation
import ObjectMapper

struct Transform {

   static let stringToDecimalTransform: TransformOf<Decimal, String> = TransformOf(fromJSON: { string -> Decimal? in
       guard let string = string else { return nil }
       return Decimal(string: string)
   }, toJSON: { (value: Decimal?) in
       guard let value = value else { return nil }
       return value.description
   })

   static let doubleToDecimalTransform: TransformOf<Decimal, Double> = TransformOf(fromJSON: { double -> Decimal? in
       guard let double = double else { return nil }
       return Decimal(double)
   }, toJSON: { (value: Decimal?) in
       guard let value = value else { return nil }
       return (value as NSDecimalNumber).doubleValue
   })

}
