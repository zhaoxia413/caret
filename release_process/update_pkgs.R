options(repos = "http://cran.r-project.org")
library(tools)

fresh <- TRUE ## starting from a fresh, bare version of R

###################################################################
## Get Bioconductor packages
## try http:// if https:// URLs are not supported

install.packages(c("BiocManager"), repos = "http://cran.r-project.org", type = "binary")

library(BiocManager)
#useDevel()

if (Sys.info()["sysname"] == "Linux") {
  BiocManager::install(c("vbmp", "gpls", "logicFS", "graph", "RBGL"),
                       dependencies = c("Depends", "Imports"),
                       update = FALSE, ask = FALSE)
} else {
  BiocManager::install(c("vbmp", "gpls", "logicFS", "graph", "RBGL"),
           type = "both",
           dependencies = c("Depends", "Imports"),
           update = FALSE, ask = FALSE)
}


###################################################################
## Get the names of all CRAN related packages references by caret.
## Exclude orphaned and Bioconductor packages for now

# install.packages(c("devtools"), repos = "http://cran.r-project.org", type = "source")
#
# library(devtools)
# install_github("topepo/caret", subdir = "pkg/caret")

library(caret)

mods <- getModelInfo()

libs <- unlist(lapply(mods, function(x) x$library))
libs <- unique(sort(libs))
libs <- libs[!(libs %in% c("caret", "vbmp", "gpls", "logicFS", "SDDA"))]
libs <- c(libs, "knitr", "Hmisc", "googleVis", "animation",
          "desirability", "networkD3", "heatmaply", "arm", "xtable",
          "RColorBrewer", "gplots", "iplots", "latticeExtra",
          "scatterplot3d", "vcd", "igraph", "corrplot", "ctv",
          "Cairo", "shiny", "scales", "tabplot", "tikzDevice", "odfWeave",
          "multicore", "doMC", "doMPI", "doSMP", "doBy",
          "foreach", "doParallel", "aod", "car", "contrast", "Design",
          "faraway",  "geepack",  "gmodels", "lme4", "tidyr", "devtools", "testthat",
          "multcomp", "multtest", "pda", "qvalue", "ChemometricsWithR", "markdown",
          "rmarkdown", "pscl",
          ## odds and ends
          "ape", "gdata", "boot", "bootstrap", "chron", "combinat", "concord", "cluster",
          "desirability", "gsubfn", "gtools", "impute", "Matrix", "proxy", "plyr",
          "reshape", "rJava", "SparseM", "sqldf", "XML", "lubridate", "GA",
          "aroma.affymetrix", "remMap", "cghFLasso", "RCurl", "QSARdata", "reshape2",
          "mapproj", "ggmap", "ggvis", "SuperLearner", "subsemble", "caretEnsemble",
          "ROSE", "DMwR", "ellipse", "bookdown", "DT", "AppliedPredictiveModeling",
          "pROC", "ggthemes", "sessioninfo", "mlbench", "tidyverse")
libs <- c(libs, package_dependencies("caret", reverse = TRUE)$caret)
libs <- unique(libs)


###################################################################
## Check to see if any packages are not on CRAN

options(repos = "http://cran.r-project.org")
all_pkg <- rownames(available.packages(type = "source"))

diffs <- libs[!(libs %in% all_pkg)]
if (length(diffs) > 0) print(diffs)

###################################################################
## Install the files. This might re-install caret so beware.

# devtools::install_github('dmlc/xgboost',subdir='R-package')

libs <- sort(libs)
n <- length(libs)

for (i in seq_along(libs)) {
  if (fresh)
    good <- rownames(installed.packages())
  if (fresh) {
    cat(
      "----------------------------------------------------------------\n",
      libs[i], " (", i, " of ", n,
      ")\n\n", sep = ""
    )

    res <- try(
      BiocManager::install(
        libs[i],
        type = "both",
        dependencies = c("Depends", "Imports"),
        update = FALSE,
        ask = FALSE
      ),
      silent = TRUE
    )

    print(res)
    cat("\n\n")
  }
}

warnings()

###################################################################
## Install orphaned packages: CHAID, rknn, SDDA
