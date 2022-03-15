################################################################################
# Reactive expressions

# Initialize view off url
observe({
  query <- parseQueryString(session$clientData$url_search)
  isolate({
    view <- s$view
    for (p in c('tab','measure')) if (!is.null(query[[p]])) view[[p]] = URLdecode(query[[p]])
    s$view <- view
    
    updateTabsetPanel(session,"maintab",selected=s$view$tab)
    updateSelectInput(session,"measures",selected=s$view$measure)
  })
})

################################################################################
