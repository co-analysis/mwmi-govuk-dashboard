########################################
# Table headers
header2_title <- reactive({
  paste0(input$maintab,": ",
         filter(measure_coding,measure==input$measures)$measure_label," by Department",
         ifelse(input$body_show==TRUE,", body,",""),
         " and reporting month")
})
header2_line1 <- reactive({
  paste0("Includes: ",paste0(input$org_type_select,collapse=", "))
})
header2_line2 <- reactive({
  paste0(
    ifelse(input$maintab=="Payroll staff" | (input$maintab=="Non-payroll staff" & !input$measures%in%c("costs","costperfte")),
           paste0("Includes: ",
                  paste0(sub_group_coding %>% filter(sub_group%in%input$sub_select) %>% pull(sub_group_label),collapse=", ")),
           ""),
    ifelse(input$maintab=="Non-payroll staff" & input$measures%in%c("costs","costperfte"),
           paste0("Includes: ",
                  paste0(names(nonpayroll_sub_labels),collapse=", ")),
           ""),
    ifelse(input$maintab=="Consultants / consultancy","Includes: Consultants / consultancy","")
  )
})

header2_line3 <- reactive({
  paste0(
    ifelse(input$measures%in%c("costperfte"),"Note: Monthly costs per FTE are calculated from the published data, and have not been verified by Departments","")
  )
})

header2 <- reactive({
  paste0("<span class=table-header1>",header2_title(),
         "</span><br><span class=table-header2>",
         header2_line1(),
         "<br>",
         header2_line2(),
         ifelse(input$measures%in%c("costperfte"),"<br>",""),
         header2_line3(),
         "</span>")
})