##Work to find all possible ethnocultural origins in the census 
raw_censusdata = read.csv("/home/abed/Documents/Blogging/Arabs in Metro Vancouver/Census_Data_Profile_2021_Census/98-401-X2021029_English_CSV_data.csv")
characeristicamedata = raw_censusdata$CHARACTERISTIC_NAME
#Row numbers are here 
startrow = 1699
endrow = 1949 
ethnicities = characeristicamedata[startrow:endrow]





df_of_codes_names = data.frame(cbind(unique(census_data_BC$V2), unique(census_data_BC$V5)))
df_of_codes_names = df_of_codes_names[-1,]
df_of_codes_names$NamesToBring = unique(bc_fed_map@data$ED_NAMEE)
openxlsx::write.xlsx(x = df_of_codes_names, "/home/abed/Documents/Blogging/Arabs in Metro Vancouver/References2.xlsx")
##Names were modified in the Excel spreadsheet to make it possible to do look ups here
updated_table = openxlsx::read.xlsx("/home/abed/Documents/Blogging/Arabs in Metro Vancouver/References2.xlsx")
colnames(updated_table)[3] = "ED_NAMEE"
#Let's make a copy, just in case
bc_fed_map_2 = bc_fed_nova

#Fix this for some reason
palestinians_in_bc_cropped$Palestinians = as.numeric(palestinians_in_bc_feds$V12[2:44])
palestinians_in_bc_cropped = palestinians_in_bc_cropped[,c(1:4)]
colnames(palestinians_in_bc_cropped) = c("Geocodes", "FEDNAME", "Pop", "PopB")


bc_fed_map_2 = dplyr::left_join(bc_fed_map_2, updated_table, by = "ED_NAMEE")
bc_fed_map_2 = dplyr::left_join(bc_fed_map_2, palestinians_in_bc_cropped, by = "Geocodes")

#
#bc_data_cropped = census_data_BC_copy[which(census_data_BC_copy$V10 == "Population,2016"),]
sampling_of_bc_data = palestinians_in_bc_feds[2:44,]
sampling_of_bc_data = sampling_of_bc_data[,c(5, 12)]