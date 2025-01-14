library(sf)
library(terra)
library(rgdal)
library(stringi)
library(stringr)
library(rstudioapi)

##This is the back-up script to the Shiny App highlighting the distribution of different "ethnocultural" groups
#across the Federal Electoral Districts (FEDs) in BC. 

#This will make it easier to carry the data files/code around from one directory to another
current_directory = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(current_directory)


#Read in the map with the federal electoral districts
#Note that this map can be found here: 
bc_fed_nova = sf::st_read("shapes_feds/BC/SHAPEFILE/FED_A_FINAL_REPORT_BC.shp")
#We need to project it properly and add points for longitude and latitude
#The longitude/latitude pairs for each polygon become the site of the markers 
bc_fed_nova = sf::st_transform(bc_fed_nova, 4326)
bc_centroids = data.frame(st_coordinates(st_centroid(bc_fed_nova$geometry)))
bc_fed_nova$X = bc_centroids[,1]
bc_fed_nova$Y = bc_centroids[,2]



#We need to import the census data for BC 
census_data_BC = openxlsx::read.xlsx("data_here/BC_census_data.xlsx")
#Let's use a "copy" just in case
census_data_BC_copy = census_data_BC


#We need this table to be here as an intermediate step to be able to bind the column names from the map and the census data
updated_table = openxlsx::read.xlsx("data_here/References2.xlsx")
colnames(updated_table)[3] = "ED_NAMEE"
#The next step was done separately for the original census data
updated_table$NamesInCensus = str_remove_all(updated_table$NamesInCensus, " ")
colnames(updated_table)[2] = "FED"
colnames(census_data_BC_copy)[5] = "FED"

#Now we bring the two references together: the names of the FEDs + the census data by riding
census_data_BC_copy = dplyr::left_join(census_data_BC_copy, updated_table, by = "FED")


#We need a function which will return the combined data + map to the user of the app
#First to extract the right group, then to bind that data to the 
extract_bind_specific_group <- function(nationalgroup, mapdatainput)
{
  #"nationalgroup" is the name of an ethnic category
  #"mapdatainput" 
  extracted_group = census_data_BC_copy[which(census_data_BC_copy$V10 == nationalgroup),]
  #We ensure that the extracted group has the correct names by doing this
  extracted_group = dplyr::left_join(extracted_group, updated_table, by = "ED_NAMEE")
  mapdataoutput = dplyr::left_join(mapdatainput, extracted_group, by = "ED_NAMEE")
  return(mapdataoutput)
  print("A data map is born")
}

extracted_group = extract_bind_specific_group("Lebanese", mapdatainput = bc_fed_nova)


#The second function is just a way to get to the first, but it takes the result mapdataouput
# and creates a new column which 
print_out_attach_messages <- function(nationalgroupB, mapdatainputB)
{
  extracted_data = extract_bind_specific_group(nationalgroup = nationalgroupB, mapdatainput = mapdatainputB)
  
  extracted_data$MESSAGE = NULL 
  for(i in 1:nrow(extracted_data))
  {
    extracted_data$MESSAGE[i] = paste("In 2021, the number of people who defined their ethnicity as ", nationalgroupB, "in the district of ", extracted_data$ED_NAMEE[i], " was ", extracted_data$V12[i])
  }
  
  #print(extracted_data$MESSAGE)
  return(extracted_data)
}
