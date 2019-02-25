# verde-refdss
## Project Overview
The Verde River Wild and Scenic River Riverine Environmental Flow Decision Support System (REFDSS) will be used in determining the environmental flow needs of fish and riparian vegetation in the Verde River in Arizona by synthesizing multiple model outputs into a user-friendly R Shiny App. The DSS will take hydrualic modeling outputs, habitat suitability requirements, and substrate information to generate suitable habitat for species of interest.

## Getting Started
### Required Inputs
1. Digital elevation model (DEM) of modeled reach with known coordinate reference system.
2. CSV of habitat suitability criteria (HSC) by lifestage. Currently, HSC may only be numeric. See example for the required format of HSC tables.
3. CSV of iRIC FaSTMECH calculation results. Results should follow a naming convention of Result_XXXX.XX where X's correspond to the discharge value used in the FaSTMECH calculation. The approximate calculation grid cell size should match that of the DEM.

### General Process
Currently, the script rasterizes the FaSTMECH results based on the DEM using bilinear interpolation. The rasters are reclassified into suitable and unsuitable habitat using the provided habitat suitability criteria. A flowchart of the process is available in the main repository folder.

### Current Outputs
List of rasterBricks of hydraulically suitable habitat. Each lifestage has a rasterBrick in the list that contains the suitable habitat by discharge.  

## Example
The following example finds suitable habitat using multiple lifestages, habitat metrics, and calculation discharges.

### Inputs
``` # Set Inputs
wd <- "C:\\Users\\username\\Desktop\\VRDSS\\verde-refdss\\" # Set path to local repository
habMets <- list("Depth","Velocity..magnitude.") #Variables from iRIC calculation result used for habitat analysis
species <- "fakefish"
lifestages <- list("adult","juvenile") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "Sample" 
DEM <- "smrf_DEM_v241.tif" # Name of DEM used in iRIC
```
The names of habMets can be found in csvList. These names are reformatted in get.results.R to remove spaces and special characters.

### Outputs
hydHabList should contain two rasterBricks (one for each lifestage) of hydraulically suitable habitats by discharge. Results can be plotted by lifestage using ```plot(hydHabList[[1]])``` for adults and ```plot(hydHabList[[2]])``` for juveniles.

## Future Developments
1. Option to include substrate type in habitat suitability criteria.
2. Calculate suitable area by discharge for each lifestage.
