import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(FacebookUser.self)
        let pivotTable = Pivot<FacebookUser,FacebookUser>.self
        pivotTable.rightIdKey = "facebookFriendId"
        preparations.append(pivotTable)
        preparations.append(TodoList.self)
        preparations.append(TodoItem.self)
        preparations.append(Pivot<TodoList,TodoItem>.self)
    }
}
