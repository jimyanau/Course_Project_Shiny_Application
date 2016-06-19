library(dplyr)


#function to summarize Mean, Sigma, LSL, Target, USL by groups
GroupBy = function(df, ...) {

  newdf <- (df %>% group_by(...) %>% summarise(Mean=mean(value), Stdev = sd(value), 
                                               LSL = (first(Nominal)-abs(min(Minus_Tol))), 
                                               Target = first(Nominal), 
                                               USL = (first(Nominal)+max(Plus_Tol)),
                                               Cp =  (USL-LSL)/(6*Stdev),
                                               Cpl = (Mean-LSL)/(3*Stdev),
                                               Cpu = (USL-Mean)/(3*Stdev),
                                               Cpk = min(Cpl,Cpu)
  )
  )
  
  #set Cpu/Cpl to one sided variables
  newdf$Cpk[which(newdf$Target==newdf$LSL)] <- newdf$Cpu[which(newdf$Target==newdf$LSL)]
  newdf$Cpk[which(newdf$Target==newdf$USL)] <- newdf$Cpl[which(newdf$Target==newdf$USL)]
  
  #round numerics variable up
  is.num <- sapply(newdf, is.numeric)
  newdf[is.num] <- lapply(newdf[is.num], round, 3)
  
  #set capability status based on Cpk value
  newdf$Capability <- ifelse(newdf$Cpk >=1.33, "Capable", "Not-Capable")
  newdf$Capability <- as.factor(newdf$Capability)
  
  return(newdf)
}
