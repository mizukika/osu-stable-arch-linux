#!/usr/bin/env bash

# ============================================================
#                         osu! for Arch
#                  Stable + Wine + handlers
# ============================================================

set -uo pipefail

# -----------------------------
# Colors
# -----------------------------

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'

# -----------------------------
# Paths
# -----------------------------

WINE_DIR="$HOME/wine-osu"
WINE="$WINE_DIR/bin/wine"

PREFIX="$HOME/.wineosu"
OSU_DIR="$HOME/osu"
OSU_EXE="$OSU_DIR/osu!.exe"

BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

OSU_LAUNCHER="$BIN_DIR/osu"
OSU_KILLER="$BIN_DIR/osukill"
OSU_HANDLER="$BIN_DIR/osu-open"

DESKTOP_MAIN="$APP_DIR/osu.desktop"
DESKTOP_FILE="$APP_DIR/osu-open.desktop"
DESKTOP_URL="$APP_DIR/osu-url-handler.desktop"

# -----------------------------
# Downloads
# -----------------------------

OSU_URL="https://m1.ppy.sh/r/osu!install.exe"

# Original Wine build used by the tutorial.
WINE_URL="http://puu.sh/KAnxf/6e2425cc8f.xz"
WINE_ARCHIVE="$HOME/Downloads/wine-osu-7.15.2-x86_64.tar.xz"

# -----------------------------
# Helpers
# -----------------------------

line() {
    printf "${DIM}────────────────────────────────────────────────────────${RESET}\n"
}

title() {
    clear
    printf "\n"
    printf "${MAGENTA}${BOLD}"
    printf "        ██████  ███████ ██    ██ \n"
    printf "       ██    ██ ██      ██    ██ \n"
    printf "       ██    ██ ███████ ██    ██ \n"
    printf "       ██    ██      ██ ██    ██ \n"
    printf "        ██████  ███████  ██████  \n"
    printf "${RESET}"
    printf "\n"
    printf "${CYAN}${BOLD}             osu! Stable — Arch Linux${RESET}\n"
    printf "${DIM}              Wine installation manager${RESET}\n"
    printf "\n"
}

info() {
    printf "${BLUE}  [INFO]${RESET} %s\n" "$1"
}

success() {
    printf "${GREEN}  [ OK ]${RESET} %s\n" "$1"
}

warn() {
    printf "${YELLOW}  [WARN]${RESET} %s\n" "$1"
}

error() {
    printf "${RED}  [FAIL]${RESET} %s\n" "$1"
}

step() {
    printf "\n${CYAN}${BOLD}  → %s${RESET}\n" "$1"
}

