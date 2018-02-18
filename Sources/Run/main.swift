import App
import PostgreSQLProvider

let config = try Config()
do {
    try config.addProvider(PostgreSQLProvider.Provider.self)
    try config.setup()
} catch {
    print(error)
}

public let drop = try Droplet(config)

do {
    try drop.setup()

    try drop.run()
} catch {
    print(error)
}

