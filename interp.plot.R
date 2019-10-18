# The function generates plots of total available and effective habitat area and discharge through the hydrograph
# Last updated by Elaina Passero on 10/18/19

interp.plot <- function(a,inter_tab,NormalizeByL){
  i_t <- inter_tab[[a]]
  yrange <- 2*max(na.omit(i_t$total_area))
  pt <-plot_ly(i_t) %>%
    add_trace(x=i_t$date,y=i_t$total_area,type='bar',name="total area") %>%
    add_trace(x=i_t$date,y=i_t$discharge,type='scatter',mode='lines',name="discharge",yaxis="y2") %>%
    layout(title=paste("Total Available Habitat Area and Discharge: ",a,sep=""),
           xaxis=list(title="date"),
           yaxis=list(side='left',title='Total Available Area',range=c(0,yrange),showgrid=FALSE),
           yaxis2=list(side='right',overlaying="y",title='Discharge in CMS',showgrid=FALSE))
  if(NormalizeByL=="Yes"){
  pe <- plot_ly(i_t) %>%
      add_trace(x=i_t$date,y=i_t$normalized_area,type='bar',name="normalized area") %>%
      add_trace(x=i_t$date,y=i_t$discharge,type='scatter',mode='lines',name="discharge",yaxis="y2") %>%
      layout(title=paste("Normalized Habitat Area and Discharge: ",a,sep=""),
             xaxis=list(title="date"),
             yaxis=list(side='left',title='Normalized Area',range=c(0,yrange),showgrid=FALSE),
             yaxis2=list(side='right',overlaying="y",title='Discharge in CMS',showgrid=FALSE))
  plotlist <- list(pt,pe)
  }else{plotlist <- list(pt)}
  return(plotlist)
}