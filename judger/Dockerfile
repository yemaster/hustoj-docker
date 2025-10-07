FROM debian:bookworm-slim AS builder
WORKDIR /opt

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

RUN apt update && apt install -y \
    build-essential \
    make \
    flex \
    g++ \
    clang \
    mariadb-client \
    libmariadb-dev \
    libmariadb-dev-compat \
    libmysql++-dev \
    mono-devel \
    default-libmysqlclient-dev \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY ./src /opt/src
RUN sed -i 's/sprintf(docker_v,"%s:\/home\/judge",oj_home);/sprintf(docker_v,"%s:\/home\/judge",getenv("JUDGER_DATA_PATH"));/' src/judged/judged.cc
RUN sed -i 's/sprintf(docker_v,"%s:\/home\/judge",getenv("JUDGER_DATA_PATH"));/sprintf(docker_v,"%s:\/home\/judge",getenv("JUDGER_DATA_PATH")); char docker_network[BUFFER_SIZE]; sprintf(docker_network,"--net=%s",getenv("JUDGER_NETWORK")); /' src/judged/judged.cc
RUN sed -i 's/"hustoj"/"yemaster\/hustoj-judger"/g' src/judged/judged.cc
RUN sed -i 's/"--net=host"/docker_network/g' src/judged/judged.cc
RUN cd src/judged && make
RUN cd src/judge_client && make

FROM debian:bookworm-slim

WORKDIR /opt

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

RUN apt update && apt install -y \
    libmariadb-dev \
    libmariadb-dev-compat \
    libmysql++-dev \
    build-essential \
    python3 \
    dos2unix \
    g++ \
    clang \
    fp-compiler \
    # openjdk-17-jdk \
    procps \
    similarity-tester \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1536 judge

COPY --from=builder /opt/src/judged/judged.cc /usr/bin/judged.cc
COPY --from=builder /opt/src/judged/judged /usr/bin/judged
COPY --from=builder /opt/src/judge_client/judge_client /usr/bin/judge_client
COPY --from=builder /opt/src/sim/sim.sh /usr/bin/sim.sh
RUN chmod +x /usr/bin/judged
RUN chmod +x /usr/bin/judge_client
RUN chmod +x /usr/bin/sim.sh

RUN mkdir /app
RUN mkdir /opt/judger
RUN mkdir /opt/judger/etc /opt/judger/log /opt/judger/run0 /opt/judger/run1 /opt/judger/run2 /opt/judger/run3
COPY ./etc /opt/judger/etc/

RUN cp /usr/bin/sim_c++ /usr/bin/sim_cc

# override endl not to flush the io buffer
RUN echo "#ifndef HUSTOJ">>`find /usr/include/c++/ -name iostream`
RUN echo "#define HUSTOJ">>`find /usr/include/c++/ -name iostream`
RUN echo "std::ostream& endl(std::ostream& s) {">>`find /usr/include/c++/ -name iostream`
RUN echo "s<<'\\\\n'; ">>`find /usr/include/c++/ -name iostream`
RUN echo "return s; ">>`find /usr/include/c++/ -name iostream`
RUN echo "}">>`find /usr/include/c++/ -name iostream`
RUN echo "#endif">>`find /usr/include/c++/ -name iostream`

COPY ./service/docker-entrypoint.sh /etc/init.sh
RUN chmod +x /etc/init.sh

CMD ["/etc/init.sh"]