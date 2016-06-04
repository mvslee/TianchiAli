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




playdata <- na.omit(join[actiontype==1][,sum(actiontype),by=c('ds','artistid')]);
downloaddata <- na.omit(join[actiontype==2][,sum(actiontype)/2,by=c('ds','artistid')]);
collectdata <- na.omit(join[actiontype==3][,sum(actiontype)/3,by=c('ds','artistid')]);



playresult <- playdata[playdata$ds>=20150701&playdata$ds<=20150830];
d <- setdiff(data.table(test_predict$ds,test_predict$artistid),data.table(playresult$ds,playresult$artistid));
d <- cbind(d,1:1);
setnames(d,c('ds','artistid','V1'));
playresult <- rbind(playresult,d);
rm(d);

actual_result <- data.table(artistid=0,ds=0,V1=0);
for (i in 1:50){
  b <- playresult[artistid==artistinfo[i]][order(playresult[artistid==artistinfo[i]]$ds),];
  actual_result <- rbind(b,actual_result);
}
actual_result <- data.table(artistid=actual_result$artistid,play=actual_result$V1,ds=actual_result$ds);
actual_result <- actual_result[-3051,];

#############Extract 25% number as qa#############
playtest <- playdata[playdata$ds>=20150501&playdata$ds<=20150631];
qa <- rep(NA,50);
for(i in 1:50){
  qa[i] <- quantile(playtest[artistid==artistinfo[i]]$V1)[2];
}
qa <- cbind(artistinfo,qa);
#setnames(qa('artistid','1st Qu'));
#qa <- data.table(qa);
#############
test_predict <- data.table(artistid=0,ds=0,play=0);
for(i in 1:50){
  a <- data.table(artistid=rep(artistinfo[i],61),play=rep(0,61),ds=c(20150701:20150731,20150801:20150830));
  test_predict <- rbind(a,test_predict);
 }

test_predict <- test_predict[-3051,];

for (i in 1:3050){
  p <- qa[V1==test_predict[i]$artistid]$qa;
  test_predict[i]$play <- round(rnorm(1, mean=p, sd = round(p/20)));
}
test_predict$artistid <- vapply(test_predict$artistid, paste, collapse = ", ", character(1L));

#userplay: play sum of 50 artists
#userdownload: download sum of 50 artists
#usercollect: collect sum of 50 artists
#artist_init: initial play amount of artists
#playdata: initial play and play sum during Mar-Aug
############Result Compare#########


##########Weight Formula#############
#Score by Tianchi Rules
delta2 <- rep(NA, 50);
wg <- rep(NA,50);
for (i in 1:50) {
  delta2[i] <- sum(((test_predict$play[(1:61)+(i-1)*rep(61,61)]-actual_result$play[(1:61)+(i-1)*rep(61,61)])/actual_result$play[(1:61)+(i-1)*rep(61,61)])^2)/61;
  wg[i] <- sqrt(sum(actual_result$play[(1:61)+(i-1)*rep(61,61)]));
}
score <- sum((rep(1,50)-delta2)*wg);
