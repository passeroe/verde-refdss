# verde-refdss
## Project Overview
The Verde River Wild and Scenic River Riverine Environmental Flow Decision Support System (REFDSS) will be used in determining the environmental flow needs of fish and riparian vegetation in the Verde River in Arizona by synthesizing multiple model outputs into a user-friendly R Shiny App. The DSS will take hydrualic modeling outputs, habitat suitability requirements, and substrate information to generate suitable habitat for species of interest.

## Getting Started
### Required Inputs
1. Digital elevation model (DEM) of modeled reach with known coordinate reference system.
2. CSV of habitat suitability criteria (HSC) by lifestage. Currently, HSC may only be numeric. See fakefish_hsc.csv for the required format of HSC tables.
3. CSV of iRIC FaSTMECH calculation results. Results should follow a naming convention of Result_XXXX.XX where X's correspond to the discharge value used in the FaSTMECH calculation. The approximate calculation grid cell size should match that of the DEM.

### Optional Inputs
1. CSV of suitable substrate types per lifestage. See fakefish_substrate.csv for an example. Currently, the function by.substrate.R creates a fake substrate map layer to use for the Sample Reach when a CSV is provided and CheckSub <- 1. A separate function will be written to handle the substrate maps once more information is known about their format.
2. CSV containing effective area relationships. See fakefish_effrel.csv for an example. The function effective.area.R, which calculates effective area when CalcEffArea <- 1, is currently under development and is not yet ready to run.

### General Process
Currently, the script rasterizes the FaSTMECH results based on the DEM using bilinear interpolation. The rasters are reclassified into suitable and unsuitable habitat using the provided habitat suitability criteria.

### Descriptions of Functions
1. Fish_hab_master: Serves as the master script that handles user inputs and calls functions. Runs through functions using habitat metrics or lifestages. 
2. get.results: Pulls in iRIC output results as CSVs and fixes headers containing special characters. Returns a list of CSVs and a list of the modeled discharges.
3. iric.process.smr: Rasterizes the results in list of CSVs using attributes of user supplied DEM. Returns a rasterBrick of each habitat metric that contains the results for all modeled discharges.
4. bricks.rc: Reclassifies rasterBricks into suitable and unsuitable habitat based on habitat suitability criteria (HSC csv). Returns a Brick of suitable cells by discharge.
5. by.substrate: *Optional*. Creates dummy substrate raster layer (this feature will be removed/replaced once substrate maps are available). Takes a rasterized substrate type map of the same extent, resolution, and projection of DEM and reclassifies it into suitable or unsuitable substrate based on user supplied substrate criteria table. Uses the reclassified substrate map as a mask over the Brick of hydraulically suitable cells to extract cells that have suitable habitat. Returns a rasterBrick of suitable habitat.
6. brick.2.spdf: Converts rasterBricks to Spatial Polygon Data Frames (SPDFs). Calculates areas of each habitat polygon and removes polygons that are too small (<0.25 m2). Returns a list of SPDFs for each lifestage where each SPDF corresponds to a modeled discharge.
7. effective.area: *Optional*. Uses effective area relationships table to calculate the effective area for each lifestage in the table. Returns a list of lifestages containing lists of SPDFs of effective area by discharge.
8. build.tables.eff: *Optional*. Constructs habitat area lookup tables for total available and effective areas.
9. save.polys.eff: *Optional* Returns a data frame of habitat area lookup table and data frame of polygons of suitable areas.
10. build.tables.tot: *If not calculating effective area.* Constructs habitat area lookup tables for total available area only. 
11. save.polys.tot: *If not calculating effective area.* Returns a data frame of habitat area lookup table and data frame of polygons of suitable areas.

## Example
The following example finds effective and total available suitable habitat area using multiple lifestages, habitat metrics, and calculation discharges.

### Inputs
``` # Set Inputs
wd <- "C:/Users/username/Desktop/VRDSS/verde-refdss/" # Set path to local repository
habMets <- list("Depth","Velocity..magnitude.") #Variables from iRIC calculation result used for habitat analysis
species <- "fakefish"
lifestages <- list("adult","juvenile") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "Sample" 
DEM <- "smrf_DEM_v241.tif" # Name of DEM used in iRIC
disunit <- "cms" #units of discharge

# Options: Currently this is only set up to run with the Sample reach
CheckSub <- 1 # 1 (Yes) or 0 (No). Choose whether or not to check substrate conditions as part of suitable habitat
CalcEffArea <- 1 # 1 (Yes) or 0 (No). Choose whether or not to calculate effective habitat area
```
The names of habMets can be found in csvList. These names are reformatted in get.results.R to remove spaces and special characters.

### Outputs
areaLookTab should contain two items (one for each lifestage) with a data frame of total available and effective area by discharge. Results can be plotted by lifestage and discharge using ```lapply(polyTab$adults[[2]], spplot)``` for adults effective area (or use [[1]] for total available and ```lapply(polyTab$juvenile[[2]], spplot)``` for juveniles effective area.

## Future Developments
1. Visualize habitat area through a hydrograph.
2. Calculate area for discharges that were not run in FaSTMECH via interpolation.


