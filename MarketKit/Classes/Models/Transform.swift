import ObjectMapper

struct Transform {

   static let stringToDecimalTransform: TransformOf<Decimal, String> = TransformOf(fromJSON: { string -> Decimal? in
       guard let string = string else { return nil }
       return Decimal(string: string)
   }, toJSON: { _ in nil })

}
