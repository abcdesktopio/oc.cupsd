FROM node:20
ARG ABCDESKTOP_LOCALACCOUNT_DIR=/etc/localaccount
ENV ABCDESKTOP_LOCALACCOUNT_DIR=$ABCDESKTOP_LOCALACCOUNT_DIR
# default branch
ARG BRANCH=4.0
ENV BRANCH=$BRANCH

# copy file-service repo to /composer/node
RUN mkdir -p /composer/node/file-service && \
    git clone -b $BRANCH https://github.com/abcdesktopio/file-service.git /composer/node/file-service
# copy printer-service repo to /composer/node
RUN mkdir -p /composer/node/printer-service && \
    git clone -b $BRANCH https://github.com/abcdesktopio/printer-service.git /composer/node/printer-service

# Add nodejs file-service and dep
WORKDIR /composer/node/file-service
RUN npm install --save-prod

# Add nodejs printer-service and dep
WORKDIR /composer/node/printer-service
RUN npm install --save-prod

# install fonts 
RUN apt-get update && apt-get install -y --no-install-recommends \
	fonts-recommended		\
	xfonts-base			\
        xfonts-encodings                \
        xfonts-utils                    \
	xfonts-100dpi			\
	xfonts-75dpi			\
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
        && apt-get clean		\
	&& rm -rf /var/lib/apt/lists/*

# cups-pdf:  pdf printer support
# smbclient: need to install smb printer
# cups:      printer support
RUN apt-get update && apt-get install -y --no-install-recommends \
	supervisor      \
        smbclient	\
	cups-pdf 	\
        cups		\
        && apt-get clean\
	&& rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Add root to lpadmin
RUN adduser root lpadmin 
RUN echo `date` > /etc/build.date

# LOG AND PID SECTION
RUN mkdir -p 	/var/log/desktop                            \
        	/var/run/desktop                            \
        	/composer/run
COPY etc /etc
RUN  chown -R lp:root /etc/cups/ppd /etc/cups/printers.conf

# cupsd need to run as root
USER root
WORKDIR /
CMD /docker-entrypoint.sh
# DEFAULT FILE_SERVICE_TCP_PORT has changed for printer
# FILE_SERVICE_TCP_PORT 	29782
# expose cupsd tcp port		631
EXPOSE 631 29782
