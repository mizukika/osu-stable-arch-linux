#!/usr/bin/env bash
set -e

WINE="$HOME/wine-osu/bin/wine"
PREFIX="$HOME/.wineosu"
OSU="$HOME/osu/osu!.exe"
HANDLER="$HOME/.local/bin/osu-open"
APPDIR="$HOME/.local/share/applications"

echo
echo "=========================================="
echo "          osu! handler installer"
echo "=========================================="
echo
echo "Wine:"
echo "  $WINE"
echo
echo "osu!:"
echo "  $OSU"
echo
echo "Wine prefix:"
echo "  $PREFIX"
echo

# Проверяем основные файлы
if [[ ! -x "$WINE" ]]; then
    echo "ОШИБКА: Wine не найден:"
    echo "  $WINE"
    exit 1
fi

if [[ ! -f "$OSU" ]]; then
    echo "ОШИБКА: osu!.exe не найден:"
    echo "  $OSU"
    exit 1
fi

echo "[1/6] Создание каталогов..."
mkdir -p "$HOME/.local/bin"
mkdir -p "$APPDIR"

echo "[2/6] Создание osu-open..."

cat > "$HANDLER" <<'EOF'
#!/usr/bin/env bash

export WINEARCH=win32
export WINEPREFIX="$HOME/.wineosu"
export WINEFSYNC=1
export WINE_DISABLE_VK_CHILD_WINDOW_RENDERING_HACK=1
export PATH="$HOME/wine-osu/bin:$PATH"

export STAGING_AUDIO_DURATION=13333
export STAGING_AUDIO_PERIOD=13333

export vblank_mode=0
export __GL_SYNC_TO_VBLANK=0
export __GL_MaxFramesAllowed=0
export __GL_THREADED_OPTIMIZATIONS=1

exec "$HOME/wine-osu/bin/wine" "$HOME/osu/osu!.exe" "$@"
EOF

chmod +x "$HANDLER"

echo "[3/6] Создание desktop entry для файлов..."

cat > "$APPDIR/osu-open.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=osu! File Handler
Comment=Open osu! files with osu!
Exec=$HANDLER %f
MimeType=application/x-osu-beatmap-archive;application/x-osu-skin-archive;application/x-osu-replay;application/x-osu-beatmap;application/x-osu-storyboard;
NoDisplay=true
Terminal=false
Icon=osu!
EOF

echo "[4/6] Создание desktop entry для osu://..."

cat > "$APPDIR/osu-url-handler.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=osu! URL Handler
Comment=Open osu:// links with osu!
Exec=$HANDLER %u
MimeType=x-scheme-handler/osu;
NoDisplay=true
Terminal=false
Icon=osu!
EOF

echo "[5/6] Обновление desktop database..."

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPDIR" 2>/dev/null || true
fi

echo "[6/6] Настройка MIME и osu://..."

xdg-mime default osu-open.desktop application/x-osu-beatmap-archive
xdg-mime default osu-open.desktop application/x-osu-skin-archive
xdg-mime default osu-open.desktop application/x-osu-replay
xdg-mime default osu-open.desktop application/x-osu-beatmap
xdg-mime default osu-open.desktop application/x-osu-storyboard

xdg-mime default osu-url-handler.desktop x-scheme-handler/osu

echo
echo "=========================================="
echo "                 ГОТОВО"
echo "=========================================="
echo
echo ".osz     -> osu-open.desktop"
echo ".osz2    -> osu-open.desktop"
echo ".osk     -> osu-open.desktop"
echo ".osr     -> osu-open.desktop"
echo ".osu     -> osu-open.desktop"
echo ".osb     -> osu-open.desktop"
echo "osu://   -> osu-url-handler.desktop"
echo
echo "Handler:"
echo "  $HANDLER"
echo
echo "File desktop entry:"
echo "  $APPDIR/osu-open.desktop"
echo
echo "URL desktop entry:"
echo "  $APPDIR/osu-url-handler.desktop"
echo
echo "osu!:"
echo "  $OSU"
echo
echo "Wine:"
echo "  $WINE"
echo
echo "Проверка:"
echo
echo "  osz  : $(xdg-mime query default application/x-osu-beatmap-archive)"
echo "  osk  : $(xdg-mime query default application/x-osu-skin-archive)"
echo "  osr  : $(xdg-mime query default application/x-osu-replay)"
echo "  osu  : $(xdg-mime query default application/x-osu-beatmap)"
echo "  osb  : $(xdg-mime query default application/x-osu-storyboard)"
echo "  URL  : $(xdg-mime query default x-scheme-handler/osu)"
echo
echo "=========================================="
