ExUnit.start()
Application.ensure_all_started(:mox)
Mox.defmock(Analyzer.ProviderMock, for: Analyzer.Provider)
