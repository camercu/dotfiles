
# extend PATH to include podman binaries
# path must exist and be owned by root
[[ -d "/opt/podman/bin/" && -n $(find /opt/podman/bin -prune -user 0) ]] && \
  export PATH="${PATH}:/opt/podman/bin/"
