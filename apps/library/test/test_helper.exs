ExUnit.start()
Application.ensure_all_started(:mox)
Mox.defmock(Library.ProviderMock, for: Library.Provider)
