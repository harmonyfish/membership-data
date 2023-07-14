library(tidyverse)

# import data -------------------------------------------------------------

##define the names of the files that will be read in
## for now testing with the 32 files for 2022/2023 season
filenames <- c("exports/2022_09_07.csv", "exports/2022_09_14.csv",
               "exports/2022_09_21.csv", "exports/2022_10_05.csv",
               "exports/2022_10_12.csv",  "exports/2022_10_19.csv",
               "exports/2022_10_26.csv", "exports/2022_11_04.csv",
               "exports/2022_11_09.csv", "exports/2022_11_18.csv",
               "exports/2022_11_25.csv", "exports/2022_12_02.csv",
               "exports/2022_12_13.csv", "exports/2022_12_30.csv",
               "exports/2023_01_06.csv", "exports/2023_01_13.csv",
               "exports/2023_01_20.csv", "exports/2023_01_27.csv",
               "exports/2023_02_03.csv", "exports/2023_02_17.csv",
               "exports/2023_02_24.csv", "exports/2023_03_03.csv",
               "exports/2023_03_10.csv", "exports/2023_03_17.csv",
               "exports/2023_03_24.csv", "exports/2023_03_31.csv",
               "exports/2023_04_07.csv", "exports/2023_04_14.csv",
               "exports/2023_04_21.csv", "exports/2023_04_28.csv",
               "exports/2023_05_05.csv", "exports/2023_05_12.csv",
               "exports/2023_05_19.csv", "exports/2023_05_26.csv",
               "exports/2023_06_02.csv", "exports/2023_06_09.csv"
               )
               
##create a blank object
tb <- NULL

## this is a thing to check that they are all adding together in the following loop
total <- c(1:length(filenames))

## for loop to read each file in and then add it to the previous
for (i in 1:length(filenames)) {
  #read in file
  df <- read_csv(filenames[i])
  #reduce to only more relevant columns
  df <-
    select(
      df,
      Date,
      `Contact Id`,
      `Membership 1 Rate`,
      `Mem Quantity`,
      `Club Quantity`,
      `Comped Shares`,
      `Membership 1 Pickups Remaining`
    )
  total[i] <- length(df$Date)
  #add newly read-in data to existing tibble
  tb <- add_row(df, tb)
               }
               
## check the total sum against the length of the tb
sum(total) == length(tb$Date)


## if this isn't true, we have a problem

# clean up data ------------------------------------------------------

## remove comp shares
tb2 <- filter(tb, is.na(`Comped Shares`))

tb.remaining <- filter(tb, `Membership 1 Pickups Remaining` > 1) %>%
  group_by(., `Contact Id`) %>%
  summarize(., total = sum(`Membership 1 Pickups Remaining`, na.rm = T))

tb.comp <- filter(tb, `Comped Shares` > 0)
## reduce membership types, rename the following types
# MEMMRKT
# MEMSUPP
# MEMSUST 
# Regular

tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "MEMMRKT"] <- "Market"
tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "Regular"] <- "Market"
tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "MEMSUPP"] <- "Supporter"
tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "MEMSUST"] <- "Sustainer"
tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "MEMCOMM"] <- "Community"

## this is just to check that there aren't extra mem types
by_memtype <- group_by(tb2, `Membership 1 Rate`)

summarize(by_memtype, total = sum(`Mem Quantity`, na.rm = T))

rm(by_memtype)


# analyses ----------------------------------------------------------------

## some summary things for the end of season 12

## total number of shares
## dividing by 2 here is rough, but people show up on the export each week and are therefore added to this
## yet only get a share half of the time
summarize(tb, total = sum(`Mem Quantity`, na.rm = T)) / 2

## this is total number of shares for paying customers and NS
summarize(tb2, total = sum(`Mem Quantity`, na.rm = T)) / 2

## this is total number of shares for comps
summarize(tb.comp, total = sum(`Mem Quantity`, na.rm = T)) /2 

## this is including staff/student comp shares
 (603 + 250 + 140) / 3418 * 100

## this is NOT including staff/student comp shares
(250 + 140) / 2806 * 100

  
## group by mem types
by_memtype_date <- group_by(tb2, `Membership 1 Rate`, Date)

## summing each mem type for each day
mems_thru_time <- summarize(by_memtype_date, total = sum(`Mem Quantity`, na.rm = T))


## group by each individual member
by_mem <- group_by(tb2, `Contact Id`)


memlength <- summarize(by_mem, memweeks = sum(`Mem Quantity`, na.rm = T))


# visualize ---------------------------------------------------------------

##this shows total member numbers through time

ggplot(data = mems_thru_time) +
  geom_line(mapping = aes(x = Date, y = total, color = `Membership 1 Rate`)) +
  theme_light() +
  labs(x = "Date", y = "Number of Members", title ="Memberships During 2022/2023")



ggplot(data = memlength, aes(memweeks)) +
  geom_histogram() +
  theme_light() +
  labs(x = "Number of Shares received", y = "Count")






# testing -----------------------------------------------------------------

## filter for anyone who has been a member all season, or had only one or fewer pickups
new <- filter(memlength, memweeks < 30)
new <- filter(new, memweeks > 1)

new2 <- filter(tb2, `Contact Id` %in% new$`Contact Id`)

## make mem quantity and id both factors

tb3 <- mutate(new2, MemQ = as.factor(new2$`Mem Quantity`), ID = as.factor(new2$`Contact Id`))

## this plots each member as line showing their total number of pickups through time
ggplot(tb3, aes(Date, `ID`)) +
  geom_tile(aes(fill = `MemQ`), colour = "grey50", na.rm = T) +
  labs(y = "Individual Member") +
  theme(axis.text.y=element_blank(),  #remove y axis labels
        axis.ticks.y=element_blank()  #remove y axis ticks
        )


## here's some test text for git experiments

