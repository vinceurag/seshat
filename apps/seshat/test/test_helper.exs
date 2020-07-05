ExUnit.start()
Application.ensure_all_started(:mox)
Mox.defmock(Seshat.BookFinderAdapterMock, for: Seshat.BookFinder)
Mox.defmock(Seshat.ProviderMock, for: Seshat.Provider)
