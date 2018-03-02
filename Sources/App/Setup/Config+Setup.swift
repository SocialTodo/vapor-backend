import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        do {
            try setupProviders()
            try setupPreparations()
        } catch { print(error) }
        
    }
    
    /// Configure providers
    private func setupProviders() throws {
        do {
            try addProvider(FluentProvider.Provider.self)
        } catch { print(error) }
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(FacebookUser.self)
        preparations.append(FacebookFriends.self)
        preparations.append(TodoList.self)
        preparations.append(TodoItem.self)
        preparations.append(Pivot<TodoList,TodoItem>.self)
        preparations.append(Pivot<TodoItem,FacebookUser>.self)
    }
}
