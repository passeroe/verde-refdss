# verde-refdss
## Project Overview
The Verde River Wild and Scenic River Riverine Environmental Flow Decision Support System (REFDSS) will be used in determining the environmental flow needs of fish and riparian vegetation in the Verde River in Arizona by synthesizing multiple model outputs in R Studio. The DSS will take hydrualic modeling outputs, habitat suitability requirements, and substrate information to generate suitable habitat for species and lifestages of interest.

### General Process
The script rasterizes iRIC solvers' calculation results based on a DEM of the reach using bilinear interpolation. Alternatively, externally rasterized results can be brought into the script for analysis. The rasters are reclassified into suitable and unsuitable habitat using the provided habitat suitability criteria. The results of the script include area-discharge reference tables and maps of available habitat with discharge. If flow scenarios are provided, area through the hydrograph can also be estimated.

### Descriptions of Functions
Fish_hab_master: Serves as the master script that handles user inputs and calls functions. Runs through functions using habitat metrics or lifestages. 

get.results: Pulls in iRIC output results as CSVs and fixes headers containing special characters. Returns a list of CSVs and a list of the modeled discharges.

iric.process.smr: Rasterizes the results in list of CSVs using attributes of user supplied DEM. Returns a rasterBrick of each habitat metric that contains the results for all modeled discharges.

load.cherry: Loads Cherry Creek raster files, stored in separate folders by hydraulic habitat variable, into the script. Will later be merged into load.external.R. Returns a rasterBrick of each habitat metric that contains the results for all modeled discharges.

load.delaware. Loads raster files from the Delaware study. Results for hydraulic habitat variables are stored in the same folder and distinguished by their file naming pattern. Returns a rasterBrick of each habitat metric that contains the results for all modeled discharges.

find.hsc: Selects habitat suitability criteria from reach_hsc.csv for the current species.

find.sub: Selects substrate criteria from reach_substrate.csv for the current species.

bricks.rc: Reclassifies rasterBricks into suitable and unsuitable habitat based on habitat suitability criteria (HSC csv). Returns a Brick of suitable cells by discharge.

by.substrate: Takes a rasterized substrate type map of the same extent, resolution, and projection of DEM and reclassifies it into suitable or unsuitable substrate based on user supplied substrate criteria table. Uses the reclassified substrate map as a mask over the Brick of hydraulically suitable cells to extract cells that have suitable habitat. Returns a rasterBrick of suitable habitat.

remove.islands: Removes islands (small, isolated habitat areas) from suitable habitat area. The number of cells that constitutes an island can be specified.

total.area: Calculates total available and, optionally, reach-normalized habitat area by lifestage for the area-discharge reference tables.

rast.by.q: Puts rasters of total available habitat in order of ascending modeled Q for easy extraction.

interp.table: Adds total available and normalized area (if applicable) to the hydrograph table. It will linearly interpolate between discharges to fill in areas for any discharges not run in iRIC. This function is not capable of extrapolation.

interp.plot: Generates plots of total available and normalized area (if applicable) with the user supplied hydrograph.

avg.monthly.area: Calculates the minimum average monthly area using a central running 10-day mean. 

x.day.stats: Calculates moving X-day minimum, maximum, and mean discharges and total area for a hydrograph.

### Descriptions of Files
reach_hsc.csv: Contains the hydraulic habitat suitability criteria for all species and lifestages of fish residing in a reach.
reach_substrate.csv: Contains the substrate requirements for all species and lifestages of fish residing in a reach.
reach_hydrograph.csv: Provides the flow scenario for the reach using daily discharge values.

## Future Developments
1. Improve visualization of habitat.
2. Process more complex habitat suitability requirements.
3. Incorporate riparian vegetation.

