source("R/load libraries.R")
# good practice to load all libraries in one place (doesn't seem to work?)
# Relatedly - this app needs something to manage packages (e.g. packrat)



################################################################################
# Per session 

# Default view of the dash (updated based on url if relevant)
default_view <- list(tab="About",measure="fte")

server <- function(input,output,session) {
  
  ################################################################################
  # Load dataset - in server to enforce refresh
  source("R/data setup.R") 
  # Returns a 'clean' data.frame 'dat'
  
  
  ################################################################################
  # Initial values
  
  # Reactives
  s = reactiveValues()
  
  # Dash view (tab, measure)
  s$view <- default_view 
  # baseurl stores the current home of the shiny dashboard, either locally or once online
  s$baseurl = isolate(paste0(session$clientData$url_protocol,"//",session$clientData$url_hostname,session$clientData$url_pathname))
  # s$baseurl = isolate(paste0(session$clientData$url_protocol,"//",session$clientData$url_hostname,":",session$clientData$url_port,session$clientData$url_pathname))
  # dynamic url is initially set to the base
  s$url = isolate(s$baseurl)
  
  # Encodes and decodes between URL and selected data view
  source("R/urlHandling.R",local=TRUE)
  # Observer to update s$view from URL, reactive on: session$clientData$url_search
  # Defines function to make URL based on selection and view: makeURL()
  
  ################################################################################
  # UI elements
  ########################################
  # Filters for sub groups
  output$subgroup_filters <- renderUI({
    sub_filt <- NULL
    
    if (input$maintab=="Payroll staff" & input$measures%in%c("costs","costperfte")) {
      sub_filt <- awesomeCheckboxGroup("sub_select","Payroll costs",
                              payroll_cost_sub_labels,
                              # selected=unlist(payroll_cost_sub_labels))
                              selected="total")
    }
    if (input$maintab=="Payroll staff" & !input$measures%in%c("costs","costperfte")) {
      sub_filt <- awesomeCheckboxGroup("sub_select","Payroll staff",
                                       choices=payroll_sub_labels,
                                       # selected=unlist(payroll_sub_labels))
                                       selected="total")
    }
    if (input$maintab=="Non-payroll staff" & !input$measures%in%c("costs","costperfte")) {
      sub_filt <- awesomeCheckboxGroup("sub_select","Non-payroll staff",
                                       choices=nonpayroll_sub_labels,
                                       # selected=unlist(nonpayroll_sub_labels))
                                       selected="total")
    }
    sub_filt
  })
  
  # Filter for Departments
  output$dept_filter <- renderUI({
    dept_labs <- dept_vals
    names(dept_labs) <- str_sub(dept_vals,1,40)
    pickerInput(inputId="dept_select",
                label="Select organisations",
                choices=dept_labs,
                selected=dept_labs,
                multiple=TRUE,
                options=list(`actions-box`=TRUE,dropdownAlignRight=FALSE,size=10))
    })
  
  ########################################
  # Current data set for download
  downloadData <- reactive({
    downloadData <- NULL
    if (input$maintab=="Payroll staff") downloadData <- payroll_filtered()
    if (input$maintab=="Non-payroll staff") downloadData <- nonpayroll_filtered()
    if (input$maintab=="Consultants / consultancy") downloadData <- consultant_filtered()
    if (!is.null(downloadData)) {
      meta <- c(header2_title(),header2_line1(),header2_line2())
      if (input$measures=="costperfte") meta <- c(meta,header2_line3())
      meta <- data.frame(Department=meta)
      downloadData <- bind_rows(downloadData,meta)
    }
    downloadData    
  })
  
  output$download <- downloadHandler(
    filename = function() {
      paste(input$maintab,"-",input$measures,"-", Sys.Date(), ".csv", sep="")
    },
    content = {
      # Forcing to windows western european encoding to handle '£' - may need to offer a utf-8 version?
      function(file) write.csv(downloadData(),file,row.names=FALSE,fileEncoding="windows-1252")
    }
  )
  
  ########################################
  source("R/uiTableHeaders.R",local=TRUE)
  
  # Unique names required for inputs and outputs
  output$table_header_a <- renderText({header2()})
  output$table_header_b <- renderText({header2()})
  output$table_header_c <- renderText({header2()})
  
  ########################################
  # Copy a url that links to this view
  output$clip <- renderUI({
    urllink <- paste0(s$baseurl,"?tab=",input$maintab,"&measure=",input$measures) %>%
      URLencode
    
    rclipButton(inputId="clipbtn",
                label="Copy a link to this view",
                clipText=urllink,
                icon=icon("link",lib="glyphicon"))
  })
  ################################################################################
  # Data sets
  ########################################
  # Function for filtering and summarising
  common_filtration <- function(obj) {
    group_list <- c("Year","Month","Department")
    arrange_list <- c("Department")
    if (input$body_show) {
      group_list <- c(group_list,"coredept","Body")
      arrange_list <- c(arrange_list,"coredept","Body")
    }
    if (input$org_type_show) {
      group_list <- c(group_list,"Organisation type")
      arrange_list <- c(arrange_list,"Organisation type")
    }
    group_list <- c(group_list,"Group","Measure")

    # Format according to data measure
    form_function <- if(input$measures%in%c("costs","costperfte")) {
      function(x) round_half_up(x) %>% format(big.mark=",",trim=TRUE) %>% paste0("£",.) %>% gsub("£ *NA","-",.)
    } else {
      function(x) round_half_up(x) %>% format(big.mark=",",trim=TRUE) %>% gsub(" *NA","-",.)
    }
    
    sum_na <- function(x) {
      ifelse(any(!is.na(x)),sum(x,na.rm=T),0*NA)
    }
    
    print(head(obj,2))
    
    obj_out <- obj %>%
      mutate(Group=sub_group_label,Measure=measure_label) %>%
      filter(measure==input$measures) %>%
      filter(Department%in%input$dept_select) %>%
      filter(`Organisation type` %in% input$org_type_select) %>%
      filter(Date >= input$dateRange[1],Date <= input$dateRange[2]) %>%
      # filter(sub_group!="total") %>%
      group_by(across(group_list))
    
    if (input$measures=="costperfte") {
      obj_out <- obj_out %>%
        group_by(sub_group,.add=TRUE) %>%
        summarise(sumval=sum_na(costs)/sum_na(fte_total)) %>%
        ungroup(sub_group) %>%
        summarise(sumval=sum_na(sumval)) %>%
        mutate(sumval=ifelse(is.finite(sumval),sumval,NA))
    } else {
      obj_out <- obj_out %>%
        summarise(sumval=sum_na(value))
    }
    
    obj_out <- obj_out %>%
      pivot_wider(names_from=c(Year,Month),values_from=sumval,names_sep=" ") %>%
      ungroup() %>%
      arrange(across(arrange_list)) %>%
      select(-one_of('coredept')) %>%
      mutate(Department=ifelse(duplicated(Department),"",Department)) %>%
      mutate(across(where(is.numeric),form_function))
    obj_out
  }
  
  ########################################
  # Payroll staff data set
  payroll_filtered <- reactive({
    dat %>%
      filter(group%in%c("payroll","payroll costs")) %>%
      filter(sub_group%in%input$sub_select) %>%
      common_filtration
  })
  output$payroll_total <- renderTable(payroll_filtered(),align="r",digits=0)

  ########################################
  # Non payroll staff data set
  nonpayroll_filtered <- reactive({
    dat %>%
      filter(group%in%c("non payroll","non payroll costs"),!sub_group=="consultants") %>%
      filter(sub_group%in%input$sub_select | measure%in%c("costs","costperfte")) %>%
      common_filtration
  })
  output$nonpayroll_total <- renderTable(nonpayroll_filtered(),align="r")
  
  ########################################
  # Consultant data set
  consultant_filtered <- reactive({
    dat %>%
      filter(group%in%c("non payroll","non payroll costs"),sub_group=="consultants") %>%
      common_filtration
  })
  output$consultant_total <- renderTable(consultant_filtered(),align="r")
  
  ################################################################################


}