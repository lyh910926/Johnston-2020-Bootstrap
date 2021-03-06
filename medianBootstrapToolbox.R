####
#
# MG Johnston
# 16/12/2020
# Faulkner Lab
# Crop Genetics, John Innes Centre
#
####

####
#
# medianBootstrap(data1, data2)
## Recommended method for comparing two sets of bombardment data
## Returns p-value and confidence limits (default 95%) of the p-value for difference in medians
#
# medianBootstrap_plot(data1, data2)
## Returns null-distrubution graph for difference in medians
#
# medianBootstraps(data1, data2, data3, ..., dataN)
## Recommended method to replace a one-way ANOVA of bombardment data
## Returns a list of p-values of comparisons to data1 (usually the control) for difference in medians
#
# meanBootstrap(data1, data2)
## Returns p-value and confidence limits (default 95%) of the p-value for difference in means
#
# meanBootstraps(data1, data2, data3, ..., dataN)
## Returns a list of p-values of comparisons to data1 (usually the control) for difference in means
#
# All functions have optional parameters N and alpha
## N is the number of bootstraps (default 5000)
## alpha is the significance level (and the Type I error rate) used for constructing confidence intervals (default 0.05)
#
####

mcp_ci <- function(success, trials, alpha){
  ## Copyright (C) 2001 Frank E Harrell Jr
  ## Modified by Matthew G Johnston 2020 from binconf in the Hmisc package
  ## Distributed under GNU General Public License v2 (or later) without any warranty. See the GNU General Public License for more details.
  zcrit <-  - qnorm(alpha/2)
  z2 <- zcrit * zcrit
  mc_p <- success/trials
  cl <- (mc_p + z2/2/trials + c(-1, 1) * zcrit *
           sqrt((mc_p * (1 - mc_p) + z2/4/trials)/trials))/(1 + z2/trials)
  if(success == 1)
    cl[1] <-  - log(1 - alpha)/trials
  if(success == (trials - 1))
    cl[2] <- 1 + log(1 - alpha)/trials
  return(cbind(mc_p, lower_ci=cl[1], upper_ci=cl[2]))
}

medianBootstrap<- function(data1, data2, N=5000, alpha=0.05){
  ## Calculate observed test statistic
  mediandiff<-median(data1)-median(data2)
  ## Generate the null distribution
  boots<-replicate(N, median(sample(data1,length(data1), replace=T))-median(sample(data2,length(data2),  replace=T))-mediandiff)
  ## Count the number of at resampled observations which are at least as extreme
  above <- sum(abs(boots)>=abs(mediandiff))
  ## Calculate p value and confidence intervals
  mcp<-mcp_ci(above+1,N+1, alpha)
  return(mcp)
}

medianBootstrapPlot<- function(data1, data2, N=5000, alpha=0.05){
  require(ggplot2)
  ## Calculate observed test statistic
  mediandiff<-median(data1)-median(data2)
  ## Generate the null distribution
  boots<-replicate(N, median(sample(data1,length(data1), replace=T))-median(sample(data2,length(data2),  replace=T))-mediandiff)
  ## Count the number of at resampled observations which are at least as extreme
  above <- sum(abs(boots)>=abs(mediandiff))
  ## Calculate p value and confidence intervals
  mcp<-format(round(mcp_ci(above+1,N+1, alpha),3),nsmall=3)
  ## Plot graph
  labeltext1<- substitute(atop(paste(hat(italic("p")))~phantom()==phantom()~AAA,"95% CI"~BBB~CCC), list(AAA=mcp[1], BBB =paste0("[",mcp[2],", "), CCC= paste0(mcp[3],"]")))
  plot<-ggplot(data.frame(median=boots), aes(x=abs(median)))+
    geom_histogram(alpha=.7, binwidth = 1, aes(y=..density..))+
    geom_vline(xintercept = abs(mediandiff), linetype=2, colour = "red4")+
    theme_bw()+
    xlab(expression(atop("|"~hat(paste(theta, "*"))~-~hat(theta)~"|",theta==Delta[median])))+
    ylab("Density")+
    annotate("text",x = Inf, y = Inf, hjust = 1.1, vjust = 1.1,label=labeltext1)+
    theme(text=element_text(size=15))
  return(plot)
}

medianBootstraps<- function(..., N=5000, alpha=0.05){
  results<-NULL
  x<-list(...)
  reference<-x[[1]]
  for(i in 2:(length(x))){
    ## Calculate observed test statistic
    mediandiff<-median(reference)-median(x[[i]])
    ## Generate the null distribution
    boots<-replicate(N, median(sample(reference,length(reference), replace=T))-median(sample(x[[i]],length(x[[i]]), replace=T))-mediandiff)
    ## Count the number of at resampled observations which are at least as extreme
    above <- sum(abs(boots)>=abs(mediandiff))
    ## Calculate p value and confidence intervals
    mcp<-mcp_ci(above+1,N+1, alpha)
    results<-rbind(results, mcp)
  }
  ## Calculate observed test statistics
  return(cbind(pvaladj=p.adjust(results[,1]),pvaladj_lower=p.adjust(results[,2]),pvaladj_upper=p.adjust(results[,3])))
}

meanBootstrap<- function(data1, data2, N=5000, alpha=0.05){
  ## Calculate observed test statistic
  meandiff<-mean(data1)-mean(data2)
  ## Generate the null distribution
  boots<-replicate(N, mean(sample(data1,length(data1), replace=T))-mean(sample(data2,length(data2),  replace=T))-meandiff)
  ## Count the number of at resampled observations which are at least as extreme
  above <- sum(abs(boots)>=abs(meandiff))
  ## Calculate p value and confidence intervals
  mcp<-mcp_ci(above+1,N+1, alpha)
  return(mcp)
}

meanBootstraps<- function(..., N=5000, alpha=0.05){
  results<-NULL
  x<-list(...)
  reference<-x[[1]]
  for(i in 2:(length(x))){
    ## Calculate observed test statistic
    mediandiff<-mean(reference)-mean(x[[i]])
    ## Generate the null distribution
    boots<-replicate(N, mean(sample(reference,length(reference), replace=T))-mean(sample(x[[i]],length(x[[i]]), replace=T))-mediandiff)
    ## Count the number of at resampled observations which are at least as extreme
    above <- sum(abs(boots)>=abs(mediandiff))
    ## Calculate p value and confidence intervals
    mcp<-mcp_ci(above+1,N+1, alpha)
    results<-rbind(results, mcp)
  }
  ## Calculate observed test statistics
  return(cbind(pvaladj=p.adjust(results[,1]),pvaladj_lower=p.adjust(results[,2]),pvaladj_upper=p.adjust(results[,3])))
}