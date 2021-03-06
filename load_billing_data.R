package<-c('dplyr','ggplot2','tidyr','stringr',
           'xlsx','magrittr','data.table','tidyverse','xlsx','lubridate')
lapply(package,require,character.only=T)


#load data
file<-list.files(path='E:/thesis_data')
filename<-list.files(path='E:/thesis_data',pattern='^bill_\\d{4}')
filepath<-paste0('E:/thesis_data/',filename)

bill<-list()
for (i in 1:12){
  bill[[i]]<-fread(filepath[i],stringsAsFactors = F)%>%
    select(nam,diag,dt_serv,code_act,cl_prof,sp_prof)
}

names(bill)<-filename[1:12]




########################################################################################################
#filter code_act for AS surgical interventions to look at case numbers: (Comparing with hospitalization data for verification)
AS_bill_code<-c(4547,4548,4542,4543,4546,4544)
bill_savr<-lapply(bill,function(x)x[x$code_act %in% AS_bill_code,])

bill_savr<-do.call(rbind,bill_savr)
length(unique(bill_savr$nam))
#12792 unique individuals

lapply(bill_savr,function(x)sum(is.na(x))) #no missing values

#link bill to index_age in demo (filtered by age) dataset by nam:
bill_savr<-left_join(bill_savr,demo[,c('nam','dt_index','age','sexe')])%>%
      filter(!is.na(dt_index))%>%
      mutate(dt_serv=as.Date(dt_serv,origin='1960-01-01'))%>%
      distinct() #remove duplicated rows


#link icd code in bill2 to ICD table:
bill_icd<-unique(c(ICD$Description.CIM10.CA..Français[ICD$CIM9.Stand %in% unique(bill2$diag)],
                ICD$Description.CIM10.CA..Français[ICD$CIM.10.CA %in% unique(bill2$diag)]))
                

#plot surgical intervention cases by year:
#ggplot(data=bill%>%group_by(year(dt_index))%>%summarise(count=n_distinct(nam)),aes(x=`year(dt_index)`,y=count))+
#   geom_bar(stat='identity')

