import ObjectMapper

struct PostsResponse: ImmutableMappable {
    let posts: [Post]

    init(map: Map) throws {
        posts = try map.value("Data")
    }
}
