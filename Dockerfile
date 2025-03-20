FROM eclipse-temurin:17-jre

WORKDIR /opt/halo

ENV TZ=Asia/Shanghai
ENV JVM_OPTS="-Xmx256m -Xms256m"

RUN apt-get update && \
    apt-get install -y wget python3 python3-venv python3-pip tar gzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=cloudflare/cloudflared:latest /usr/local/bin/cloudflared /usr/local/bin/cloudflared
RUN chmod +x /usr/local/bin/cloudflared

RUN wget https://dl.halo.run/release/halo-2.20.16.jar -O halo.jar

RUN mkdir -p ~/.halo2

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --no-cache-dir huggingface_hub

COPY sync_data.sh /opt/halo/
RUN chmod +x /opt/halo/sync_data.sh

EXPOSE 8090

CMD cloudflared tunnel --no-autoupdate run --token $CF_TOKEN & \
    /opt/halo/sync_data.sh
