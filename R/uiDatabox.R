################################################################################
# Panels
########################################

about_panel <- tabPanel(title="About",div(class="maindisplay",
h4("Introduction"),
"This dashboard brings together the figures published by Government Departments in their monthly workforce 
management information reporting, as part of the UK Government transparency agenda.",
p(),
"The information includes headcount, full-time equivalent employment, and salary and other costs for 
both payroll and non-payroll employees. All Civil Service organisations as well as Executive Non-departmental 
Public Bodies (ENDPBs) are in scope for these publications.",
p(),
"Please note that figures presented here are automatically collated, have not been quality assured or 
verified, and are provided 'as is' based on the tables
published by individual Departments. These can all be found on gov.uk using the search 
term 'workforce management information'.",
p(),
"For further enquiries, please contact: psmgreporting@cabinetoffice.gov.uk",
h4("How to use this dashboard"),
"Each tab (e.g. 'Payroll staff', 'Non-payroll staff') shows a summary data table for that group of employees, 
split by Department and date.",
p(),
"The filters to the right allow you to specify the date range included, the measure 
(headcount / FTE / monthly costs), whether to show the results at the level of individual bodies, and which 
organisation types to include in the figures.",
p(),
"Where data is reported with additional detail, which sub-groups 
to include within the data can be selected in the second set of filters (e.g. which types of non-payroll staff).",
p(),
"To download the table, select the 'Download data set' button at the bottom left of the page and the table 
will begin to download in .csv format",
""
))

payroll_panel <- tabPanel(title="Payroll staff",
                          htmlOutput("table_header_a"),
                          div(class='maindisplay', tableOutput('payroll_total')))

nonpayroll_panel <- tabPanel(title="Non-payroll staff",
                             htmlOutput("table_header_b"),
                             div(class='maindisplay', tableOutput('nonpayroll_total')))

consultant_panel <- tabPanel(title="Consultants / consultancy",
                             htmlOutput("table_header_c"),
                             div(class='maindisplay', tableOutput('consultant_total')))

pivot_panel <- tabPanel(title="Custom data view",div(class="maindisplay",
                                                     rpivotTable(pivot_data,
                                                                 rows=list("Department","Body"),
                                                                 cols=list("Year","Month"),
                                                                 inclusions=list(Measure=list("FTE"),Group=list("payroll")),
                                                                 exlusions=list(Org_type=list("Executive Non-departmental Public Body")),
                                                                 aggregatorName="Sum",
                                                                 vals="value",
                                                                 rendererName="Table")))


