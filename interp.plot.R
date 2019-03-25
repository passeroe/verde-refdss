# The function generates plots of habitat area and discharge through the hydrograph
# Last updated by Elaina Passero on 3/25/19

interp.plot <- function(t,inter.Tab){
  plot_ly(hydrograph) %>%
    add_trace(x=hydrograph$date,y=hydrograph$totalArea,type='bar',name="total area") %>%
    add_trace(x=hydrograph$date,y=hydrograph$discharge,type='scatter',mode='lines',name="discharge",yaxis="y2") %>%
    layout(title=paste("Total Available Habitat Area and Discharge: ",t,sep=""),
           xaxis=list(title="date"),
           yaxis=list(side='left',title='Total Area Area'),
           yaxis2=list(side='right',overlaying="y",title='Discharge in CMS'))
}