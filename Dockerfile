# IMAGE BUILD
FROM ilyasbit/debianbase:latest

EXPOSE 8555 8444

ENV CHIA_ROOT=/root/.chia/mainnet
ENV keys="generate"
ENV service="harvester"
ENV plots_dir="/plots"
ENV farmer_address=127.0.0.1
ENV farmer_port=8444
ENV testnet="false"
ENV TZ="UTC"
ENV upnp="true"
ENV log_to_file="true"
ENV healthcheck="false"

# Deprecated legacy options
#ENV harvester="false"
#ENV farmer="false"

# Minimal list of software dependencies
#   sudo: Needed for alternative plotter install
#   tzdata: Setting the timezone
#   curl: Health-checks
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y sudo tzdata curl && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

RUN wget https://download.chia.net/latest/x86_64-Ubuntu-cli -O /chia_installer  && \
    dpkg -i /chia_installer

COPY docker-start.sh /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-healthcheck.sh /usr/local/bin/

HEALTHCHECK --interval=1m --timeout=10s --start-period=20m \
  CMD /bin/bash /usr/local/bin/docker-healthcheck.sh || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-start.sh"]
