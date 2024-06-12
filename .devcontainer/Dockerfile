FROM ubuntu:latest 

RUN apt update && apt install -y curl
RUN apt install -y git
RUN apt install build-essential libreadline-dev unzip -y --no-install-recommends
RUN apt install -y p7zip
RUN curl -R -O https://lua.org/ftp/lua-5.4.6.tar.gz
RUN tar -zxf lua-5.4.6.tar.gz
RUN cd lua-5.4.6 && make linux test && make install
RUN curl -R -O https://luarocks.github.io/luarocks/releases/luarocks-3.11.1.tar.gz
RUN tar -zxf luarocks-3.11.1.tar.gz
RUN cd luarocks-3.11.1 && ./configure --with-lua-include=/usr/local/include && make && make install
RUN luarocks install busted