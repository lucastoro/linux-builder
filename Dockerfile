FROM gcc:latest

RUN apt update
RUN apt install -y flex bison bc libelf-dev
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
