
# extend PATH to include podman binaries
# path must exist and be owned by root
if [[ -d "/opt/podman/bin" ]] && [[ "$(stat -f '%u' /opt/podman/bin 2>/dev/null)" == "0" ]]; then
  export PATH="${PATH}:/opt/podman/bin"
fi