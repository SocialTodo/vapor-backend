@_exported import Vapor

extension Droplet {
    public func setup() throws {
        do {
            try setupRoutes()
        } catch {
            print(error)
        }
    }
}
