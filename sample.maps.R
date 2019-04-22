# Generate sample maps of habitat area by discharge and lifestage
# Last edited by Elaina Passero on 4/9/19

# can't add basemaps right now unfortunately

lapply(polyTab$adult$totalArea,function(a) sample.maps(a))
a <- 3
b <- polyTab$adult$totalArea[[a]]
extents <- b@bbox
xmi <- extents[1,1]*.99999
xma <- extents[1,2]*1.00001
ymi <- extents[2,1]*.99999
yma <- extents[2,2]*1.00001

### Individual Plotting
spplot(b,colorkey=FALSE,main="Total Available Habitat Area: adult",sub="Q = 1.6 cms",xlim=c(xmi,xma),ylim=c(ymi,yma))