pause() {
    printf "\n${DIM}Нажми Enter для продолжения...${RESET}"
    read -r
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# -----------------------------
# GPU detection
# -----------------------------

detect_gpu() {
    if command_exists nvidia-smi && nvidia-smi >/dev/null 2>&1; then
        GPU="nvidia"
    elif command_exists lspci; then
        if lspci | grep -qi "AMD"; then
            GPU="amd"
        elif lspci | grep -qi "Intel"; then
            GPU="intel"
        else
            GPU="other"
        fi
    else
        GPU="other"
    fi
}

# -----------------------------
# Dependencies
# -----------------------------

install_dependencies() {
    step "Установка системных зависимостей"

    sudo pacman -S --needed --noconfirm \
        giflib \
        lib32-giflib \
        libpng \
        lib32-libpng \
        libldap \
        lib32-libldap \
        gnutls \
        lib32-gnutls \
        mpg123 \
        lib32-mpg123 \
        openal \
        lib32-openal \
        v4l-utils \
        lib32-v4l-utils \
        libpulse \
        lib32-libpulse \
        libgpg-error \
        lib32-libgpg-error \
        alsa-plugins \
        lib32-alsa-plugins \
        alsa-lib \
        lib32-alsa-lib \
        libjpeg-turbo \
        lib32-libjpeg-turbo \
        sqlite \
        lib32-sqlite \
        libxcomposite \
        lib32-libxcomposite \
        libxinerama \
        lib32-libxinerama \
        libgcrypt \
        lib32-libgcrypt \
        ncurses \
        lib32-ncurses \
        opencl-icd-loader \
        lib32-opencl-icd-loader \
        libxslt \
        lib32-libxslt \
        libva \
        lib32-libva \
        gtk3 \
        lib32-gtk3 \
        gst-plugins-base-libs \
        lib32-gst-plugins-base-libs \
        vulkan-icd-loader \
        lib32-vulkan-icd-loader \
        wine \
        winetricks \
        wget \
        curl \
        unzip \
        p7zip \
        xdg-utils \
        desktop-file-utils

    success "Зависимости установлены"
}

# -----------------------------
# Custom Wine
# -----------------------------

install_custom_wine() {
    step "Проверка Wine osu!"

    if [[ -x "$WINE" ]]; then
        success "Кастомный Wine уже установлен"
        "$WINE" --version || true
        return 0
    fi

    mkdir -p "$HOME/Downloads"

    info "Скачивание Wine 7.15.2..."
    info "Источник: $WINE_URL"

    if ! wget -O "$WINE_ARCHIVE" "$WINE_URL"; then
        warn "Не удалось скачать кастомный Wine из старого источника."
        warn "Будет использован системный Wine."

        if command_exists wine; then
            WINE="$(command -v wine)"
            WINE_DIR=""
            success "Используется системный Wine: $WINE"
            return 0
        fi

        error "Wine не найден."
        return 1
    fi

    rm -rf "$HOME/wine-osu"
    mkdir -p "$HOME/wine-osu"

    if ! tar -xf "$WINE_ARCHIVE" -C "$HOME"; then
        error "Не удалось распаковать Wine."
        return 1
    fi

    # Архив обычно содержит wine-osu/
    if [[ -d "$HOME/wine-osu" ]]; then
        success "Wine установлен"
    else
        error "После распаковки каталог wine-osu не найден."
        return 1
    fi

    chmod +x "$HOME/wine-osu/bin/"* 2>/dev/null || true

    if [[ -x "$WINE" ]]; then
        "$WINE" --version || true
        success "Wine готов"
    else
        error "Wine binary не найден: $WINE"
        return 1
    fi
}

# -----------------------------
# osu! download
# -----------------------------

download_osu() {
    step "Установка osu! Stable"

    mkdir -p "$OSU_DIR"

    if [[ -f "$OSU_EXE" ]]; then
        success "osu!.exe уже существует"
        return 0
    fi

    info "Скачивание официального osu! Stable installer..."

    if ! wget \
        --show-progress \
        --output-document="$OSU_EXE" \
        "$OSU_URL"; then

        error "Не удалось скачать osu!"
        rm -f "$OSU_EXE"
        return 1
    fi

    success "osu! скачан"
}

# -----------------------------
# Wine prefix
# -----------------------------

setup_prefix() {
    step "Создание Wine prefix"

    export WINEARCH=win32
    export WINEPREFIX="$PREFIX"

    if [[ ! -d "$PREFIX" ]]; then
        info "Создаём 32-bit Wine prefix..."
        "$WINE" wineboot -u >/dev/null 2>&1 || true
    else
        info "Wine prefix уже существует"
    fi

    info "Установка Windows-компонентов..."
    info "Если появится окно Mono — нажми Cancel."

    "$WINE" wineboot -u >/dev/null 2>&1 || true

    WINEPREFIX="$PREFIX" \
    WINEARCH=win32 \
    winetricks -q dotnet45 cjkfonts gdiplus

    success "Wine prefix настроен"
}

# -----------------------------
# Launcher
# -----------------------------

create_launcher() {
    step "Создание launcher"

    mkdir -p "$BIN_DIR"

    cat > "$OSU_LAUNCHER" <<EOF
#!/usr/bin/env bash

export WINEARCH=win32
export WINEPREFIX="\$HOME/.wineosu"
export WINEFSYNC=1
export WINE_DISABLE_VK_CHILD_WINDOW_RENDERING_HACK=1

export STAGING_AUDIO_DURATION=13333
export STAGING_AUDIO_PERIOD=13333

# Graphics
EOF

    if [[ "$GPU" == "nvidia" ]]; then
        cat >> "$OSU_LAUNCHER" <<'EOF'
export __GL_SYNC_TO_VBLANK=0
export __GL_MaxFramesAllowed=0
export __GL_THREADED_OPTIMIZATIONS=1
EOF
    else
        cat >> "$OSU_LAUNCHER" <<'EOF'
export vblank_mode=0
EOF
    fi

    cat >> "$OSU_LAUNCHER" <<EOF

cd "\$HOME/osu"

exec "$WINE" "\$HOME/osu/osu!.exe" "\$@"
EOF

    chmod +x "$OSU_LAUNCHER"

    success "Команда osu создана"
}

# -----------------------------
# Killer
# -----------------------------

create_killer() {
    step "Создание osukill"

    cat > "$OSU_KILLER" <<EOF
#!/usr/bin/env bash

export WINEARCH=win32
export WINEPREFIX="\$HOME/.wineosu"

if command -v wineserver >/dev/null 2>&1; then
    wineserver -k
else
    "$WINE" wineserver -k
fi
EOF

    chmod +x "$OSU_KILLER"

    success "Команда osukill создана"
}

# -----------------------------
# File handler
# -----------------------------

create_file_handler() {
    step "Настройка открытия osu! файлов"

    cat > "$OSU_HANDLER" <<EOF
#!/usr/bin/env bash

export WINEARCH=win32
export WINEPREFIX="\$HOME/.wineosu"
export WINEFSYNC=1
export WINE_DISABLE_VK_CHILD_WINDOW_RENDERING_HACK=1

export STAGING_AUDIO_DURATION=13333
export STAGING_AUDIO_PERIOD=13333

EOF

    if [[ "$GPU" == "nvidia" ]]; then
        cat >> "$OSU_HANDLER" <<'EOF'
export __GL_SYNC_TO_VBLANK=0
export __GL_MaxFramesAllowed=0
export __GL_THREADED_OPTIMIZATIONS=1
EOF
    else
        cat >> "$OSU_HANDLER" <<'EOF'
export vblank_mode=0
EOF
    fi

    cat >> "$OSU_HANDLER" <<EOF

exec "$WINE" "\$HOME/osu/osu!.exe" "\$@"
EOF

    chmod +x "$OSU_HANDLER"

    success "File handler создан"
}

# -----------------------------
# Desktop entries
# -----------------------------

create_desktop_entries() {
    step "Создание desktop entries"

    mkdir -p "$APP_DIR"

    cat > "$DESKTOP_MAIN" <<EOF
[Desktop Entry]
Type=Application
Name=osu!
Comment=osu! Stable
Exec=$OSU_LAUNCHER
Path=$OSU_DIR
Terminal=false
StartupNotify=true
Categories=Game;
EOF

    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=osu! File Handler
Comment=Open osu! files with osu!
Exec=$OSU_HANDLER %f
MimeType=application/x-osu-beatmap-archive;application/x-osu-skin-archive;application/x-osu-replay;application/x-osu-beatmap;application/x-osu-storyboard;
NoDisplay=true
Terminal=false
EOF

    cat > "$DESKTOP_URL" <<EOF
[Desktop Entry]
Type=Application
Name=osu! URL Handler
Comment=Open osu:// links with osu!
Exec=$OSU_HANDLER %u
MimeType=x-scheme-handler/osu;
NoDisplay=true
Terminal=false
EOF

    chmod +x "$DESKTOP_MAIN"
    chmod +x "$DESKTOP_FILE"
    chmod +x "$DESKTOP_URL"

    if command_exists update-desktop-database; then
        update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
    fi

    success "osu! добавлен в меню приложений"
}

# -----------------------------
# MIME handlers
# -----------------------------

setup_handlers() {
    step "Регистрация файлов и osu://"

    xdg-mime default osu-open.desktop \
        application/x-osu-beatmap-archive

    xdg-mime default osu-open.desktop \
        application/x-osu-skin-archive

    xdg-mime default osu-open.desktop \
        application/x-osu-replay

    xdg-mime default osu-open.desktop \
        application/x-osu-beatmap

    xdg-mime default osu-open.desktop \
        application/x-osu-storyboard

    xdg-mime default osu-url-handler.desktop \
        x-scheme-handler/osu

    success "MIME handlers настроены"
    success "osu:// ссылки зарегистрированы"
}

# -----------------------------
# Full install
# -----------------------------

full_install() {
    title

    printf "${WHITE}${BOLD}  Полная установка osu! Stable${RESET}\n\n"

    line

    printf "  ${DIM}osu!       ${RESET}$OSU_EXE\n"
    printf "  ${DIM}Prefix     ${RESET}$PREFIX\n"
    printf "  ${DIM}Wine       ${RESET}$WINE\n"

    detect_gpu

    printf "  ${DIM}GPU        ${RESET}$GPU\n"

    line

    printf "\n"

    read -rp "  Начать установку? [Y/n]: " answer

    if [[ "$answer" =~ ^[Nn]$ ]]; then
        return
    fi

    install_dependencies || return
    install_custom_wine || return
    download_osu || return
    setup_prefix || return

    create_launcher
    create_killer
    create_file_handler
    create_desktop_entries
    setup_handlers

    title

    printf "${GREEN}${BOLD}"
    printf "  ╔══════════════════════════════════════════════════╗\n"
    printf "  ║              osu! УСТАНОВЛЕН                     ║\n"
    printf "  ╚══════════════════════════════════════════════════╝\n"
    printf "${RESET}\n"

    printf "  ${CYAN}Запуск:${RESET}\n"
    printf "    osu\n\n"

    printf "  ${CYAN}Принудительно закрыть:${RESET}\n"
    printf "    osukill\n\n"

    printf "  ${CYAN}Игра:${RESET}\n"
    printf "    $OSU_EXE\n\n"

    printf "  ${CYAN}Wine prefix:${RESET}\n"
    printf "    $PREFIX\n\n"

    printf "  ${CYAN}GPU:${RESET} $GPU\n\n"

    printf "${DIM}"
    printf "  .osz / .osk / .osr / .osu / .osb → osu!\n"
    printf "  osu:// → osu!\n"
    printf "${RESET}\n"

    pause
}

# -----------------------------
# Launch
# -----------------------------

launch_osu() {
    if [[ ! -x "$OSU_LAUNCHER" ]]; then
        error "osu ещё не установлен."
        pause
        return
    fi

    "$OSU_LAUNCHER"
}

# -----------------------------
# Kill
# -----------------------------

kill_osu() {
    if [[ -x "$OSU_KILLER" ]]; then
        "$OSU_KILLER"
        success "Wine processes остановлены"
    else
        wineserver -k 2>/dev/null || true
        success "Wine processes остановлены"
    fi

    pause
}

# -----------------------------
# Repair handlers
# -----------------------------

repair_handlers() {
    title

    detect_gpu

    create_file_handler
    create_desktop_entries
    setup_handlers

    printf "\n"
    success "Handlers восстановлены."

    printf "\n"
    printf "  Проверка:\n\n"

    printf "  osz → %s\n" \
        "$(xdg-mime query default application/x-osu-beatmap-archive 2>/dev/null || echo '?')"

    printf "  osk → %s\n" \
        "$(xdg-mime query default application/x-osu-skin-archive 2>/dev/null || echo '?')"

    printf "  osr → %s\n" \
        "$(xdg-mime query default application/x-osu-replay 2>/dev/null || echo '?')"

    printf "  osu → %s\n" \
        "$(xdg-mime query default application/x-osu-beatmap 2>/dev/null || echo '?')"

    printf "  osb → %s\n" \
        "$(xdg-mime query default application/x-osu-storyboard 2>/dev/null || echo '?')"

    printf "  URL → %s\n" \
        "$(xdg-mime query default x-scheme-handler/osu 2>/dev/null || echo '?')"

    pause
}

# -----------------------------
# Status
# -----------------------------

status() {
    title

    detect_gpu

    printf "${BOLD}  Состояние установки${RESET}\n\n"

    if [[ -f "$OSU_EXE" ]]; then
        printf "  ${GREEN}●${RESET} osu!.exe       установлен\n"
    else
        printf "  ${RED}●${RESET} osu!.exe       отсутствует\n"
    fi

    if [[ -d "$PREFIX" ]]; then
        printf "  ${GREEN}●${RESET} Wine prefix     существует\n"
    else
        printf "  ${RED}●${RESET} Wine prefix     отсутствует\n"
    fi

    if [[ -x "$WINE" ]]; then
        printf "  ${GREEN}●${RESET} Custom Wine     установлен\n"
    else
        printf "  ${YELLOW}●${RESET} Custom Wine     отсутствует\n"
    fi

    if [[ -x "$OSU_LAUNCHER" ]]; then
        printf "  ${GREEN}●${RESET} osu launcher     установлен\n"
    else
        printf "  ${RED}●${RESET} osu launcher     отсутствует\n"
    fi

    printf "\n"
    printf "  GPU: ${CYAN}$GPU${RESET}\n"

    printf "\n"
    printf "  osu! path:\n"
    printf "    $OSU_EXE\n"

    printf "\n"
    printf "  Wine prefix:\n"
    printf "    $PREFIX\n"

    pause
}

# -----------------------------
# Uninstall
# -----------------------------

uninstall() {
    title

    printf "${RED}${BOLD}  Удаление osu!${RESET}\n\n"

    printf "  Будут удалены:\n\n"
    printf "    $OSU_DIR\n"
    printf "    $PREFIX\n"
    printf "    $WINE_DIR\n"
    printf "    $OSU_LAUNCHER\n"
    printf "    $OSU_KILLER\n"
    printf "    $OSU_HANDLER\n"
    printf "    $DESKTOP_MAIN\n"
    printf "    $DESKTOP_FILE\n"
    printf "    $DESKTOP_URL\n\n"

    warn "Beatmaps, skins и настройки внутри ~/osu тоже будут удалены."

    read -rp "  Точно удалить? Введите DELETE: " answer

    if [[ "$answer" != "DELETE" ]]; then
        info "Отмена."
        pause
        return
    fi

    rm -rf "$OSU_DIR"
    rm -rf "$PREFIX"
    rm -rf "$WINE_DIR"

    rm -f "$OSU_LAUNCHER"
    rm -f "$OSU_KILLER"
    rm -f "$OSU_HANDLER"

    rm -f "$DESKTOP_MAIN"
    rm -f "$DESKTOP_FILE"
    rm -f "$DESKTOP_URL"

    if command_exists update-desktop-database; then
        update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
    fi

    success "osu! удалён."

    pause
}

# -----------------------------
# Menu
# -----------------------------

menu() {
    while true; do
        title

        printf "  ${BOLD}1${RESET}  Установить / обновить osu!\n"
        printf "  ${BOLD}2${RESET}  Запустить osu!\n"
        printf "  ${BOLD}3${RESET}  Закрыть osu!\n"
        printf "  ${BOLD}4${RESET}  Починить .osz / osu:// handlers\n"
        printf "  ${BOLD}5${RESET}  Проверить установку\n"
        printf "  ${BOLD}6${RESET}  Удалить osu!\n"
        printf "  ${BOLD}0${RESET}  Выход\n"

        printf "\n"
        line

        printf "\n  Выбор: "
        read -r choice

        case "$choice" in
            1)
                full_install
                ;;
            2)
                launch_osu
                ;;
            3)
                kill_osu
                ;;
            4)
                repair_handlers
                ;;
            5)
                status
                ;;
            6)
                uninstall
                ;;
            0)
                clear
                exit 0
                ;;
            *)
                warn "Неизвестный пункт."
                sleep 1
                ;;
        esac
    done
}

# -----------------------------
# Main
# -----------------------------

if [[ "${1:-}" == "--install" ]]; then
    full_install
    exit $?
fi

if [[ "${1:-}" == "--status" ]]; then
    status
    exit $?
fi

if [[ "${1:-}" == "--repair" ]]; then
    repair_handlers
    exit $?
fi

if [[ "${1:-}" == "--kill" ]]; then
    kill_osu
    exit $?
fi

menu
