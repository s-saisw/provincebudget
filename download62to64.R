library(tidyverse)
library(readxl)

setwd("C:\\Users\\81804\\Desktop\\Data\\provinceBudget\\provincebudget-github")

# import province code --------
provmatch <- read_excel("C:/Users/81804/Desktop/Data/basicData/Province_match.xlsx", 
                        sheet = "Sheet2", col_names = FALSE)
colnames(provmatch) <- c("province", "code")


# download pdfs ---------------

base <- "http://www.bb.go.th/web/budget/province/province_bud"

yrvec <- 62:64

for (yr in yrvec) {
  
  # create directory to store files -----
  newdir <- paste0(getwd(),"/budget",yr)
  if (dir.exists(newdir)) {
    print("skip create dir")
  } else {
    dir.create(newdir)
  }
  
  # set key for each year -----------
  
  if (yr == 60) {
    key <- '<td><a target="_blank" href="pages/PDF-item/'
  } else if (yr == 61) {
    key <- '<td><a href="pages/PDF-item/'
  } else if (yr == 62|yr==63|yr == 64) {
    key <- '<td><a href="PDF/plan/bis61rchang2001_'
  }

  # get download link ---------------
  
  baselink <- paste0(base, yr, "/")
  page <- readLines(baselink,
                    encoding = "UTF-8")
  
  linkline <- grep(key, page)
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
  
  print(paste("finished year", yr))
}

# key for 60: <td><a target="_blank" href="pages/PDF-item/
# key for 61: <td><a href="pages/PDF-item/





    
    