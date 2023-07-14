##dusting off some cobwebs
library(nycflights13)
library(tidyverse)
# filter() allows you to subset observations based on their values. The first argument is the name of the data frame. The second and subsequent arguments are the expressions that filter the data frame.
filter(flights, month==1, day==1)

jan1 <- (filter(flights, month==1, day==1))
jan1
##arrange arrange() works similarly to filter() except that instead of selecting rows, it changes their order. It takes a data frame and a set of column names (or more complicated expressions) to order by. If you provide more than one column name, each additional column will be used to break ties in the values of preceding columns
arrange(flights, year, month, day)

arrange(flights, dep_time)
#desc() to re-order by a column in descending ord
arrange(flights,desc(dep_time))
# Select columns with select()

select(flights, year, month, day)
# Another option is to use select() in conjunction with the everything() helper. This is useful if you have a handful of variables you’d like to move to the start of the data frame.

# mutate() always adds new columns at the end of your dataset so we’ll start by creating a narrower dataset so we can see the new variables. Remember that when you’re in RStudio, the easiest way to see all the columns is View().

#summarise() is not terribly useful unless we pair it with group_by(). This changes the unit of analysis from the complete dataset to individual groups. Then, when you use the dplyr verbs on a grouped data frame they’ll be automatically applied “by group”. 


library(tidyverse)
df<- read_csv("exports/2022_09_07.csv")
