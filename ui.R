source("R/load libraries.R")
# modify dashboardHeader() to accept non-list tags so that we can put in title text
# TODO: disable header and replace with a custom header
source("R/uncheckedHeader.R",local=TRUE)

header <- uncheckedHeader(
  title = NULL,
  titleWidth=0,
  tags$span("UK Government monthly workforce management information",
            style="font-size:20px; text-align:center; padding-right:15px; height:50px; line-height:50px")
)

source("R/javascript header scripts.R",local=TRUE)

# Main tab box with data displays
source("R/uiDatabox.R",local=TRUE)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"), # Static CSS file to tweak appearance
    heightfunction), # resizes .maindisplay to 70% of screen height
  
  rclipboardSetup(), # Needed to copy to clipboard
  
  fluidRow(
    column(width=9,
           tabBox(width = NULL,
                  selected="About",
                  id='maintab',
                  about_panel,
                  payroll_panel,
                  nonpayroll_panel,
                  consultant_panel
           ),
           
           box(width=NULL,
               div(style="padding: 5px 5px; display: inline",downloadButton("download","Download data set")),
               div(style="padding: 5px 5px; display: inline",uiOutput("clip"))
               # ""
           ),
           
           box(width=NULL,HTML('Contains data published by Government Departments on <a href="https://www.gov.uk/search/all?keywords=%22monthly+workforce+management+information%22&order=relevance">gov.uk</a> used under the <a href="http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/">Open Government Licence</a>'))
    ),
    column(width=3,
       box(width=NULL,
           status="info",
           collapsible=FALSE,
           airDatepickerInput('dateRange',
                              # value=c("2021-06-01",as.character(max(dat$Date))),
                              value=c(Sys.Date()-365,min(Sys.Date(),as.character(max(dat$Date)))),
                              label = "Date range",
                              range=TRUE,
                              dateFormat = "yyyy-mm",
                              minDate = min(dat$Date),
                              maxDate=max(dat$Date),
                              minView="months",
                              view="months",
                              autoClose=TRUE,
                              update_on="close",
                              toggleSelected=FALSE),
           selectInput("measures","Measure",measure_labels,selected="fte"),
           awesomeCheckbox("body_show","Show bodies within organisations",FALSE),
           awesomeCheckbox("org_type_show","Show organisation type in table",FALSE),
           awesomeCheckboxGroup("org_type_select","Organisation types",
                                choices=org_type_labels,
                                selected=setdiff(org_type_labels,"Executive Non-departmental Public Body")),
           uiOutput("dept_filter")
       ),
       box(width=NULL,
           status="info",
           collapsible=FALSE,
           uiOutput("subgroup_filters")
           )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable=TRUE),
  body,
  skin='black'
)