#!/bin/bash

# Install Flutter
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

# Upgrade and config
flutter doctor
flutter config --enable-web

# Build Web
echo "Building Flutter Web..."
flutter build web --release --dart-define=GROQ_API_KEY=$GROQ_API_KEY

echo "Build complete!"
