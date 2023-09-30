# defaul TAG is dev
ARG TAG=dev
# Default base image 
ARG BASE_IMAGE=ubuntu:22.04

# --- BEGIN node_modules_builder ---
FROM $BASE_IMAGE as node_modules_builder

ENV NODE_MAJOR=18

#Install curl
RUN apt-get update && apt-get install -y --no-install-recommends \
	software-properties-common \
	gnupg \
	gpg-agent               \
        curl  \
    && apt-get clean                    \
    && rm -rf /var/lib/apt/lists/*

# install yarn npm nodejs 
RUN  mkdir -p /etc/apt/keyrings && \
     curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
     echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
     apt-get update && \
     apt-get install -y --no-install-recommends nodejs && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*

RUN npm -g install yarn

COPY composer /composer

# Add nodejs service
RUN cd /composer/node/common-libraries && npm install --omit=dev && \
    cd /composer/node/file-service && npm install --omit=dev && \
    cd /composer/node/printer-service && npm install --omit=dev


# --- START Build image ---
FROM $BASE_IMAGE

# Add LABELS
LABEL MAINTAINER="Alexandre DEVELY"
LABEL vcs-type "git"
LABEL vcs-url  "https://github.com/abcdesktopio/oc.cupsd"


# define env
ENV DEBCONF_FRONTEND noninteractive
ENV TERM linux
ENV NODE_MAJOR=18

## 
# install fonts 
RUN apt-get update && apt-get install -y --no-install-recommends \
	xfonts-base			\
        xfonts-encodings                \
        xfonts-utils                    \
	xfonts-100dpi			\
	xfonts-75dpi			\
	xfonts-cyrillic			\
        ubuntustudio-fonts              \
   	libfontconfig 			\
    	libfreetype6 			\
        fonts-freefont-ttf		\
  	fonts-croscore                  \
        fonts-dejavu-core               \
        fonts-horai-umefont             \
        fonts-noto                      \
        fonts-opendyslexic              \
        fonts-roboto                    \
        fonts-roboto-hinted             \
        fonts-sil-mondulkiri            \
        fonts-unfonts-core              \
        fonts-wqy-microhei              \
	fonts-ipafont-gothic            \
        fonts-wqy-zenhei                \
        fonts-tlwg-loma-otf             \
	gsfonts-x11			\
        && apt-get clean		\
	&& rm -rf /var/lib/apt/lists/*



# cups-pdf:  pdf printer support
# smbclient: need to install smb printer
# cups:      printer support
RUN apt-get update && apt-get install -y --no-install-recommends \
        smbclient	\
	cups-pdf 	\
        cups		\
        && apt-get clean\
	&& rm -rf /var/lib/apt/lists/*

# apt install iproute2 install ip command
# install supervisor
RUN apt-get update && apt-get install -y  --no-install-recommends      \
	supervisor		\
	curl			\
	gpg-agent		\
        software-properties-common \
	gnupg			\
        && apt-get clean	\
	&& rm -rf /var/lib/apt/lists/*	

# this package nodejs include npm 
# install nodejs 
RUN  mkdir -p /etc/apt/keyrings && \
     curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
     echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
     apt-get update && \
     apt-get install -y --no-install-recommends nodejs && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*

COPY --from=node_modules_builder /composer  /composer

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Add 
RUN adduser root lpadmin 

# Next command use $BUSER context
ENV BUSER balloon
# RUN adduser --disabled-password --gecos '' $BUSER
# RUN id -u $BUSER &>/dev/null || 
RUN groupadd --gid 4096 $BUSER
RUN useradd --create-home --shell /bin/bash --uid 4096 -g $BUSER --groups lpadmin $BUSER
# create an ubuntu user
# PASS=`pwgen -c -n -1 10`
# PASS=ballon
# Change password for user balloon
RUN echo "balloon:lmdpocpetit" | chpasswd $BUSER
#

RUN echo `date` > /etc/build.date

# LOG AND PID SECTION
RUN mkdir -p 	/var/log/desktop                            \
        	/var/run/desktop                            \
        	/composer/run
COPY etc /etc
RUN  chown -R lp:root /etc/cups/ppd /etc/cups/printers.conf
USER root

CMD /docker-entrypoint.sh

# DEFAULT FILE_SERVICE_TCP_PORT use 29782
# FILE_SERVICE_TCP_PORT 29782
# CUPSD PORT 631

# expose cupsd tcp port
EXPOSE 631 29782

