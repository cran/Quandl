library("httr")
source("test-datatable-helper.r")
source("test-helpers.r")

context("Getting Datatable data")

context("Quandl.datatable() call")
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    test_that("correct arguments are passed in", {
      expect_equal(http, "GET")
      expect_equal(url, "https://www.quandl.com/api/v3/datatables/ZACKS/FC")
      expect_null(body)
      expect_equal(query, list())
    })
    mock_response(content = mock_datatable_data())
  },
  `httr::content` = function(response, as="text") {
    response$content
  },
  Quandl.datatable("ZACKS/FC")
)

context("Quandl.datatable() call with options")
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    test_that("correct arguments are passed in", {
      expect_equal(http, "GET")
      expect_equal(url, "https://www.quandl.com/api/v3/datatables/ZACKS/FE")
      expect_null(body)
      expect_equal(query, list('ticker[]'='AAPL', 'ticker[]'='MSFT',
                               per_end_date.gt='2015-01-01', code='FOO',
                               'qopts.columns[]'='ticker', 'qopts.columns[]'='per_end_date',
                               'qopts.columns[]'='tot_revnu'))
    })
    mock_response(content = mock_datatable_data())
  },
  `httr::content` = function(response, as="text") {
    response$content
  },
  Quandl.datatable("ZACKS/FE", ticker=c('AAPL', 'MSFT'),
                               per_end_date.gt='2015-01-01',
                               code='FOO',
                               qopts.columns=c('ticker','per_end_date','tot_revnu'),
                    paginate=FALSE)
)

context("Quandl.datatable() response with cursor")
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    mock_response(content = mock_datatable_data("\"cursor_foo_bar\""))
  },
  `httr::content` = function(response, as="text") {
    response$content
  },
  `Quandl:::quandl.datatable.max_rows` = function() {
    return(100)
  },
  test_that("warning message is displayed regarding more data when cursor_id is present in response", {
    expect_warning(Quandl.datatable('ZACKS/FE'),
                   paste("This call returns more data. To request more pages, please set paginate=TRUE",
                         "in your Quandl.datatable() call. For more information see our documentation:",
                         "https://github.com/quandl/quandl-r/blob/master/README.md#datatables"), fixed = TRUE)
  }),
  test_that("warning message is displayed when max number of rows fetched is reached", {
    expect_warning(Quandl.datatable('ZACKS/FE', paginate=TRUE),
      paste("This call returns a larger amount of data than Quandl.datatable() allows.",
            "Please view our documentation on developer methods to request more data.",
            "https://github.com/quandl/quandl-r/blob/master/README.md#datatables"), fixed = TRUE)
  })
)

context("Quandl.datatable() response with cursor and suppressed warning")
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    mock_response(content = mock_datatable_data("\"cursor_foo_bar\""))
  },
  `httr::content` = function(response, as="text") {
    response$content
  },
  `Quandl:::quandl.datatable.max_rows` = function() {
    return(100)
  },
  `warning` = function(warning, ...) {
    return(TRUE)
  },
  test_that("response data contains max rows if paginate=TRUE is set", {
    data <- Quandl.datatable('ZACKS/FC', paginate=TRUE)
    expect_equal(nrow(data), 100)
  })
)

context("Quandl.datatable() response")
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    mock_response(content = mock_datatable_data())
  },
  `httr::content` = function(response, as="text") {
    response$content
  },
  test_that("response data is data frame", {
    expect_is(Quandl.datatable('ZACKS/FC'), "data.frame")
  }),
  test_that("column names are set", {
    data <- Quandl.datatable('ZACKS/FC')
    expect_equal(names(data), c("ticker", "oper_income", "comm_share_holder", "per_end_date"))
  }),
  test_that("response data columns are converted to proper data types", {
    data <- Quandl.datatable('ZACKS/FC')
    expect_is(data[,1], "character")
    expect_is(data[,2], "numeric")
    expect_is(data[,3], "numeric")
    expect_is(data[,4], "Date")
  }),
  test_that("response data is one page if paginate=TRUE is not set", {
    data <- Quandl.datatable('ZACKS/FC')
    expect_equal(nrow(data), 25)
  })
)

context("Quandl.datatable() empty data response")
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    mock_response(content = mock_empty_datatable_data())
  },
  `httr::content` = function(response, as="text") {
    response$content
  },
  test_that("empty response data columns are converted to proper data types", {
    data <- Quandl.datatable('ZACKS/FC')
    expect_equal(nrow(data), 0)
    expect_is(data[,1], "character")
    expect_is(data[,2], "numeric")
    expect_is(data[,3], "numeric")
    expect_is(data[,4], "Date")
  })
)

context("Quandl.datatable() response new column types")
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    mock_response(content = mock_datatable_data_extra_columns())
  },
  `httr::content` = function(response, as="text") {
    response$content
  },
  test_that("response data columns are converted to proper new data types", {
    data <- Quandl.datatable('USTRE/AUCTHIST')
    expect_is(data[,1], "numeric")
    expect_is(data[,2], "POSIXct")
  })
)
context("Quandl.datatable.bulk_download_url()")
with_mock(
  `Quandl:::quandl.api` = function(path, filename, ...) {
    test_that("correct arguments are passed to api layer", {
      params <- list(...)
      expect_equal(params$ticker, "AAPL")
      expect_equal(params$qopts.export, 'true')
      expect_equal(path, "datatables/ZACKS/EE")
    })
    json_response <- tryCatch(jsonlite::fromJSON(mock_datatable_export_response_fresh(), simplifyVector = TRUE), error = function(e) {
      stop(e, " Failed to parse response: ", text_response)
    })
    json_response
  },
  Quandl.datatable.bulk_download_url("ZACKS/EE", "folder/exists/NSE.zip", ticker="AAPL")
)
context("Quandl.datatable.bulk_download_url ready detection")
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    mock_response(content = mock_datatable_export_response_creating())
  },
  `httr::content` = function(response, as = "text") {
    response$content
  },
  test_that("detect response is not ready", {
    not_ready_response <- Quandl:::quandl.api('datatables')
    ready <- Quandl:::quandl.datatable.export_ready(not_ready_response, '2019-05-23')
    expect_equal(ready, FALSE)
  })
)
with_mock(
  `httr::VERB` = function(http, url, config, body, query) {
    mock_response(content = mock_datatable_export_response_fresh())
  },
  `httr::content` = function(response, as = "text") {
    response$content
  },
  test_that("detect response is ready", {
    ready_response <- Quandl:::quandl.api('datatables')
    ready <- Quandl:::quandl.datatable.export_ready(ready_response, '2019-05-23')
    expect_equal(ready, TRUE)
    })
)
reset_config()
