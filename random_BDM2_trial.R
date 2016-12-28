subjid<-commandArgs(TRUE);

path<-"Output/"
#bdm<-read.table(paste(path,subjid,"_BDM1.txt",sep=""),header=T)
bdm<-read.table(paste(path,subjid,"_BDM2.txt",sep=""),header=T)
#bdm<-rbind(bdm,bdm2)
trial<-round(runif(1,min=0,max=length(bdm$Bid)))
n <- c(0,.25,.5,.75,1,1.25,1.5,1.75,2,2.25,2.5,2.75,3)
n <- sample(n)  
if (bdm$Bid[trial]<=n[1]){
  write(paste("Random number ",n[1], " higher than bid $", round(bdm$Bid[trial],2), ". You do not receive item ",bdm$StimName[trial], "."),paste("Output/",subjid,"_BDM2_resolve.txt",sep=""),sep=" ");
}
if (bdm$Bid[trial]>n[1]){
  write(paste("You may buy item",bdm$StimName[trial], "for price $", n[1], ", you bid", round(bdm$Bid[trial],2),"." ),paste("Output/",subjid,"_BDM2_resolve.txt",sep=""),sep=" ");
}
