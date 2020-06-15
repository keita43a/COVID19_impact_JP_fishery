# draft of downloading the data from public websites

# Author: Keita Abe
# created: June 11, 2020


# library

pacman::p_load(tidyverse,
               lubridate,
               readxl)

# data 
# use 水産物流通調査 to get landing market data monthly
# http://www.market.jafic.or.jp/

file_DL = FALSE # TRUE if you need to download file

# download the file
if(file_DL){
for(yr in 2019:2020){ # the data avaialable from 2010
  for(m in 1:12){
    # convert digits to padded char. (e.g. 4 -> 04)
    mon = str_pad(m,width = 2,pad = 0)
    # file name same as the original file
    file_name = paste0("01_tukibetu_",yr,"_",mon,".xls")
    # set URL
    url <- paste0("http://www.market.jafic.or.jp/file/sanchi/",yr,"/",file_name)
    # download the file (excel)
    download.file(url, file_name)
  }
}
}

# read file

for(yr in 2010:2020){ # the data avaialable from 2010
  for(m in 1:12){
    if(yr == 2020 & m == 5) break
    # convert digits to padded char. (e.g. 4 -> 04)
    mon = str_pad(m,width = 2,pad = 0)
    # file name same as the original file
    file_name = paste0("01_tukibetu_",yr,"_",mon,".xls")
    
    # monthly landing data (aggregated) by major species
    dat_mon = read_excel(file_name, sheet = 1)
    # extract latest month landing (assuming the rows are same across files)
    mon_land = dat_mon %>%
      slice(19) %>% # landing for the latest month
      ##mutate(across(everything(), ~str_replace(.,"-","0"))) %>%
      mutate(across(4:38,as.numeric)) %>%
      mutate(across(1:3,as.character)) %>%
      mutate(year = yr,
             month = m,
             type = "landing_t")
    # extract latest month price
    mon_pr= dat_mon %>%
      slice(40) %>% # price for the past 12 month
      ##mutate(across(everything(), ~str_replace(.,"-","0"))) %>% # if -, which is exactly zero. 
      mutate(across(4:38,as.numeric)) %>%
      mutate(across(1:3,as.character)) %>%
      mutate(year = yr,
             month = m,
             type = "price_kg")
  
    # dataset: if 2010 Jan, initiate the data. bind rows otherwise
    if(yr == 2010 & m == 1){
      dat1 = mon_land %>%
        bind_rows(mon_pr)
    }else{
      dat1 = bind_rows(dat1,mon_land) %>%
        bind_rows(mon_pr)
    } # end if
  } # end for m
} # end for yr

dat2 <- dat1 %>%
  dplyr::select(-c(1:3)) %>%
  mutate(date = ceiling_date(as.Date(paste(year,month,15,sep = "-")), "month") - days(1)) %>%
  relocate(year,month,date,type) %>% # bring these new date info to the front
  pivot_longer(
    cols = -c(year,month,date,type),
    names_to = "species",
    values_to = "value") %>%
  pivot_wider(names_from = type,
              values_from = value) %>%
  # compare the change
  arrange(species, date) %>%
  group_by(species) %>%
  mutate(across(c(landing_t,price_kg), ~.x/lag(.x,1), .names = "{col}_rel_prev_mon")) %>%
  ungroup() %>%
  arrange(species, month,year) %>%
  group_by(species,month) %>%
  mutate(across(c(landing_t,price_kg), ~.x/lag(.x,1), .names = "{col}_rel_year_mon")) %>%
  ungroup() %>%
  arrange(date, species)

# save data

write_csv(dat2, "monthly_landing_market_aggregate_201001_202004.csv")


# ====== data by landing port =======
# the same excel file, but the second sheet contains the data by major landing port.
# monthly landing data (aggregated) by major species


for(yr in 2010:2020){
  for(m in 1:12){
    
  if(yr == 2020 & m >= 5) break
    
  
  # file name same as the original file
    mon = str_pad(m,width = 2,pad = 0)
    file_name = paste0("01_tukibetu_",yr,"_",mon,".xls")
 
  dat_temp = read_excel(file_name, sheet = 2)

  # clean and extract header 
  dat_header = dat_temp %>%
    slice(2:3) %>%
    t() %>%
    as_tibble() %>%
    fill(V1,.direction = "down") %>%
    mutate(header = paste(V1,V2,sep ="_")) %>%
    mutate(header = str_replace(header, "（","("),
           header = str_replace(header, "）",")")) %>%
    slice(-1) %>%
    dplyr::select(header) %>%
    t()
  
  dat_header[1] = "漁港"
  dat_header[2] = "漁港code"

  
  # extract the main data and set header
  dat_main = dat_temp %>%
    filter(!is.na(`...2`)) %>%
    dplyr::select(-1) %>%
    set_names(dat_header) %>%
    pivot_longer(cols = -c(漁港,漁港code), 
                 names_to = c("species",".value"),
                 names_pattern = "(.*)_(.*)") %>%
    mutate(year = yr,
           month = m)
    
  
  # bind rows data
  if(yr == 2010 & m == 1){
    dat_port = dat_main
  }else{
    dat_port = bind_rows(dat_port,dat_main)
  }

  } # end for m
} # end for yr

dat_port2 = dat_port %>%
  rename("port" = "漁港",
         "port_code" = "漁港code",
         "landing_t" = "水揚量",
         "price_kg" = "価格") %>%
  mutate(date = ceiling_date(as.Date(paste(year,month,15,sep = "-")), "month") - days(1)) %>%
  relocate(year,month,date) %>%
  mutate(across(c(landing_t,price_kg),as.numeric)) %>%
  # fix names of port based on code
  mutate(port = ifelse(port_code == 23, "勝浦(千葉)", 
                       ifelse(port_code == 31, "勝浦(和歌山)",port))) %>%
  filter(!is.na(port))
  

write_csv(dat_port2, "monthly_landing_market_by_port_201001_202004.csv")
  
