FROM innovanon/bare as installer
USER root
COPY ./stage-0 /tmp/stage-0
RUN sleep 91                \
 && ( cd       /tmp/stage-0 \
 &&   tar  pcf - . )          \
  | tar  pxf - -C /           \
 && rm -rf     /tmp/stage-0 \
 && chmod -v 1777 /tmp      \
 \
 && test -x       /tmp/dpkg.list  \
 && apt      update               \
 && apt full-upgrade              \
 && apt install $(/tmp/dpkg.list) \
 && rm -v         /tmp/dpkg.list

FROM installer as builder
USER root
COPY ./stage-1 /tmp/stage-1
RUN ( cd       /tmp/stage-1 \
 &&   tar  pcf - . )          \
  | tar  pxf - -C /           \
 && rm -rf     /tmp/stage-1 \
 && chown -v -R lfs:lfs     \
      /home/lfs/.gnupg      \
 && chmod -v -R 0600        \
      /home/lfs/.gnupg      \
 && chmod -v    0700        \
      /home/lfs/.gnupg

FROM builder as test-ecc
USER root
COPY ./ecc     /tmp/ecc
RUN ( cd       /tmp/ecc \
 &&   tar  pcf - . )      \
  | tar  pxf - -C /       \
 && rm -rf     /tmp/ecc
USER lfs
RUN sleep 31 \
 && MODE=ed25519-cert    /app/genkey.sh \
 && MODE=ed25519-sign    /app/addkey.sh \
 && MODE=cv25519-encrypt /app/addkey.sh \
 && MODE=ed25519-auth    /app/addkey.sh \
 && exec true

FROM builder as test-rsa
USER root
COPY ./rsa     /tmp/rsa
RUN ( cd       /tmp/rsa \
 &&   tar  pcf - . )      \
  | tar  pxf - -C /       \
 && rm -rf     /tmp/rsa
USER lfs
RUN sleep 31 \
 && MODE=rsa-cert    /app/genkey.sh \
 && MODE=rsa-sign    /app/addkey.sh \
 && MODE=rsa-encrypt /app/addkey.sh \
 && MODE=rsa-auth    /app/addkey.sh \
 && exec true

FROM builder as final
USER root
COPY ./ecc     /tmp/ecc
COPY ./rsa     /tmp/rsa
RUN ( cd       /tmp/ecc \
 &&   tar  pcf - . )      \
  | tar  pxf - -C /       \
 && ( cd       /tmp/rsa \
 &&   tar  pcf - . )      \
  | tar  pxf - -C /       \
 && rm -rf     /tmp/ecc \
               /tmp/rsa
USER lfs
ARG CA=ed25519
ARG SA=ed25519
ARG EA=cv25519
ARG AA=ed25519
ENV CA $CA
ENV SA $SA
ENV EA $EA
ENV AA $AA
VOLUME       /etc/gnupg/
VOLUME /home/lfs/.gnupg/
#ENTRYPOINT ["/usr/bin/env", "bash", "-l", "-c", "/app/entrypoint.sh"]
ENTRYPOINT ["/app/entrypoint.sh"]
CMD        ["cert", "sign", "encrypt", "auth"]

#FROM final as squash-tmp
#USER root
#RUN  squash.sh
#FROM scratch as squash
#ADD --from=squash-tmp /tmp/final.tar /

FROM final

