library(tidyverse)
library(magrittr)
library(lubridate)

# Initial data
rawdat <- readRDS(url("https://github.com/co-analysis/mwmi.govuk.data/blob/main/data/output/cleaned_data.RDS?raw=TRUE","rb"))

# Create a named list
named_list <- function(vals,noms) {
  x <- as.list(vals)
  names(x) <- noms
  x
}

# coding of civil service and non
org_coding <- read_csv("data/org_types.csv")
org_type_labels <- org_coding$org_type_label

# User friendly labels for sub_groups
sub_group_coding <- read_csv("data/sub_group_labels.csv")

payroll_sub_labels <- sub_group_coding %>%
  filter(group=="payroll",sub_group!="total") %$%
  named_list(sub_group,sub_group_label)
payroll_cost_sub_labels <- sub_group_coding %>%
  filter(group=="payroll costs",sub_group!="total") %$%
  named_list(sub_group,sub_group_label)
nonpayroll_sub_labels <- sub_group_coding %>%
  filter(group=="non payroll",!sub_group%in%c("consultants","total")) %$%
  named_list(sub_group,sub_group_label)

# User friendly labels for measures
measure_coding <- read_csv("data/measure_labels.csv")
# Named list of measures
measure_labels <- measure_coding %$% named_list(measure,measure_label)

dat <- rawdat %>%
  mutate(Date=dmy(paste0(1,"-",Month,"-",Year))) %>%
  mutate(org_type_lower=tolower(org_type)) %>%
  left_join(org_coding) %>%
  left_join(sub_group_coding) %>%
  left_join(measure_coding) %>%
  mutate(coredept=Department!=Body) %>%
  rename('Organisation type'=org_type_label)

pivot_data <- dat %>%
  filter(sub_group!="total") %>%
  select(Department,Body,Org_type=`Organisation type`,
         Year,Month,
         Group=group,Sub_group=sub_group_label,
         Measure=measure_label,value)
