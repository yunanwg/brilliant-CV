# Test environment for brilliant-cv. The CI workflow and the
# `just test` / `just test-update` recipes both run inside this image so
# the maintainer's Apple Silicon Mac and CI Linux use the same toolchain.
# Persistent refs also use fonts verified stable across both ARM hosts.
#
# Architecture: arm64 only. Running x86_64 binaries via Rosetta/QEMU
# translation produces FreeType-rasterized pixels that drift from
# native x86_64 (empirically: ~5912 deviating pixels in Roboto-rendered
# headers, see commit history for the migration). Sticking to a single
# native arch (arm64) removes the larger cross-architecture drift. Some
# fonts (notably Roboto Bold) still vary between ARM CPU implementations,
# so persistent refs use Source Sans 3; see tests/README.md.
#
# Build:  docker build -t brilliant-cv-test -f tests/Dockerfile .
# Run:    docker run --rm -v "$(pwd)":/workspace brilliant-cv-test <cmd>
# (the just recipes wrap this for you)

FROM ubuntu:24.04@sha256:4fbb8e6a8395de5a7550b33509421a2bafbc0aab6c06ba2cef9ebffbc7092d90

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
        fontconfig=2.15.0-1.1ubuntu2 \
        fonts-roboto=2:0~20170802-3 \
        fonts-roboto-unhinted=2:0~20170802-3 \
        fonts-noto-cjk=1:20230817+repack1-3 \
        bash \
        just \
    && rm -rf /var/lib/apt/lists/*

# typst 0.15.1 (>= the 0.14.0 manifest min). Download then extract in
# separate steps — keeping the two-step form for robustness against
# transient network/io flakes during the build.
RUN curl -fsSL -o /tmp/typst.tar.xz \
        https://github.com/typst/typst/releases/download/v0.15.1/typst-aarch64-unknown-linux-musl.tar.xz \
    && echo "5aa8d74a3d906e60ea12a66ac2f37f8eef1b14cbad7182a745e393a10c23dcee  /tmp/typst.tar.xz" | sha256sum -c - \
    && tar -xJf /tmp/typst.tar.xz -C /tmp \
    && mv /tmp/typst-aarch64-unknown-linux-musl/typst /usr/local/bin/typst \
    && rm -rf /tmp/typst.tar.xz /tmp/typst-aarch64-unknown-linux-musl

# tytanic 0.4.1 embeds Typst 0.15.1, keeping the standalone compiler and
# the visual-reference renderer on the same Typst release.
RUN curl -fsSL -o /tmp/tytanic.tar.xz \
        https://github.com/typst-community/tytanic/releases/download/v0.4.1/tytanic-aarch64-unknown-linux-musl.tar.xz \
    && echo "5d3ccd7b58fe0d60717df50ce429fc39dc8be0abfc166817bdce1b2b7722190e  /tmp/tytanic.tar.xz" | sha256sum -c - \
    && tar -xJf /tmp/tytanic.tar.xz -C /tmp \
    && mv /tmp/tytanic-aarch64-unknown-linux-musl/tt /usr/local/bin/tt \
    && rm -rf /tmp/tytanic.tar.xz /tmp/tytanic-aarch64-unknown-linux-musl

# typstyle 0.15.0 (single binary, no archive; built against Typst 0.15)
RUN curl -fsSL -o /usr/local/bin/typstyle \
        https://github.com/typstyle-rs/typstyle/releases/download/v0.15.0/typstyle-aarch64-unknown-linux-gnu \
    && echo "d782f1fa1704c537542edf131bddb9b6467af72944a50b174709f904a198f3b7  /usr/local/bin/typstyle" | sha256sum -c - \
    && chmod +x /usr/local/bin/typstyle

# Source Sans 3 (Adobe upstream — not in apt)
RUN mkdir -p /usr/local/share/fonts/SourceSans3 \
    && curl -fsSL --retry 3 -o /tmp/ss3.zip \
        https://github.com/adobe-fonts/source-sans/releases/download/3.052R/OTF-source-sans-3.052R.zip \
    && echo "a4ebbdea20b08ccbd7bf3665a9462454eefdd01d9a6307129d3b3d4672981074  /tmp/ss3.zip" | sha256sum -c - \
    && unzip -q /tmp/ss3.zip -d /usr/local/share/fonts/SourceSans3 \
    && rm /tmp/ss3.zip

# Font Awesome 7.2.0 desktop (matches @preview/fontawesome:0.6.0 expected
# family names — apt's fonts-font-awesome is FA 6 with different names)
RUN curl -fsSL --retry 3 -o /tmp/fa.zip \
        https://github.com/FortAwesome/Font-Awesome/releases/download/7.2.0/fontawesome-free-7.2.0-desktop.zip \
    && echo "5717251cdd7b3f3df989f9fada0ca65b6609045c04a0c1bd78fb27acb3bf84cb  /tmp/fa.zip" | sha256sum -c - \
    && unzip -q /tmp/fa.zip -d /tmp/fa \
    && find /tmp/fa -name '*.otf' -exec cp {} /usr/local/share/fonts/ \; \
    && rm -rf /tmp/fa.zip /tmp/fa \
    && fc-cache -f

COPY tests/docker-entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["bash"]
