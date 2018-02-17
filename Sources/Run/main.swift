import App

let config = try Config()
do {
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

