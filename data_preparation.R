#Below, I prepare the data for the province of BC--you could reproduce these steps for another province, too
#I've taken this intermediate step because the full census data file is huge and could be a lag for some users

#Putting this here so you know which packages you need! 
library(openxlsx)
library(rstudioapi)

#Set the directory where this file sits as the working directory
current_directory = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(current_directory)



#Get the census data for BC 
#Note the filename is based on a table number which you can look up with StatCan
census_data_file = ("/home/abed/Documents/Blogging/Arabs in Metro Vancouver/Census_Data_Profile_2021_Census/98-401-X2021029_English_CSV_data.csv")
#Having had a look through 
#Starting on line 807719
#Ending on line 923482
starting_line = 807719
ending_line = 923482
number_of_rows = ending_line - starting_line 
census_data_BC_only = read.csv(census_data_file, nrows = number_of_rows, skip = (starting_line - 1), header = FALSE)
#census_metadata = read.csv(census_data_file, nrows = 1)

#Remove that silly white space which makes it impossible to read in the ethnocultural groups
for(j in 1:ncol(census_data_BC_only))
{
  census_data_BC_only[,j] = str_remove_all(census_data_BC_only[,j], " ")
}


#The below change of column names actually won't work--some more work needs to be done to prep it
#colnames(census_data_BC) = census_metadata

#Now, we export the data to make it easier for the app to just read it in. 
openxlsx::write.xlsx(census_data_BC_only, file = "data_here/BC_census_data.xlsx", overwrite = TRUE)

#We also need to make sure that we have the correct names for the column headings
##Names were modified in the Excel spreadsheet to make it possible to do look ups here--this was manually done
#Look for References2 which becomes "updated_table" in the support file. 

#Extract and spit out the list of the nationalities so that it can be used in the app
census_data_lookup_nationalities = openxlsx::read.xlsx("data_here/BC_census_data.xlsx", rows = 1700:1949, cols = 10)
openxlsx::write.xlsx(census_data_lookup_nationalities, "data_here/list_of_nationalities.xlsx")