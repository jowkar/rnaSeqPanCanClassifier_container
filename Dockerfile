FROM ubuntu:20.04

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Update, install necessary utilities, and clean up in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common dirmngr apt-transport-https ca-certificates gnupg \
    libcurl4-openssl-dev libssl-dev libxml2-dev git build-essential \
    curl libharfbuzz-dev libfreetype6-dev libfontconfig1-dev libzmq3-dev libfribidi-dev \
    libpng-dev libtiff5-dev libjpeg-dev && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs && \
    git lfs install && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    r-base=4.3.1-3.2004.0 \
    r-base-dev=4.3.1-3.2004.0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "options(repos = c(CRAN = 'https://cloud.r-project.org/')); \
    install.packages(c('Rtsne', 'data.table', 'stringr', 'ggplot2', 'ggrepel', 'RColorBrewer', 'caret', 'BiocManager', 'pkgdown', 'devtools')); \
    BiocManager::install('Biobase')"

# Clone repository and install
RUN git clone https://github.com/jowkar/rnaSeqPanCanClassifier && \
    cd rnaSeqPanCanClassifier && \
    git checkout 17e6cdd && \
    git lfs pull && \
    R -e "devtools::install('.')"

# Append library load to Rprofile.site
RUN echo "library(rnaSeqPanCanClassifier)" >> /usr/lib/R/etc/Rprofile.site

# Set the default command to R prompt
CMD ["R"]
