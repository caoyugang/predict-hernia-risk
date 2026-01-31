options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))

required_pkgs <- c("shiny", "randomForest", "dplyr", "ggplot2", "caret", "readr")

for (pkg in required_pkgs) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg