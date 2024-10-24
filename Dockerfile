FROM node:18.19.1-bullseye AS builder

ENV TZ="Europe/Moscow"
ENV BUILD_DIR="/devel"
ENV GIT_DIR="server"
ENV GIT_BRANCH="master"


#sudo apt install nodejs npm -y
RUN sh -c 'echo "Acquire::http {No-Cache=True;};" >> /etc/apt/apt.conf'
RUN apt update && apt upgrade -y
RUN apt install ca-certificates tzdata build-essential git -y && \
    npm install -g pkg 


WORKDIR ${BUILD_DIR}

RUN git clone https://github.com/spacebarchat/server.git ${GIT_DIR}

RUN cd ${GIT_DIR}; npm i; npx patch-package ; npm run setup 

# linuxstatic
RUN cd server; pkg -t node18-alpine-x64  --debug dist/bundle/start.js -o bundle_node18_x64_alpine


##############################################

FROM alpine:3.18.4

ENV TZ="Europe/Moscow"
ENV SPACEBAR_DIR="/app"
ENV DATABASE=postgres://postgres:QmV4m88Xd7ds97pTwF79@192.168.88.57:5432/spacebar;

RUN apk --no-cache update && apk --no-cache upgrade && \
    apk add --no-cache ca-certificates tzdata git
RUN apk add nodejs=18.20.1-r0 npm

# RUN npm install -g npm@10.9.0 && npm install sqlite3 --save


RUN echo ${TZ} > /etc/timezone && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime


ARG USER=spacebar
ARG UID=1001
ARG GID=1001

RUN adduser --uid ${UID} --shell /bin/sh --home ${SPACEBAR_DIR}/${USER} --disabled-password ${USER}

COPY --chown=${USER} --from=builder /devel/server/ \
                    ${SPACEBAR_DIR}/${USER}/
                    
USER $USER
WORKDIR ${SPACEBAR_DIR}/${USER}

EXPOSE 3001

# Start the bundle server ( API, CDN, Gateway in one )
CMD ["./bundle_node18_x64_alpine"]
