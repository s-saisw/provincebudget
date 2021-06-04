library(tidyverse)

yr <- 63

setwd("C:\\Users\\81804\\Desktop\\Data\\provinceBudget")

base <- "http://www.bb.go.th/web/budget/province/province_bud"
baselink <- paste0(base, yr, "/")
page <- readLines(baselink,
                  encoding = "UTF-8") 

# download link ---------------
linkline <- grep('<td><a href="PDF/plan/bis61rchang2001_',page)
link <- gsub("[[:blank:]]", "", 
             sub('\" target=\"_blank\">ดาวน์โหลด</a></td>',"",
                 sub('<td><a href=\"', "", page[linkline])))

# province ---------------------

# get province order
provline <- linkline - 3
prov <- gsub("[[:blank:]]", "",
             sub('</td>', "", sub('<td>',"",page[provline])))
province <- sub("จังหวัด","",prov)%>%
  as.data.frame()
colnames(province) <- c("province")

# import province code
provmatch <- read_excel("C:/Users/81804/Desktop/Data/basicData/Province_match.xlsx", 
                             sheet = "Sheet2", col_names = FALSE)
colnames(provmatch) <- c("province", "code")

# merge province name with code
provcode <- left_join(province,provmatch, 
            by = "province")
provcode[which(is.na(provcode$code)),2] <- "00"

if (length(link) == length(provcode$code)) {
  for (i in 1:length(link)) {
    filelink <- paste0(baselink,link[i])
    filename <- paste0("/budget",provcode$code, ".pdf")[i]
    dest <- paste0(getwd(),"/budget",yr, filename)
    download.file(filelink, destfile = dest, 
                  mode="wb") #prevent blank file
  }
} else {
  msg <- paste0("unequal length of link and name for year", yr)
  print(msg)
}


    
    