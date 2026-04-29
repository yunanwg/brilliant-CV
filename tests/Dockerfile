# Test environment for brilliant-cv. The CI workflow and the
# `just test` / `just test-update` recipes both run inside this image so
# the maintainer's macOS and CI Linux see identical pixel output —
# tytanic ref PNGs are a Linux baseline, not platform-dependent.
#
# Build:  docker build -t brilliant-cv-test -f tests/Dockerfile .
# Run:    docker run --rm -v "$(pwd)":/workspace brilliant-cv-test <cmd>
# (the just recipes wrap this for you)

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Make typst + tytanic find system fonts without needing the
# --use-system-fonts CLI flag on every invocation. Both tools honor
# TYPST_FONT_PATHS (colon-separated dirs).
ENV TYPST_FONT_PATHS=/usr/share/fonts:/usr/local/share/fonts

# System tools + Roboto + Noto CJK (substitutes for Heiti SC in zh tests
# — see tests/README.md for the rationale: Heiti SC isn't redistributable,
# so the Linux baseline uses Noto CJK SC and the test fixture overrides
# the font selection.)
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
        xz-utils \
        fontconfig \
        fonts-roboto \
        fonts-noto-cjk \
        bash \
        just \
    && rm -rf /var/lib/apt/lists/*

# typst 0.14.2 (>= the 0.14.0 manifest min). Download then extract in
# separate steps — piping curl -> tar -xJ flakes under QEMU x86_64
# emulation (SIGPIPE on tar's child).
RUN curl -fsSL -o /tmp/typst.tar.xz \
        https://github.com/typst/typst/releases/download/v0.14.2/typst-x86_64-unknown-linux-musl.tar.xz \
    && tar -xJf /tmp/typst.tar.xz -C /tmp \
    && mv /tmp/typst-x86_64-unknown-linux-musl/typst /usr/local/bin/typst \
    && rm -rf /tmp/typst.tar.xz /tmp/typst-x86_64-unknown-linux-musl

# tytanic 0.3.3 (matches what the test harness expects)
RUN curl -fsSL -o /tmp/tytanic.tar.xz \
        https://github.com/typst-community/tytanic/releases/download/v0.3.3/tytanic-x86_64-unknown-linux-musl.tar.xz \
    && tar -xJf /tmp/tytanic.tar.xz -C /tmp \
    && mv /tmp/tytanic-x86_64-unknown-linux-musl/tt /usr/local/bin/tt \
    && rm -rf /tmp/tytanic.tar.xz /tmp/tytanic-x86_64-unknown-linux-musl

# typstyle 0.14.4 (single binary, no archive)
RUN curl -fsSL -o /usr/local/bin/typstyle \
        https://github.com/typstyle-rs/typstyle/releases/download/v0.14.4/typstyle-x86_64-unknown-linux-gnu \
    && chmod +x /usr/local/bin/typstyle

# Source Sans 3 (Adobe upstream — not in apt)
RUN mkdir -p /usr/local/share/fonts/SourceSans3 \
    && curl -fsSL --retry 3 -o /tmp/ss3.zip \
        https://github.com/adobe-fonts/source-sans/releases/download/3.052R/OTF-source-sans-3.052R.zip \
    && unzip -q /tmp/ss3.zip -d /usr/local/share/fonts/SourceSans3 \
    && rm /tmp/ss3.zip

# Font Awesome 7.2.0 desktop (matches @preview/fontawesome:0.6.0 expected
# family names — apt's fonts-font-awesome is FA 6 with different names)
RUN curl -fsSL --retry 3 -o /tmp/fa.zip \
        https://github.com/FortAwesome/Font-Awesome/releases/download/7.2.0/fontawesome-free-7.2.0-desktop.zip \
    && unzip -q /tmp/fa.zip -d /tmp/fa \
    && find /tmp/fa -name '*.otf' -exec cp {} /usr/local/share/fonts/ \; \
    && rm -rf /tmp/fa.zip /tmp/fa \
    && fc-cache -f

COPY tests/docker-entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["bash"]
