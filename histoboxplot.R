#' ---
#' title: "Histogram with boxplot and optional table of summary statistics"
#' author: "Julian Cabezas"
#' date: "Version 0.2, 27-11-2018"
#' ---

#Function designed for positive vectors, with several outliers that cant be seen in the histogram

library(ggplot2)
library(grid)
library(gridExtra)

histoboxplot<-function (x,binw=round((max(x)-min(x))/30,1),xmin=floor(min(x)-(abs(min(x)*0.05))),
xmax=ceiling(max(x)+(max(x)*0.05)),ylab="Absolute Frequency",xlab="Variable",
title="histoboxplot",sumtable=FALSE,language="english") {
# x = A vector
# lenguage can be "spanish or "english"

# Convert x to data.frame
df<-data.frame(x=x)

#Calculate frecuencies according to binwhith
df$freq<-cut(df$x,breaks=seq(xmin,xmax,binw))

#Calculate maximum frequency
ymax<-max(tapply(df$x,df$freq,length),na.rm=TRUE)

#More or less 30% of extra space for the boxplot
ymax<-ymax+ymax*0.3

# Histogram
hist_in<-ggplot(df, aes(x=x)) +
  geom_histogram(color="black",fill="lightblue",breaks=seq(xmin,xmax,binw),size=0.2) +
  ylab(ylab) +
  xlim(c(xmin,xmax)) +
  #xlim(c(-99,10)) +
  ylim(c(0,ymax)) +
  xlab(xlab) +
  ggtitle(title) +
  theme_gray(14)

# Boxplot
box_in<-ggplot(df,aes(x=factor(0),x))+
  geom_boxplot(outlier.size = 0.8,lwd=0.5,fill="lightblue")+
  coord_flip() +
  scale_y_continuous(limits=c(xmin, xmax), expand = c(0, 0)) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.margin=unit(c(0, 0, 0, 0), "null"),
        axis.text = element_blank(), axis.ticks.length = unit(0, "mm"),
        #panel.background = element_rect(fill = "red"), # bg of the panel
        #plot.background = element_rect(fill = "transparent", col = NA), # bg of the plot
        #panel.grid.major = element_blank(), # get rid of major grid
        #panel.grid.minor = element_blank(), # get rid of minor grid
        legend.background = element_rect(fill = "transparent"), # get rid of legend bg
        legend.box.background = element_rect(fill = "transparent"),
        panel.border = element_rect(colour = "black", fill=NA, size=0.5)
  ) +
  labs(x = NULL, y = NULL)

#Cobvert to grob object
box_grob <- ggplotGrob(box_in)

# Insert the boxplot in the histogram
hist_box<-hist_in + 
  annotation_custom(grob = box_grob, xmin = xmin, xmax = xmax, 
                    ymin = ymax*0.85, ymax = ymax)

# In case you want a summary table
if (sumtable) {

#Summary table
sum<-summary(df$x)

# Calculate CV
sum[7]<-(sd(df$x)/mean(df$x))*100

if (language=="spanish") {
sum.df<-data.frame(cbind(Estadístico=c("Mínimo","Mediana","Media","Máximo","CV (%)"),Valor=round(as.vector(sum),2)[c(1,3,4,6,7)]),row.names=NULL)
}

if (language=="english") {
  sum.df<-data.frame(cbind(Statistic =c("Minimum","Median","Mean","Maximum","CV (%)"),Value=round(as.vector(sum),2)[c(1,3,4,6,7)]),row.names=NULL)
}

if (!(language %in% c('spanish','english'))) {
  stop("languaje not supported, select spanish or english")
}

# Set theme for the table
tt1 <- tt1 <- gridExtra::ttheme_default(
  core = list(fg_params=list(cex = 1)),
  colhead = list(fg_params=list(cex = 1)),
  rowhead = list(fg_params=list(cex = 1)))

sum.grob<-tableGrob(sum.df, theme=tt1,rows = NULL)

# Insertar la dataframe en el histograma
histoboxplot_full<-hist_box + 
  annotation_custom(grob = sum.grob, xmin = xmax*0.6, xmax = xmax, 
                    ymin = ymax*0.4, ymax = ymax*0.6)

return(histoboxplot_full)

} else {
  return(hist_box)
}

}

# algo<-rnorm(10000)

# histoboxplot(algo,sumtable=FALSE)

# Ejemplo:
# histoboxplot(algo,ylab="Frecuencia absoluta",
#              xlab="Algo",
#              title="Distribución de la variable algo",
#              sumtable = TRUE, language = "spanish")
