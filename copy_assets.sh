#!/bin/bash
# Copy generated images into Xcode asset catalog

ASSETS_SRC="Assets"
ASSETS_DST="NazoNazo/NazoNazo/Assets.xcassets"

# App icon
cp "$ASSETS_SRC/Icons/app_icon.png" "$ASSETS_DST/AppIcon.appiconset/app_icon.png"

# Characters
cp "$ASSETS_SRC/Characters/easy_character.png" "$ASSETS_DST/easy_character.imageset/easy_character.png"
cp "$ASSETS_SRC/Characters/medium_character.png" "$ASSETS_DST/medium_character.imageset/medium_character.png"
cp "$ASSETS_SRC/Characters/hard_character.png" "$ASSETS_DST/hard_character.imageset/hard_character.png"

# UI
cp "$ASSETS_SRC/UI/splash_background.png" "$ASSETS_DST/splash_background.imageset/splash_background.png"
cp "$ASSETS_SRC/UI/background_quiz.png" "$ASSETS_DST/background_quiz.imageset/background_quiz.png"

echo "Assets copied successfully!"
