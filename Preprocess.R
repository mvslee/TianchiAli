#########Upadate Info#############
#20160601 submit first edition, get 5042 points;
#20160602 Create test edition;
#20160602 Change training dataset from 20160701 to 20150830
#20160604 Edit test rules by fixing bug about selecting artist in time-line data;
#20160604 Change random valve to 20 instead of 5 rnorm(1, mean=p, sd = round(p/20)








#########Import data and raw process

library(RPostgreSQL);
library(data.table);
library(dplyr);
drv <- dbDriver("PostgreSQL");
pgdb <- dbConnect(drv, user = 'postgres', password = '1234',dbname = 'tianchidb', host = '127.0.0.1');
artist <- dbReadTable(pgdb,'t_artist');
users <- dbReadTable(pgdb,'t_user');
users <- data.table(users);
artist <- data.table(artist);
##############################
setkey(artist,songid);
setkey(users,songid);
users$actiontype <- as.numeric(users$actiontype);
users$ds <- as.numeric(users$ds);
#######join is a list that combines artist and users, using songid as key
join <- artist[users];
artistinfo<- na.omit(data.table(unique(join$artistid)));
ds <- data.table(sort(unique(join$ds)));
rm(users);
rm(artist);


#userplay <- na.omit(join[actiontype=='1'][,sum(as.numeric(actiontype)/as.numeric(actiontype)),by=artistid]);
#userdownload <- na.omit(join[actiontype=='2'][,sum(as.numeric(actiontype)/as.numeric(actiontype)),by=artistid]);
#usercollect <- na.omit(join[actiontype=='3'][,sum(as.numeric(actiontype)/as.numeric(actiontype)),by=artistid]);
#setnames(userplay,c('V1'),c('userplay'));
#setnames(userdownload,c('V1'),c('userdownload'));
#setnames(usercollect,c('V1'),c('usercollect'));
#artist_init <- artist[,sum(as.numeric(initplay)),by=artistid];
#setnames(artist_init,c('artistid','V1'),c('artistid','initplay'));
#setkey(artist_init,artistid);
#setkey(userplay,artistid);
#playdata <- na.omit(artist_init[userplay]);
# playdata <- join[actiontype==1][,sum(actiontype),by=.(artistid,ds)];
# setnames(playdata,'V1','play');
# downloaddata <- tapply(join[actiontype==2]$actiontype, list(join[actiontype==2]$ds,join[actiontype==2]$artistid), sum);
# downloaddata <- cbind(row.names(downloaddata),downloaddata);
# row.names(downloaddata) <- NULL;
# downloaddata <- data.table(downloaddata);
# setnames(downloaddata,'V1','ds');
# collectdata <- tapply(join[actiontype==3]$actiontype, list(join[actiontype==3]$ds,join[actiontype==3]$artistid), sum);
# collectdata <- cbind(row.names(collectdata),collectdata);
# row.names(collectdata) <- NULL;
# collectdata <- data.table(collectdata);
# setnames(collectdata,'V1','ds');

playdata <- na.omit(join[actiontype==1][,sum(actiontype),by=c('ds','artistid')]);
downloaddata <- na.omit(join[actiontype==2][,sum(actiontype)/2,by=c('ds','artistid')]);
collectdata <- na.omit(join[actiontype==3][,sum(actiontype)/3,by=c('ds','artistid')]);
#############Extract 25% number as qa#############
playtest <- playdata[ds>=20150701&ds<=20150830];
qa <- rep(NA,50);
for(i in 1:50){
  qa[i] <- quantile(playtest[artistid==artistinfo[i]]$V1)[2];
}
qa <- cbind(artistinfo,qa);
#setnames(qa('artistid','1st Qu'));
#qa <- data.table(qa);
#############
mars_tianchi_artist_plays_predict <- data.table(artistid=0,ds=0,play=0);
for(i in 1:50){
  a <- data.table(artistid=rep(artistinfo[i],60),play=rep(0,60),ds=c(20150901:20150930,20151001:20151030));
  mars_tianchi_artist_plays_predict <- rbind(a,mars_tianchi_artist_plays_predict);
 }

mars_tianchi_artist_plays_predict <- mars_tianchi_artist_plays_predict[-3001,];

for (i in 1:3000){
  p <- qa[V1==mars_tianchi_artist_plays_predict[i]$artistid]$qa;
  mars_tianchi_artist_plays_predict[i]$play <- round(rnorm(1, mean=p, sd = round(p/20)));
}
mars_tianchi_artist_plays_predict$artistid <- vapply(mars_tianchi_artist_plays_predict$artistid, paste, collapse = ", ", character(1L));
write.table(mars_tianchi_artist_plays_predict,file = 'mars_tianchi_artist_plays_predict.csv',sep = ',',row.names = FALSE, col.names = FALSE, fileEncoding = 'UTF-8',append = FALSE,quote = FALSE,eol = '\r\n');

#userplay: play sum of 50 artists
#userdownload: download sum of 50 artists
#usercollect: collect sum of 50 artists
#artist_init: initial play amount of artists
#playdata: initial play and play sum during Mar-Aug
############
#sum(((rep(mean(a1play$play),length(a1play$play))-a1play$play)/a1play$play)^2)/length(a1play$play);

