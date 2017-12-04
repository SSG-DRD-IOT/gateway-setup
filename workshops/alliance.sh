
if [ "$platform" == "$CORE_PLATFORM" ]; then
  source platforms/NUC5i7RYB.sh
elif [[ "$platform" == "$UP2_PLATFORM" ]]; then
  source platforms/up2.sh
fi
