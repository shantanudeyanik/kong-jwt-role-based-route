FROM kong:3.7
USER root
RUN luarocks install kong-oidc-v3
COPY . .
RUN luarocks make
USER kong
