# The function generates plots of total available and effective habitat area and discharge through the hydrograph
# Last updated by Elaina Passero on 4/8/19

interp.plot <- function(t,interTab){
  iT <- interTab[[t]]
  yrange <- 2*max(iT$totalArea)
  a <-plot_ly(iT) %>%
    add_trace(x=iT$date,y=iT$totalArea,type='bar',name="total area") %>%
    add_trace(x=iT$date,y=iT$discharge,type='scatter',mode='lines',name="discharge",yaxis="y2") %>%
    layout(title=paste("Total Available Habitat Area and Discharge: ",t,sep=""),
           xaxis=list(title="date"),
           yaxis=list(side='left',title='Total Available Area',range=c(0,yrange),showgrid=FALSE),
           yaxis2=list(side='right',overlaying="y",title='Discharge in CMS',showgrid=FALSE))
  if("effArea" %in% names(iT)){
  b <- plot_ly(iT) %>%
      add_trace(x=iT$date,y=iT$effArea,type='bar',name="effective area") %>%
      add_trace(x=iT$date,y=iT$discharge,type='scatter',mode='lines',name="discharge",yaxis="y2") %>%
      layout(title=paste("Effective Habitat Area and Discharge: ",t,sep=""),
             xaxis=list(title="date"),
             yaxis=list(side='left',title='Effective Area',range=c(0,yrange),showgrid=FALSE),
             yaxis2=list(side='right',overlaying="y",title='Discharge in CMS',showgrid=FALSE))
  }
  plotlist <- list(a,b)
  return(plotlist)
}