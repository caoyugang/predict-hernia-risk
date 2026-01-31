# 极简版 install.R（适配Binder，仅装核心包，无冗余）
options(repos = c(
  CRAN = "https://cloud.r-project.org/",  # Binder兼容的全球镜像
  rlang = "https://cran.r-project.org/src/contrib/Archive/rlang/"
))

# 仅安装代码真正用到的核心包（去掉caret，避免大礼包下载失败）
core_pkgs <- c("shiny", "randomForest", "dplyr", "ggplot2", "readr")
install.packages(core_pkgs, dependencies = TRUE, quiet = TRUE)

# 安装兼容的rlang版本（避免ffi_list2错误，改用CRAN仓库直接安装）
install.packages("rlang", version = "0.4.12", repos = "https://cran.r-project.org/src/contrib/Archive/rlang/")