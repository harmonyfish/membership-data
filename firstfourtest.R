# first four --------------------------------------------------------------



## for now testing with the first 4 files
filenames <- c("exports/2022_09_07.csv", "exports/2022_09_14.csv",
               "exports/2022_09_21.csv", "exports/2022_10_05.csv")

##create a blank object
tb <- NULL

## this is a thing to check that they are all adding together in the following loop
total <- c(1:4)

## for loop to read each file in and then add it to the previous
for (i in 1:4){
  #read in file
  df<- read_csv(filenames[i])
  #reduce to only more relevant columns
  df<-select(df, Date, `Contact Id`, `Membership 1 Rate`, `Mem Quantity`, `Club Quantity`,
             `Comped Shares`)
  total[i]<-length(df$Date)
  #add newly read-in data to existing tibble
  tb<-add_row(df,tb)
}

## check the total sum against the length of the tb
sum(total) == length(tb$Date)

## if this isn't true, we have a problem

# clean up data ------------------------------------------------------

## remove comp shares
tb2 <- filter(tb, is.na(`Comped Shares`))

## reduce membership types, rename the following types
# MEMMRKT
# MEMSUPP
# MEMSUST 
# Regular

tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "MEMMRKT"] <- "Market"
tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "Regular"] <- "Market"
tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "MEMSUPP"] <- "Supporter"
tb2$`Membership 1 Rate`[tb2$`Membership 1 Rate` == "MEMSUST"] <- "Sustainer"

## this is just to check that there aren't extra mem types
by_memtype <- group_by(tb2, `Membership 1 Rate`)

summarize(by_memtype, total = sum(`Mem Quantity`, na.rm = T))


by_memtype_date <- group_by(tb2, `Membership 1 Rate`, Date)

new <- summarize(by_memtype_date, total = sum(`Mem Quantity`, na.rm = T))


# visualize ---------------------------------------------------------------

ggplot(data = new) +
  geom_line(mapping = aes(x = Date, y = total, color = `Membership 1 Rate`))
