import Vapor
import HTTP

final class FacebookUserController: ResourceRepresentable {
    typealias Model = FacebookUser

    let drop: Droplet
    let graphApi: GraphApiService

    init(droplet: Droplet){
        drop = droplet
        graphApi = GraphApiService(droplet: drop)
    }

    func makeResource() -> Resource<FacebookUser> {
        return Resource(
        )
    }
}
