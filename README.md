# Seshat.Umbrella

## Overview

This umbrella project contains 3 apps

  - `seshat_web` - this contains the webhook that receives the events
  - `seshat` - this is the main bot engine that processes the events
  - `library` - this is the app that does everything related to books (provider-independent)
  - `analyzer` - this is the app that does everything related to sentiment analysis (provider-independent)

Under the hood, it uses ETS to maintain the state of the users using the chatbot.

The project is deployed in Gigalixir: [https://early-conscious-sandpiper.gigalixirapp.com/](https://early-conscious-sandpiper.gigalixirapp.com/)

## Test Coverage

### Analyzer

```
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/analyzer.ex                                17        1        0
  0.0% lib/analyzer/entities/sentiment.ex              8        0        0
100.0% lib/analyzer/provider.ex                       20        2        0
100.0% lib/analyzer/providers/watson.ex               28        5        0
100.0% lib/analyzer/providers/watson/client.ex        33        5        0
[TOTAL] 100.0%
----------------
```

### Library

```
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/library.ex                                 33        3        0
  0.0% lib/library/entities/book.ex                   11        0        0
  0.0% lib/library/entities/review.ex                 10        0        0
100.0% lib/library/provider.ex                        40        4        0
100.0% lib/library/providers/goodreads.ex            120       22        0
100.0% lib/library/providers/goodreads/client.e       25        4        0
[TOTAL] 100.0%
----------------
```

### Seshat

```
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/seshat.ex                                  36        7        0
  0.0% lib/seshat/application.ex                      22        2        2
 71.4% lib/seshat/conversation_store.ex               37        7        2
  0.0% lib/seshat/provider.ex                         12        0        0
100.0% lib/seshat/providers/facebook.ex               86       24        0
100.0% lib/seshat/providers/facebook/client.ex        38        7        0
  0.0% lib/seshat/providers/facebook/entities/p       11        0        0
  0.0% lib/seshat/providers/facebook/handler.ex       11        0        0
100.0% lib/seshat/providers/facebook/handlers/m      147       39        0
 83.3% lib/seshat/providers/facebook/handlers/p       70       18        3
100.0% lib/seshat/providers/facebook/response_b       65       15        0
  0.0% lib/seshat/providers/facebook/responses/        8        0        0
  0.0% lib/seshat/providers/facebook/responses/        9        0        0
  0.0% lib/seshat/providers/facebook/responses/       12        0        0
  0.0% lib/seshat/providers/facebook/responses/        8        0        0
  0.0% lib/seshat/providers/facebook/responses/        7        0        0
100.0% lib/seshat/verification.ex                     30        4        0
[TOTAL]  94.3%
----------------
```

### SeshatWeb (a little low due to the generated phx boilerplate)

```
----------------
COV    FILE                                        LINES RELEVANT   MISSED
  0.0% lib/seshat_web.ex                              75        1        1
  0.0% lib/seshat_web/application.ex                  28        4        4
  0.0% lib/seshat_web/channels/user_socket.ex         35        0        0
100.0% lib/seshat_web/controllers/privacy_polic        9        1        0
100.0% lib/seshat_web/controllers/webhook_contr       50       10        0
  0.0% lib/seshat_web/endpoint.ex                     51        0        0
100.0% lib/seshat_web/router.ex                       27        4        0
  0.0% lib/seshat_web/views/error_helpers.ex          16        2        2
100.0% lib/seshat_web/views/error_view.ex             16        1        0
  0.0% test/support/channel_case.ex                   34        1        1
100.0% test/support/conn_case.ex                      37        1        0
[TOTAL]  68.0%
----------------
```

To run the coverage tool, run this command in the root of the umbrella: `mix coveralls` or `mix coveralls.html`

## Setting up & Running the app

To run this on your machine, you must have the following environment variables:

  - FB_ACCESS_TOKEN
  - VERIFICATION_TOKEN
  - GOODREADS_API_KEY
  - WATSON_URL
  - WATSON_API_KEY

To run the app, `iex -S mix phx.server`