# verde-refdss
## Project Overview
The Verde River Wild and Scenic River Riverine Environmental Flow Decision Support System (REFDSS) will be used in determining the environmental flow needs of fish and riparian vegetation in the Verde River in Arizona by synthesizing multiple model outputs in R Studio. The DSS will take 2D hydrualic modeling outputs, habitat suitability requirements, and substrate information to quantify and map suitable habitat for species and lifestages of interest for each modeled discharge. The resulting habitat area-discharge relationships can be used to quantify habitat area under various flow scenarios. 

## General Process
The DSS is comprised of three parts:
1. Pre-processing: The script processes 2D hydraulic modeling results and rasterizes substrate maps. The outputs include rasterized modeling results and substrate map for use in fish or riparian vegetation habitat processing. 
2. Fish-processing: This script quantifies and maps habitat area for fish species based on their habitat suitability criteria using the rasterized modeling results and substrate map. Habitat area-discharge lookup tables and maps of habitat area by modeled discharge are returned. The outputs are species and lifestage (if applicable) specific.
3. Post-processing: This script determines fish habitat area and probability of riparian vegetation as a function of flow scenarios. For fish, habitat area is linearly interpolated from the habitat area-discharge lookup tables to give area available through the flow scenario. Probability of occurrence of riparian vegetation is determined as a function of the exceedance probabilities of inundating discharges. Exceedance probabilities are dependent on the flow scenario. The outputs of this script are still being developed.


### Descriptions of Functions
Fish_hab_master: Serves as the master script that handles user inputs and calls functions. Runs through functions using habitat metrics or lifestages. 

get.results: Pulls in iRIC output results as CSVs and fixes headers containing special characters. Returns a list of CSVs and a list of the modeled discharges.

get.gila: Reads in SR2DH text file outputs for rasterization. Adds headers and extracts modeled discharges.

iric.process.smr: Rasterizes the results in list of CSVs using attributes of user supplied DEM. Returns a rasterBrick of each habitat metric that contains the results for all modeled discharges.

load.cherry: Loads Cherry Creek raster files, stored in separate folders by hydraulic habitat variable, into the script. Will later be merged into load.external.R. Returns a rasterBrick of each habitat metric that contains the results for all modeled discharges.

find.hsc: Selects habitat suitability criteria from reach_hsc.csv for the current species.

find.sub: Selects substrate criteria from reach_substrate.csv for the current species.

bricks.rc: Reclassifies rasterBricks into suitable and unsuitable habitat based on habitat suitability criteria (HSC csv). Returns a Brick of suitable cells by discharge.

by.substrate: Takes a rasterized substrate type map of the same extent, resolution, and projection of DEM and reclassifies it into suitable or unsuitable substrate based on user supplied substrate criteria table. Uses the reclassified substrate map as a mask over the Brick of hydraulically suitable cells to extract cells that have suitable habitat. Returns a rasterBrick of suitable habitat.

remove.islands: Removes islands (small, isolated habitat areas) from suitable habitat area. The number of cells that constitutes an island can be specified.

total.area: Calculates total available and, optionally, reach-normalized habitat area by lifestage for the area-discharge reference tables. This function will also export the habitat area-discharge lookup tables to the dss_outputs folder if that option has been specified.

order.by.q: Puts rasters of total available habitat in order of ascending modeled Q for easy extraction. This function will also export the rasters to the dss_outputs folder if that option has been specified.

interp.table: Adds total available and normalized area (if applicable) to the hydrograph table. It will linearly interpolate between discharges to fill in areas for any discharges not run in iRIC. This function is not capable of extrapolation.

avg.monthly.area: Calculates the minimum average monthly area using a central running 10-day mean. 

x.day.stats: Calculates moving X-day minimum, maximum, and mean discharges and total area for a hydrograph.

q.ep.weibull: Calculates exceedance probability (EP) for discharges in flow scenario and modeled discharges. Exceedance probability is calculated from the Weibull plotting position.

make.ep.maps: Generates map of inundating discharges by cell and reclassifies that map to give the EP for each cell based on the flow scenario.

add_hydrograph: Adds the hydroperiod for each date in the hydrograph.

alter.hydrograph: Applies flow alterations to the historic flow record by hydroperiod so a flow scenario can be built.

#### Functions in Development
make.flow.scenario: Generates flow scenarios from the historic flow record. The historic flow record can be read from a USGS gage or CSV. Currently, flow scenarios can be percent reduction in flow or a fixed withdrawal.

interp.plot: Generates plots of total available and normalized area (if applicable) with the user supplied flow scenario.

## Descriptions of File Structure
Each reach should have its own folder with a unique reach name. This name should not contain any spaces. Within the reach folder there should be four sub-folders: model_outputs, habitat_info, dss_outputs, and flow_scenarios. The .RData files and substrate shapefile should be stored in the main reach folder.

### Required Folders
model_outputs: The rasterized or text-delimited results of 2D hydraulic modeling should be supplied here. Files must contain the discharge for which they were processed at. If results need to be rasterized, a DEM (.tif) of the reach needs to be provided in this folder as well.

habitat_info: CSVs of habitat suitability criteria (reach_name_hsc.csv) and substrate requirements (reach_name_substrate.csv) should be stored here. Only one file of each type should be in the folder. These files should contain the requirements for all species and lifestages in the study.

dss_outputs: Tifs of habitat area by discharge and CSVs of habitat area-discharge lookup tables will be output here by fish_processing.R. Results will be identified by species, lifestage, and discharge if applicable.

flow_scenarios: Flow scenarios, which may be created in R or externally, will be stored here as CSVs. The file names should lead with the reach_name and contain a unique identifier for the scenario.

## Future Developments
1. Improve visualization of habitat area through flow scenarios.
2. Incorporate riparian vegetation.
3. Add methods for comparing the results of multiple flow scenarios.

