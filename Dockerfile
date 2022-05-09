FROM plugfox/flutter:stable

USER root

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=$CARGO_HOME/bin:$PATH \
    RUST_VERSION=stable

RUN set -eux; \
    apk add --no-cache make git ca-certificates gcc ;\
    dart --disable-analytics ;\
    flutter --suppress-analytics config --no-analytics ;\
    flutter --suppress-analytics precache --no-ios --no-linux --no-windows --no-winuwp --no-macos --no-fuchsia --universal --web ;\
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        x86_64) rustArch='x86_64-unknown-linux-musl'; rustupSha256='bdf022eb7cba403d0285bb62cbc47211f610caec24589a72af70e1e900663be9' ;; \
        aarch64) rustArch='aarch64-unknown-linux-musl'; rustupSha256='89ce657fe41e83186f5a6cdca4e0fd40edab4fd41b0f9161ac6241d49fbdbbbe' ;; \
        *) echo >&2 "unsupported architecture: $apkArch"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.24.3/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    find /usr/local/rustup/ -type f -executable -exec strip --strip-unneeded {} \; && find /usr/local/rustup/ -name *.so -exec strip --strip-unneeded {} \; && find /usr/local/rustup/ -name *.rlib -exec strip -d {} \; && find /usr/local/rustup/ -name *.a -exec strip -d {} \;

COPY config.toml /usr/local/cargo/

WORKDIR /
CMD [ "/bin/bash" ]
