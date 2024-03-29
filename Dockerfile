# Default base image 
ARG BASE_IMAGE=ubuntu:22.04


# --- START Build image ---
FROM $BASE_IMAGE

# Add LABELS
LABEL MAINTAINER="Alexandre DEVELY"
LABEL vcs-type "git"
LABEL vcs-url  "https://github.com/abcdesktopio/oc.cupsd"


# define env
ENV DEBCONF_FRONTEND noninteractive
ENV TERM linux
ENV NODE_MAJOR=20

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
#         smbclient
RUN apt-get update && apt-get install -y --no-install-recommends \
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

COPY composer /composer

# Add nodejs service
RUN cd /composer/node/common-libraries && npm install --omit=dev && \
    cd /composer/node/file-service && npm install --omit=dev && \
    cd /composer/node/printer-service && npm install --omit=dev

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Add 
RUN adduser root lpadmin 
ENV PRINTERQUEUE=/var/spool/cups-pdf/ANONYMOUS
RUN mkdir -p $PRINTERQUEUE && chown root:lp $PRINTERQUEUE 
RUN echo `date` > /etc/build.date

# LOG AND PID SECTION
RUN mkdir -p 	/var/log/desktop                            \
        	/var/run/desktop                            \
        	/composer/run
COPY etc /etc
RUN  chown -R lp:root /etc/cups/ppd /etc/cups/printers.conf

CMD /docker-entrypoint.sh

# DEFAULT FILE_SERVICE_TCP_PORT use 29782
# FILE_SERVICE_TCP_PORT 29782
# CUPSD PORT 631
# expose cupsd tcp port
EXPOSE 631 29782

