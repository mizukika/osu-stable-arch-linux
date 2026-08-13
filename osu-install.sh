#!/usr/bin/env bash

# ============================================================
#  osu! Stable — Arch Linux  |  Wine installation manager
# ============================================================

set -uo pipefail

VERSION="1.1.0"

# -----------------------------
# Colors (MSR-like)
# -----------------------------

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
GRAY='\033[1;30m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
DARK='\033[90m'

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

CONFIG_DIR="$HOME/.config/osu-stable-arch"
AUDIO_ENV="$CONFIG_DIR/audio.env"
AUDIO_STATE="$CONFIG_DIR/audio.state"
AUDIO_BACKUP_DIR="$CONFIG_DIR/audio-backup"
LANG_FILE="$CONFIG_DIR/ui.lang"

PW_CONF_D="$HOME/.config/pipewire/pipewire.conf.d"
PW_PULSE_D="$HOME/.config/pipewire/pipewire-pulse.conf.d"
PW_DROPIN="$PW_CONF_D/99-osu-lowlatency.conf"
PW_PULSE_DROPIN="$PW_PULSE_D/99-osu-lowlatency.conf"

OSU_URL="https://m1.ppy.sh/r/osu!install.exe"
WINE_URL="http://puu.sh/KAnxf/6e2425cc8f.xz"
WINE_ARCHIVE="$HOME/Downloads/wine-osu-7.15.2-x86_64.tar.xz"

UI_LANG=""
BOX_W=58

# -----------------------------
# i18n
# -----------------------------

declare -A MSG=()

load_lang() {
    local lang="${1:-ru}"
    UI_LANG="$lang"
    MSG=()

    if [[ "$lang" == "en" ]]; then
        MSG[press_enter]="Press Enter to continue..."
        MSG[choice]="Choice"
        MSG[unknown_item]="Unknown option."
        MSG[cancel]="Cancelled."
        MSG[back]="Back"
        MSG[exit]="Exit"
        MSG[select_lang_title]="SELECT LANGUAGE"
        MSG[select_lang_hint]="Choose UI language for this session"
        MSG[lang_ru]="Russian"
        MSG[lang_en]="English"
        MSG[menu_title]="Main menu"
        MSG[menu_hint]="Type the number and press Enter"
        MSG[m1]="Install / update osu!"
        MSG[m2]="Launch osu!"
        MSG[m3]="Kill osu!"
        MSG[m4]="Repair .osz / osu:// handlers"
        MSG[m5]="Check installation"
        MSG[m6]="Uninstall osu!"
        MSG[m7]="Low-latency audio (PipeWire presets)"
        MSG[m8]="System preflight (PipeWire / multilib / deps)"
        MSG[subtitle]="Wine installation manager"
        MSG[tagline]="osu! Stable — Arch Linux"
        MSG[stats_user]="User"
        MSG[stats_gpu]="GPU"
        MSG[stats_audio]="Audio"
        MSG[stats_lang]="Lang"
        MSG[yes_no_install]="Start installation? [Y/n]: "
        MSG[full_install_title]="Full osu! Stable installation"
        MSG[installed_banner]="osu! INSTALLED"
        MSG[launch]="Launch"
        MSG[force_close]="Force close"
        MSG[game]="Game"
        MSG[audio_menu_hint]="menu item 7 — PipeWire presets + restore"
        MSG[not_installed]="osu! is not installed yet."
        MSG[wine_stopped]="Wine processes stopped"
        MSG[handlers_ok]="Handlers restored."
        MSG[check]="Check"
        MSG[status_title]="Installation status"
        MSG[present]="present"
        MSG[missing]="missing"
        MSG[exists]="exists"
        MSG[absent]="absent"
        MSG[uninstall_title]="Uninstall osu!"
        MSG[will_remove]="Will be removed:"
        MSG[audio_also]="PipeWire low-latency drop-ins/backups can be removed too."
        MSG[warn_beatmaps]="Beatmaps, skins and settings inside ~/osu will also be deleted."
        MSG[type_delete]="Really delete? Type DELETE: "
        MSG[remove_audio]="Also remove low-latency PipeWire drop-ins? [y/N]: "
        MSG[audio_removed]="Audio drop-ins removed"
        MSG[uninstalled]="osu! uninstalled."
        MSG[dep_step]="Installing system dependencies"
        MSG[dep_ok]="Dependencies installed"
        MSG[preflight_title]="System preflight"
        MSG[preflight_ok]="All required components look OK."
        MSG[preflight_issues]="Missing components found (needed for osu! / low-latency audio)."
        MSG[preflight_offer]="Install missing packages now? [Y/n]: "
        MSG[preflight_skip]="Skipped. Install may fail without these."
        MSG[preflight_installing]="Installing missing system packages..."
        MSG[preflight_done]="System packages ready."
        MSG[preflight_fail]="Failed to install some packages. Check pacman output."
        MSG[pf_sudo]="sudo"
        MSG[pf_network]="network"
        MSG[pf_multilib]="multilib repo"
        MSG[pf_pipewire]="PipeWire"
        MSG[pf_wireplumber]="WirePlumber"
        MSG[pf_pw_pulse]="pipewire-pulse"
        MSG[pf_pw_alsa]="pipewire-alsa"
        MSG[pf_realtime]="realtime-privileges"
        MSG[pf_wine]="wine"
        MSG[pf_winetricks]="winetricks"
        MSG[pf_git]="git"
        MSG[pf_path]="~/.local/bin in PATH"
        MSG[pf_display]="graphical session (DISPLAY/WAYLAND)"
        MSG[pf_enable_multilib]="Enable [multilib] in pacman.conf? [Y/n]: "
        MSG[pf_multilib_ok]="[multilib] enabled + pacman -Sy done."
        MSG[pf_multilib_fail]="Could not enable multilib automatically."
        MSG[pf_note_wp]="Using WirePlumber (modern). Not installing obsolete pipewire-media-session from the old guide."
        MSG[pf_note_gpu]="GPU drivers are not auto-installed — pick them in archinstall / pacman yourself."
        MSG[pf_path_fix]="Add export PATH=\"\$HOME/.local/bin:\$PATH\" to ~/.bashrc? [Y/n]: "
        MSG[pf_path_added]="PATH line added to ~/.bashrc (re-open terminal)."
        MSG[pf_running]="PipeWire user services"
        MSG[pf_enable_pw]="Enable/start PipeWire user services now? [Y/n]: "
        MSG[pf_pw_started]="PipeWire user services enabled/started."
        MSG[wine_check]="Checking Wine osu!"
        MSG[wine_custom_ok]="Custom Wine already installed"
        MSG[wine_dl]="Downloading Wine 7.15.2..."
        MSG[wine_src]="Source: %s"
        MSG[wine_dl_fail]="Could not download custom Wine from the old source."
        MSG[wine_sys_fallback]="Falling back to system Wine."
        MSG[wine_sys_ok]="Using system Wine: %s"
        MSG[wine_missing]="Wine not found."
        MSG[wine_unpack_fail]="Failed to extract Wine."
        MSG[wine_installed]="Wine installed"
        MSG[wine_dir_missing]="wine-osu directory not found after extract."
        MSG[wine_ready]="Wine ready"
        MSG[wine_bin_missing]="Wine binary not found: %s"
        MSG[osu_step]="Installing osu! Stable"
        MSG[osu_exists]="osu!.exe already exists"
        MSG[osu_dl]="Downloading official osu! Stable installer..."
        MSG[osu_dl_fail]="Failed to download osu!"
        MSG[osu_ok]="osu! downloaded"
        MSG[prefix_step]="Creating Wine prefix"
        MSG[prefix_create]="Creating 32-bit Wine prefix..."
        MSG[prefix_exists]="Wine prefix already exists"
        MSG[prefix_win]="Installing Windows components..."
        MSG[prefix_mono]="If a Mono window appears — press Cancel."
        MSG[prefix_ok]="Wine prefix configured"
        MSG[backup_ok]="Backup: %s"
        MSG[rt_step]="Realtime privileges (Arch: realtime-privileges)"
        MSG[rt_install]="Installing realtime-privileges..."
        MSG[rt_install_fail]="Failed to install realtime-privileges"
        MSG[rt_pkg_ok]="realtime-privileges already installed"
        MSG[rt_in]="User %s already in group realtime"
        MSG[rt_add]="Adding %s to group realtime..."
        MSG[rt_added]="Added to realtime (re-login required)"
        MSG[rt_relogin]="Log out and back in so rtprio/memlock apply."
        MSG[audio_in]="User %s already in group audio"
        MSG[audio_add]="Adding %s to group audio..."
        MSG[audio_added]="Added to audio"
        MSG[pw_written]="PipeWire drop-ins written (quantum=%s)"
        MSG[pw_restart]="Restart PipeWire + WirePlumber"
        MSG[pw_restart_fail]="systemctl --user restart failed (no user-session bus?)."
        MSG[pw_restart_hint]="Re-login or run manually:"
        MSG[pw_restart_ok]="Audio stack restarted"
        MSG[preset_unknown]="Unknown preset: %s"
        MSG[preset_step]="Preset: %s"
        MSG[apply_preset]="Apply preset «%s»? [Y/n]: "
        MSG[preset_ok]="Preset «%s» applied."
        MSG[preset_compat]="In osu!, enable Audio compatibility mode if not already."
        MSG[preset_pwtop]="Check buffer: pw-top (QUANT column for wine/osu)."
        MSG[preset_crackle]="If crackle — pick a safer preset (safe/balanced) or raise STAGING."
        MSG[restore_step]="Restore low-latency settings"
        MSG[restore_info1]="Our drop-ins will be removed and STAGING_* reset to 13333/13333."
        MSG[restore_info2]="Latest backup stays in:"
        MSG[restore_ask]="Restore? [Y/n]: "
        MSG[restore_ok]="Audio restored to defaults (no osu drop-ins)."
        MSG[audio_status_title]="Low-latency audio"
        MSG[preset_label]="Preset"
        MSG[yes]="yes"
        MSG[no]="no"
        MSG[sys_default]="no (system default)"
        MSG[modern_path]="Modern path: PipeWire drop-ins + realtime group."
        MSG[dont_touch]="We never touch: /etc/pulse/*, full pipewire.conf overwrite, media-session."
        MSG[staging_title]="Manual STAGING_AUDIO_* tuning"
        MSG[staging_help1]="PERIOD in microseconds, DURATION = PERIOD × 2."
        MSG[staging_help2]="Start high and lower until crackle appears."
        MSG[staging_help3]="Examples: 25000/50000 → 13333/26666 → 6666/13333 → 3333/6666"
        MSG[staging_bad]="Need a number between 1000 and 100000"
        MSG[staging_write]="Write? [Y/n]: "
        MSG[staging_ok]="STAGING updated. Restart osu!"
        MSG[audio_menu_title]="Low-latency audio (PipeWire)"
        MSG[cur_preset]="current preset"
        MSG[a1]="Preset safe       — quantum 256,  STAGING 20000/40000"
        MSG[a2]="Preset balanced   — quantum 128,  STAGING 13333/26666"
        MSG[a3]="Preset low        — quantum 64,   STAGING 6666/13333"
        MSG[a4]="Preset ultra      — quantum 32,   STAGING 3333/6666"
        MSG[a5]="Manual STAGING (experiment)"
        MSG[a6]="Realtime groups only (no quantum change)"
        MSG[a7]="Status"
        MSG[a8]="Restore defaults (remove drop-ins + default STAGING)"
        MSG[a9]="Restart PipeWire/WirePlumber"
        MSG[launcher_step]="Creating launcher"
        MSG[launcher_ok]="osu command created"
        MSG[killer_step]="Creating osukill"
        MSG[killer_ok]="osukill command created"
        MSG[handler_step]="Configuring osu! file open"
        MSG[handler_ok]="File handler created"
        MSG[desktop_step]="Creating desktop entries"
        MSG[desktop_ok]="osu! added to app menu"
        MSG[mime_step]="Registering files and osu://"
        MSG[mime_ok]="MIME handlers configured"
        MSG[mime_url_ok]="osu:// links registered"
        MSG[shutdown]="See you."
        MSG[installed]="installed"
        MSG[group_rt]="realtime group"
        MSG[group_audio]="audio group"
        MSG[rt_pkg]="realtime-privileges"
        MSG[pw_dropin]="pipewire drop-in"
        MSG[pw_pulse]="pipewire-pulse"
    else
        MSG[press_enter]="Нажми Enter для продолжения..."
        MSG[choice]="Выбор"
        MSG[unknown_item]="Неизвестный пункт."
        MSG[cancel]="Отмена."
        MSG[back]="Назад"
        MSG[exit]="Выход"
        MSG[select_lang_title]="ВЫБОР ЯЗЫКА"
        MSG[select_lang_hint]="Выбери язык интерфейса для этой сессии"
        MSG[lang_ru]="Русский"
        MSG[lang_en]="English"
        MSG[menu_title]="Главное меню"
        MSG[menu_hint]="Введи номер и нажми Enter"
        MSG[m1]="Установить / обновить osu!"
        MSG[m2]="Запустить osu!"
        MSG[m3]="Закрыть osu!"
        MSG[m4]="Починить .osz / osu:// handlers"
        MSG[m5]="Проверить установку"
        MSG[m6]="Удалить osu!"
        MSG[m7]="Low-latency audio (PipeWire пресеты)"
        MSG[m8]="Проверка системы (PipeWire / multilib / deps)"
        MSG[subtitle]="Wine installation manager"
        MSG[tagline]="osu! Stable — Arch Linux"
        MSG[stats_user]="User"
        MSG[stats_gpu]="GPU"
        MSG[stats_audio]="Audio"
        MSG[stats_lang]="Lang"
        MSG[yes_no_install]="Начать установку? [Y/n]: "
        MSG[full_install_title]="Полная установка osu! Stable"
        MSG[installed_banner]="osu! УСТАНОВЛЕН"
        MSG[launch]="Запуск"
        MSG[force_close]="Принудительно закрыть"
        MSG[game]="Игра"
        MSG[audio_menu_hint]="пункт меню 7 — пресеты PipeWire + откат"
        MSG[not_installed]="osu ещё не установлен."
        MSG[wine_stopped]="Wine processes остановлены"
        MSG[handlers_ok]="Handlers восстановлены."
        MSG[check]="Проверка"
        MSG[status_title]="Состояние установки"
        MSG[present]="установлен"
        MSG[missing]="отсутствует"
        MSG[exists]="существует"
        MSG[absent]="отсутствует"
        MSG[uninstall_title]="Удаление osu!"
        MSG[will_remove]="Будут удалены:"
        MSG[audio_also]="PipeWire drop-ins и бэкапы low-latency (если ставил) тоже можно убрать."
        MSG[warn_beatmaps]="Beatmaps, skins и настройки внутри ~/osu тоже будут удалены."
        MSG[type_delete]="Точно удалить? Введите DELETE: "
        MSG[remove_audio]="Убрать и low-latency PipeWire drop-ins? [y/N]: "
        MSG[audio_removed]="Audio drop-ins убраны"
        MSG[uninstalled]="osu! удалён."
        MSG[dep_step]="Установка системных зависимостей"
        MSG[dep_ok]="Зависимости установлены"
        MSG[preflight_title]="Проверка системы"
        MSG[preflight_ok]="Все нужные компоненты на месте."
        MSG[preflight_issues]="Не хватает компонентов (нужны для osu! / low-latency audio)."
        MSG[preflight_offer]="Установить недостающее сейчас? [Y/n]: "
        MSG[preflight_skip]="Пропущено. Без этого установка может упасть."
        MSG[preflight_installing]="Ставлю недостающие системные пакеты..."
        MSG[preflight_done]="Системные пакеты готовы."
        MSG[preflight_fail]="Не удалось поставить часть пакетов. Смотри вывод pacman."
        MSG[pf_sudo]="sudo"
        MSG[pf_network]="сеть"
        MSG[pf_multilib]="репозиторий multilib"
        MSG[pf_pipewire]="PipeWire"
        MSG[pf_wireplumber]="WirePlumber"
        MSG[pf_pw_pulse]="pipewire-pulse"
        MSG[pf_pw_alsa]="pipewire-alsa"
        MSG[pf_realtime]="realtime-privileges"
        MSG[pf_wine]="wine"
        MSG[pf_winetricks]="winetricks"
        MSG[pf_git]="git"
        MSG[pf_path]="~/.local/bin в PATH"
        MSG[pf_display]="графическая сессия (DISPLAY/WAYLAND)"
        MSG[pf_enable_multilib]="Включить [multilib] в pacman.conf? [Y/n]: "
        MSG[pf_multilib_ok]="[multilib] включён + pacman -Sy выполнен."
        MSG[pf_multilib_fail]="Не удалось включить multilib автоматически."
        MSG[pf_note_wp]="Ставим WirePlumber (актуально). Устаревший pipewire-media-session из старого гайда не трогаем."
        MSG[pf_note_gpu]="GPU-драйверы сами не ставим — их выбирают в archinstall / pacman."
        MSG[pf_path_fix]="Добавить export PATH=\"\$HOME/.local/bin:\$PATH\" в ~/.bashrc? [Y/n]: "
        MSG[pf_path_added]="Строка PATH добавлена в ~/.bashrc (открой терминал заново)."
        MSG[pf_running]="user-сервисы PipeWire"
        MSG[pf_enable_pw]="Включить/запустить PipeWire user services сейчас? [Y/n]: "
        MSG[pf_pw_started]="PipeWire user services включены/запущены."
        MSG[wine_check]="Проверка Wine osu!"
        MSG[wine_custom_ok]="Кастомный Wine уже установлен"
        MSG[wine_dl]="Скачивание Wine 7.15.2..."
        MSG[wine_src]="Источник: %s"
        MSG[wine_dl_fail]="Не удалось скачать кастомный Wine из старого источника."
        MSG[wine_sys_fallback]="Будет использован системный Wine."
        MSG[wine_sys_ok]="Используется системный Wine: %s"
        MSG[wine_missing]="Wine не найден."
        MSG[wine_unpack_fail]="Не удалось распаковать Wine."
        MSG[wine_installed]="Wine установлен"
        MSG[wine_dir_missing]="После распаковки каталог wine-osu не найден."
        MSG[wine_ready]="Wine готов"
        MSG[wine_bin_missing]="Wine binary не найден: %s"
        MSG[osu_step]="Установка osu! Stable"
        MSG[osu_exists]="osu!.exe уже существует"
        MSG[osu_dl]="Скачивание официального osu! Stable installer..."
        MSG[osu_dl_fail]="Не удалось скачать osu!"
        MSG[osu_ok]="osu! скачан"
        MSG[prefix_step]="Создание Wine prefix"
        MSG[prefix_create]="Создаём 32-bit Wine prefix..."
        MSG[prefix_exists]="Wine prefix уже существует"
        MSG[prefix_win]="Установка Windows-компонентов..."
        MSG[prefix_mono]="Если появится окно Mono — нажми Cancel."
        MSG[prefix_ok]="Wine prefix настроен"
        MSG[backup_ok]="Бэкап: %s"
        MSG[rt_step]="Realtime-привилегии (Arch: realtime-privileges)"
        MSG[rt_install]="Устанавливаю realtime-privileges..."
        MSG[rt_install_fail]="Не удалось установить realtime-privileges"
        MSG[rt_pkg_ok]="realtime-privileges уже установлен"
        MSG[rt_in]="Пользователь %s уже в группе realtime"
        MSG[rt_add]="Добавляю %s в группу realtime..."
        MSG[rt_added]="Добавлен в realtime (нужен re-login)"
        MSG[rt_relogin]="Выйди из сессии и зайди снова, чтобы rtprio/memlock применились."
        MSG[audio_in]="Пользователь %s уже в группе audio"
        MSG[audio_add]="Добавляю %s в группу audio..."
        MSG[audio_added]="Добавлен в audio"
        MSG[pw_written]="PipeWire drop-ins записаны (quantum=%s)"
        MSG[pw_restart]="Рестарт PipeWire + WirePlumber"
        MSG[pw_restart_fail]="systemctl --user restart не удался (нет user-session bus?)."
        MSG[pw_restart_hint]="Перелогинься или выполни вручную:"
        MSG[pw_restart_ok]="Аудиостек перезапущен"
        MSG[preset_unknown]="Неизвестный пресет: %s"
        MSG[preset_step]="Пресет: %s"
        MSG[apply_preset]="Применить пресет «%s»? [Y/n]: "
        MSG[preset_ok]="Пресет «%s» применён."
        MSG[preset_compat]="В osu! включи Audio compatibility mode, если ещё не."
        MSG[preset_pwtop]="Проверка буфера: pw-top (колонка QUANT у wine/osu)."
        MSG[preset_crackle]="Если crackle — возьми пресет выше (safe/balanced) или подними STAGING вручную."
        MSG[restore_step]="Откат low-latency настроек"
        MSG[restore_info1]="Будут удалены наши drop-ins и возвращены дефолтные STAGING_* (13333/13333)."
        MSG[restore_info2]="Последний бэкап останется в:"
        MSG[restore_ask]="Откатить? [Y/n]: "
        MSG[restore_ok]="Аудио вернули к дефолту (без osu drop-ins)."
        MSG[audio_status_title]="Low-latency audio"
        MSG[preset_label]="Пресет"
        MSG[yes]="да"
        MSG[no]="нет"
        MSG[sys_default]="нет (системный дефолт)"
        MSG[modern_path]="Современный путь: PipeWire drop-ins + realtime group."
        MSG[dont_touch]="Не трогаем: /etc/pulse/*, полный overwrite pipewire.conf, media-session."
        MSG[staging_title]="Ручная подстройка STAGING_AUDIO_*"
        MSG[staging_help1]="PERIOD в микросекундах, DURATION = PERIOD × 2."
        MSG[staging_help2]="Начни выше и снижай, пока нет crackle."
        MSG[staging_help3]="Примеры: 25000/50000 → 13333/26666 → 6666/13333 → 3333/6666"
        MSG[staging_bad]="Нужно число 1000–100000"
        MSG[staging_write]="Записать? [Y/n]: "
        MSG[staging_ok]="STAGING обновлён. Перезапусти osu!"
        MSG[audio_menu_title]="Low-latency audio (PipeWire)"
        MSG[cur_preset]="текущий пресет"
        MSG[a1]="Пресет safe       — quantum 256,  STAGING 20000/40000"
        MSG[a2]="Пресет balanced   — quantum 128,  STAGING 13333/26666"
        MSG[a3]="Пресет low        — quantum 64,   STAGING 6666/13333"
        MSG[a4]="Пресет ultra      — quantum 32,   STAGING 3333/6666"
        MSG[a5]="Ручной STAGING (эксперименты)"
        MSG[a6]="Только realtime-группы (без смены quantum)"
        MSG[a7]="Статус"
        MSG[a8]="Откатить как было (убрать drop-ins + дефолт STAGING)"
        MSG[a9]="Рестарт PipeWire/WirePlumber"
        MSG[launcher_step]="Создание launcher"
        MSG[launcher_ok]="Команда osu создана"
        MSG[killer_step]="Создание osukill"
        MSG[killer_ok]="Команда osukill создана"
        MSG[handler_step]="Настройка открытия osu! файлов"
        MSG[handler_ok]="File handler создан"
        MSG[desktop_step]="Создание desktop entries"
        MSG[desktop_ok]="osu! добавлен в меню приложений"
        MSG[mime_step]="Регистрация файлов и osu://"
        MSG[mime_ok]="MIME handlers настроены"
        MSG[mime_url_ok]="osu:// ссылки зарегистрированы"
        MSG[shutdown]="Пока."
        MSG[installed]="установлен"
        MSG[group_rt]="группа realtime"
        MSG[group_audio]="группа audio"
        MSG[rt_pkg]="realtime-privileges"
        MSG[pw_dropin]="pipewire drop-in"
        MSG[pw_pulse]="pipewire-pulse"
    fi
}

msg() {
    local key="$1"
    printf '%s' "${MSG[$key]:-$key}"
}

msgf() {
    local key="$1"
    shift
    # shellcheck disable=SC2059
    printf "${MSG[$key]:-$key}" "$@"
}

# -----------------------------
# UI (MSR-inspired)
# -----------------------------

clear_screen() {
    printf '\033[H\033[2J'
}

print_gradient_line() {
    local line="$1"
    local len=${#line}
    local i r g b
    local denom=1
    (( len > 1 )) && denom=$((len - 1))
    for ((i = 0; i < len; i++)); do
        r=$((40 + (200 * i) / denom))
        g=$((210 - (90 * i) / denom))
        b=$((255 - (30 * i) / denom))
        (( r > 255 )) && r=255
        (( g < 0 )) && g=0
        printf '\033[38;2;%d;%d;%dm%s' "$r" "$g" "$b" "${line:i:1}"
    done
    printf '%b\n' "$RESET"
}

print_logo() {
    local lines=(
        '  ██████╗ ███████╗██╗   ██╗'
        ' ██╔═══██╗██╔════╝██║   ██║'
        ' ██║   ██║███████╗██║   ██║'
        ' ██║   ██║╚════██║██║   ██║'
        ' ╚██████╔╝███████║╚██████╔╝'
        '  ╚═════╝ ╚══════╝ ╚═════╝'
    )
    local line
    printf '\n'
    for line in "${lines[@]}"; do
        print_gradient_line "  $line"
    done
}

box_rule() {
    local w="${1:-$BOX_W}"
    local i s=""
    for ((i = 0; i < w; i++)); do
        s+="─"
    done
    printf '%s' "$s"
}

box_top() {
    local w="${1:-$BOX_W}"
    printf '  %b┌%s┐%b\n' "$GRAY" "$(box_rule "$w")" "$RESET"
}

box_mid() {
    local w="${1:-$BOX_W}"
    printf '  %b├%s┤%b\n' "$GRAY" "$(box_rule "$w")" "$RESET"
}

box_bot() {
    local w="${1:-$BOX_W}"
    printf '  %b└%s┘%b\n' "$GRAY" "$(box_rule "$w")" "$RESET"
}

box_line() {
    # Centered box row. box_line "text" [color] [width]
    local text="$1"
    local color="${2:-$WHITE}"
    local w="${3:-$BOX_W}"
    local plain="$text"
    local len=${#plain}
    local left=0 right=0
    if (( len < w )); then
        left=$(( (w - len) / 2 ))
        right=$(( w - len - left ))
    fi
    printf '  %b│%b%b%*s%s%*s%b%b│%b\n' \
        "$GRAY" "$RESET" "$color" "$left" "" "$plain" "$right" "" "$RESET" "$GRAY" "$RESET"
}

box_line_left() {
    local text="$1"
    local color="${2:-$WHITE}"
    local w="${3:-$BOX_W}"
    local content=" $text"
    local pad=$((w - ${#content}))
    (( pad < 0 )) && pad=0
    printf '  %b│%b%b%s%*s%b%b│%b\n' "$GRAY" "$RESET" "$color" "$content" "$pad" "" "$RESET" "$GRAY" "$RESET"
}

menu_item() {
    local num="$1"
    local label="$2"
    local selected="${3:-0}"
    local n
    printf -v n '%02d' "$num"
    if [[ "$selected" == "1" ]]; then
        box_line_left " $n. $label" "$CYAN$BOLD"
    else
        box_line_left " $n. $label" "$WHITE"
    fi
}

divider() {
    local w="${1:-$((BOX_W + 2))}"
    printf '  %b%s%b\n' "$GRAY" "$(box_rule "$w")" "$RESET"
}

title() {
    clear_screen
    print_logo
    printf '  %b[ %b%s%b ]%b  %b%s%b\n' "$GRAY" "$CYAN" "v$VERSION" "$GRAY" "$RESET" "$DIM" "$(msg tagline)" "$RESET"
    divider

    local gpu_s="?"
    [[ -n "${GPU:-}" ]] && gpu_s="$GPU"
    local audio_s
    audio_s="$(current_audio_preset 2>/dev/null || echo default)"
    printf '  %b[%s]%b %s  %b[%s]%b %s  %b[%s]%b %s  %b[%s]%b %s\n' \
        "$BLUE" "$(msg stats_user)" "$RESET" "${TARGET_USER:-?}" \
        "$MAGENTA" "$(msg stats_gpu)" "$RESET" "$gpu_s" \
        "$GREEN" "$(msg stats_audio)" "$RESET" "$audio_s" \
        "$YELLOW" "$(msg stats_lang)" "$RESET" "${UI_LANG:-?}"
    divider
    printf '\n'
}

info() {
    printf '  %b[%b*%b]%b %s\n' "$BLUE" "$RESET" "$BLUE" "$RESET" "$1"
}

success() {
    printf '  %b[%b+%b]%b %s\n' "$BLUE" "$GREEN" "$BLUE" "$RESET" "$1"
}

warn() {
    printf '  %b[%b!%b]%b %s\n' "$BLUE" "$YELLOW" "$BLUE" "$RESET" "$1"
}

error() {
    printf '  %b[%b-%b]%b %s\n' "$BLUE" "$RED" "$BLUE" "$RESET" "$1"
}

step() {
    printf '\n  %b[%b>%b]%b %b%s%b\n' "$BLUE" "$CYAN" "$BLUE" "$RESET" "$BOLD" "$1" "$RESET"
}

pause() {
    printf '\n  %b%s%b' "$DARK" "$(msg press_enter)" "$RESET"
    read -r
}

ask() {
    # ask "prompt" -> sets REPLY via read -rp style into global ASK_REPLY
    local prompt="$1"
    printf '  %b[%b?%b]%b %s' "$BLUE" "$RESET" "$BLUE" "$RESET" "$prompt"
    read -r ASK_REPLY
}

prompt_choice() {
    printf '\n  %b[%b?%b]%b %s: %b' "$BLUE" "$RESET" "$BLUE" "$RESET" "$(msg choice)" "$CYAN"
    read -r CHOICE
    printf '%b' "$RESET"
}

draw_menu_box() {
    local title_text="$1"
    shift
    # remaining: "num|label" pairs
    box_top
    box_line "$title_text" "$GREEN$BOLD"
    box_line "$(msg menu_hint)" "$DARK"
    box_mid
    local item num label
    for item in "$@"; do
        num="${item%%|*}"
        label="${item#*|}"
        menu_item "$num" "$label"
    done
    box_bot
}

select_language() {
    clear_screen
    print_logo
    printf '  %b[ %bv%s%b ]%b\n\n' "$GRAY" "$CYAN" "$VERSION" "$GRAY" "$RESET"

    box_top
    box_line "SELECT LANGUAGE / ВЫБОР ЯЗЫКА" "$WHITE$BOLD"
    box_line "Choose UI language / Выбери язык UI" "$DARK"
    box_mid
    box_line_left " 01. Русский" "$WHITE"
    box_line_left " 02. English" "$WHITE"
    box_bot

    local choice
    while true; do
        printf '\n  %b[%b?%b]%b Language / Язык: %b' "$BLUE" "$RESET" "$BLUE" "$RESET" "$CYAN"
        read -r choice
        printf '%b' "$RESET"
        case "$choice" in
            1|01|ru|RU|рус|Русский|русский)
                load_lang ru
                break
                ;;
            2|02|en|EN|eng|English|english)
                load_lang en
                break
                ;;
            *)
                printf '  %b[%b!%b]%b 1 = Русский, 2 = English\n' "$BLUE" "$YELLOW" "$BLUE" "$RESET"
                ;;
        esac
    done

    mkdir -p "$CONFIG_DIR" 2>/dev/null || true
    printf '%s\n' "$UI_LANG" > "$LANG_FILE" 2>/dev/null || true

    box_top 40
    if [[ "$UI_LANG" == "en" ]]; then
        box_line "Language: English" "$GREEN" 40
    else
        box_line "Язык: Русский" "$GREEN" 40
    fi
    box_bot 40
    sleep 0.6
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

resolve_target_user() {
    if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
        printf '%s\n' "$SUDO_USER"
        return
    fi

    if [[ "$(id -u)" -ne 0 ]]; then
        id -un
        return
    fi

    local owner
    owner="$(stat -c '%U' "$HOME" 2>/dev/null || true)"
    if [[ -n "$owner" && "$owner" != "root" ]]; then
        printf '%s\n' "$owner"
        return
    fi

    if getent passwd exteradere >/dev/null 2>&1; then
        printf 'exteradere\n'
        return
    fi

    getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" { print $1; exit }'
}

TARGET_USER="$(resolve_target_user)"
TARGET_UID="$(id -u "$TARGET_USER" 2>/dev/null || echo 0)"

run_user_cmd() {
    if [[ "$(id -u)" -eq 0 && "$TARGET_USER" != "root" ]]; then
        sudo -u "$TARGET_USER" \
            env HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)" \
                XDG_RUNTIME_DIR="/run/user/$TARGET_UID" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_UID/bus" \
            "$@"
    else
        "$@"
    fi
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
# Preflight (PipeWire / multilib / tutorial deps)
# Modern stack: WirePlumber — NOT obsolete pipewire-media-session from the guide.
# -----------------------------

pkg_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

multilib_enabled() {
    # Active (non-commented) [multilib] section
    awk '
        /^\[multilib\]/ { print; exit 0 }
        /^[[:space:]]*#[[:space:]]*\[multilib\]/ { next }
    ' /etc/pacman.conf 2>/dev/null | grep -q '\[multilib\]'
}

network_ok() {
    if command_exists curl; then
        curl -fsS --connect-timeout 3 -o /dev/null https://archlinux.org 2>/dev/null && return 0
    fi
    if command_exists ping; then
        ping -c1 -W2 1.1.1.1 >/dev/null 2>&1 && return 0
    fi
    return 1
}

pipewire_services_active() {
    run_user_cmd systemctl --user is-active --quiet pipewire.service 2>/dev/null \
        && run_user_cmd systemctl --user is-active --quiet wireplumber.service 2>/dev/null
}

path_has_local_bin() {
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) return 0 ;;
        *) return 1 ;;
    esac
}

pf_status_line() {
    local ok="$1"
    local label="$2"
    local yes_word="${3:-$(msg present)}"
    local no_word="${4:-$(msg missing)}"
    if [[ "$ok" == "1" ]]; then
        printf "  %b●%b %-36s %b%s%b\n" "$GREEN" "$RESET" "$label" "$GREEN" "$yes_word" "$RESET"
    else
        printf "  %b●%b %-36s %b%s%b\n" "$YELLOW" "$RESET" "$label" "$YELLOW" "$no_word" "$RESET"
    fi
}

enable_multilib() {
    step "$(msg pf_multilib)"

    if multilib_enabled; then
        success "$(msg pf_multilib_ok)"
        return 0
    fi

    ask "$(msg pf_enable_multilib)"
    if [[ "${ASK_REPLY:-Y}" =~ ^[Nn]$ ]]; then
        warn "$(msg preflight_skip)"
        return 1
    fi

    if ! command_exists sudo; then
        error "$(msg pf_multilib_fail)"
        return 1
    fi

    # Uncomment [multilib] block Include line (Arch default pacman.conf layout)
    if ! sudo sed -i '/^#\[multilib\]/,/^$/{s/^#//}' /etc/pacman.conf; then
        error "$(msg pf_multilib_fail)"
        return 1
    fi

    if ! multilib_enabled; then
        error "$(msg pf_multilib_fail)"
        return 1
    fi

    sudo pacman -Sy --noconfirm || true
    success "$(msg pf_multilib_ok)"
}

ensure_local_bin_path() {
    if path_has_local_bin; then
        return 0
    fi

    ask "$(msg pf_path_fix)"
    if [[ "${ASK_REPLY:-Y}" =~ ^[Nn]$ ]]; then
        return 0
    fi

    local rc="$HOME/.bashrc"
    local line='export PATH="$HOME/.local/bin:$PATH"'
    touch "$rc"
    if ! grep -Fq '.local/bin' "$rc" 2>/dev/null; then
        printf '\n# osu-stable-arch\n%s\n' "$line" >> "$rc"
    fi
    export PATH="$HOME/.local/bin:$PATH"
    success "$(msg pf_path_added)"
}

enable_pipewire_user_services() {
    ask "$(msg pf_enable_pw)"
    if [[ "${ASK_REPLY:-Y}" =~ ^[Nn]$ ]]; then
        return 0
    fi

    run_user_cmd systemctl --user enable --now \
        pipewire.service pipewire.socket \
        wireplumber.service \
        pipewire-pulse.service pipewire-pulse.socket 2>/dev/null || true

    success "$(msg pf_pw_started)"
}

# Fills global arrays PF_MISSING_PKGS and sets PF_NEED_*
preflight_scan() {
    PF_MISSING_PKGS=()
    PF_OK_SUDO=0
    PF_OK_NET=0
    PF_OK_MULTILIB=0
    PF_OK_PW=0
    PF_OK_WP=0
    PF_OK_PULSE=0
    PF_OK_ALSA=0
    PF_OK_RT=0
    PF_OK_WINE=0
    PF_OK_WT=0
    PF_OK_GIT=0
    PF_OK_PATH=0
    PF_OK_DISPLAY=0
    PF_OK_PW_RUN=0
    PF_OK_NVIDIA32=1  # ok unless nvidia without lib

    command_exists sudo && PF_OK_SUDO=1
    network_ok && PF_OK_NET=1
    multilib_enabled && PF_OK_MULTILIB=1
    pkg_installed pipewire && PF_OK_PW=1
    pkg_installed wireplumber && PF_OK_WP=1
    pkg_installed pipewire-pulse && PF_OK_PULSE=1
    pkg_installed pipewire-alsa && PF_OK_ALSA=1
    pkg_installed realtime-privileges && PF_OK_RT=1
    pkg_installed wine && PF_OK_WINE=1
    pkg_installed winetricks && PF_OK_WT=1
    pkg_installed git && PF_OK_GIT=1
    path_has_local_bin && PF_OK_PATH=1
    { [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; } && PF_OK_DISPLAY=1
    pipewire_services_active && PF_OK_PW_RUN=1

    [[ "$PF_OK_PW" -eq 0 ]] && PF_MISSING_PKGS+=(pipewire pipewire-audio)
    [[ "$PF_OK_WP" -eq 0 ]] && PF_MISSING_PKGS+=(wireplumber)
    [[ "$PF_OK_PULSE" -eq 0 ]] && PF_MISSING_PKGS+=(pipewire-pulse)
    [[ "$PF_OK_ALSA" -eq 0 ]] && PF_MISSING_PKGS+=(pipewire-alsa)
    [[ "$PF_OK_RT" -eq 0 ]] && PF_MISSING_PKGS+=(realtime-privileges)
    [[ "$PF_OK_WINE" -eq 0 ]] && PF_MISSING_PKGS+=(wine)
    [[ "$PF_OK_WT" -eq 0 ]] && PF_MISSING_PKGS+=(winetricks)
    [[ "$PF_OK_GIT" -eq 0 ]] && PF_MISSING_PKGS+=(git)

    # lib32-pipewire helps Wine/pulse clients
    if ! pkg_installed lib32-pipewire; then
        PF_MISSING_PKGS+=(lib32-pipewire)
    fi

    detect_gpu
    if [[ "${GPU:-}" == "nvidia" ]]; then
        if ! pkg_installed lib32-nvidia-utils; then
            PF_OK_NVIDIA32=0
            PF_MISSING_PKGS+=(lib32-nvidia-utils)
        fi
    fi

    # Unique
    if ((${#PF_MISSING_PKGS[@]})); then
        mapfile -t PF_MISSING_PKGS < <(printf '%s\n' "${PF_MISSING_PKGS[@]}" | awk 'NF && !seen[$0]++')
    fi
}

preflight_report() {
    title
    printf "  %b%s%b\n\n" "$BOLD" "$(msg preflight_title)" "$RESET"

    pf_status_line "$PF_OK_SUDO" "$(msg pf_sudo)" "$(msg yes)" "$(msg no)"
    pf_status_line "$PF_OK_NET" "$(msg pf_network)" "$(msg yes)" "$(msg no)"
    pf_status_line "$PF_OK_MULTILIB" "$(msg pf_multilib)" "$(msg yes)" "$(msg no)"
    pf_status_line "$PF_OK_DISPLAY" "$(msg pf_display)" "$(msg yes)" "$(msg no)"
    pf_status_line "$PF_OK_PW" "$(msg pf_pipewire)"
    pf_status_line "$PF_OK_WP" "$(msg pf_wireplumber)"
    pf_status_line "$PF_OK_PULSE" "$(msg pf_pw_pulse)"
    pf_status_line "$PF_OK_ALSA" "$(msg pf_pw_alsa)"
    pf_status_line "$PF_OK_RT" "$(msg pf_realtime)"
    pf_status_line "$PF_OK_WINE" "$(msg pf_wine)"
    pf_status_line "$PF_OK_WT" "$(msg pf_winetricks)"
    pf_status_line "$PF_OK_GIT" "$(msg pf_git)"
    pf_status_line "$PF_OK_PATH" "$(msg pf_path)" "$(msg yes)" "$(msg no)"
    pf_status_line "$PF_OK_PW_RUN" "$(msg pf_running)" "$(msg yes)" "$(msg no)"
    if [[ "${GPU:-}" == "nvidia" ]]; then
        pf_status_line "$PF_OK_NVIDIA32" "lib32-nvidia-utils"
    fi

    printf "\n"
    info "$(msg pf_note_wp)"
    info "$(msg pf_note_gpu)"

    if ((${#PF_MISSING_PKGS[@]})); then
        printf "\n"
        warn "$(msg preflight_issues)"
        printf "  %b%s%b\n" "$DIM" "${PF_MISSING_PKGS[*]}" "$RESET"
        return 1
    fi

    if [[ "$PF_OK_MULTILIB" -eq 0 || "$PF_OK_SUDO" -eq 0 || "$PF_OK_NET" -eq 0 ]]; then
        printf "\n"
        warn "$(msg preflight_issues)"
        return 1
    fi

    printf "\n"
    success "$(msg preflight_ok)"
    return 0
}

install_missing_system_packages() {
    step "$(msg preflight_installing)"

    if [[ "$PF_OK_MULTILIB" -eq 0 ]]; then
        enable_multilib || return 1
        PF_OK_MULTILIB=1
    fi

    if ((${#PF_MISSING_PKGS[@]} == 0)); then
        success "$(msg preflight_done)"
        return 0
    fi

    if ! sudo pacman -S --needed --noconfirm "${PF_MISSING_PKGS[@]}"; then
        error "$(msg preflight_fail)"
        return 1
    fi

    success "$(msg preflight_done)"
}

preflight_and_fix() {
    preflight_scan
    local scan_rc=0
    preflight_report || scan_rc=$?

    local need_action=0
    ((${#PF_MISSING_PKGS[@]})) && need_action=1
    [[ "$PF_OK_MULTILIB" -eq 0 ]] && need_action=1
    [[ "$PF_OK_PATH" -eq 0 ]] && need_action=1
    [[ "$PF_OK_PW_RUN" -eq 0 && "$PF_OK_PW" -eq 1 ]] && need_action=1

    # If packages missing after report returned issues
    if [[ "$need_action" -eq 1 ]] || [[ "$scan_rc" -ne 0 ]]; then
        printf "\n"
        if ((${#PF_MISSING_PKGS[@]})) || [[ "$PF_OK_MULTILIB" -eq 0 ]]; then
            ask "$(msg preflight_offer)"
            if [[ "${ASK_REPLY:-Y}" =~ ^[Nn]$ ]]; then
                warn "$(msg preflight_skip)"
            else
                install_missing_system_packages || return 1
                # refresh scan after install
                preflight_scan
            fi
        fi

        if [[ "$PF_OK_PATH" -eq 0 ]]; then
            ensure_local_bin_path
            path_has_local_bin && PF_OK_PATH=1
        fi

        # After packages present, offer to start PW
        if pkg_installed pipewire && pkg_installed wireplumber; then
            if ! pipewire_services_active; then
                enable_pipewire_user_services
            fi
        fi
    fi

    return 0
}

# -----------------------------
# Dependencies
# -----------------------------

install_dependencies() {
    step "$(msg dep_step)"

    local pkgs=(
        giflib
        lib32-giflib
        libpng
        lib32-libpng
        libldap
        lib32-libldap
        gnutls
        lib32-gnutls
        mpg123
        lib32-mpg123
        openal
        lib32-openal
        v4l-utils
        lib32-v4l-utils
        libpulse
        lib32-libpulse
        libgpg-error
        lib32-libgpg-error
        alsa-plugins
        lib32-alsa-plugins
        alsa-lib
        lib32-alsa-lib
        libjpeg-turbo
        lib32-libjpeg-turbo
        sqlite
        lib32-sqlite
        libxcomposite
        lib32-libxcomposite
        libxinerama
        lib32-libxinerama
        libgcrypt
        lib32-libgcrypt
        ncurses
        lib32-ncurses
        opencl-icd-loader
        lib32-opencl-icd-loader
        libxslt
        lib32-libxslt
        libva
        lib32-libva
        gtk3
        lib32-gtk3
        gst-plugins-base-libs
        lib32-gst-plugins-base-libs
        vulkan-icd-loader
        lib32-vulkan-icd-loader
        wine
        winetricks
        wget
        curl
        unzip
        p7zip
        xdg-utils
        desktop-file-utils
        git
        # Audio stack expected by the Arch+osu guide (modern session manager)
        pipewire
        pipewire-audio
        pipewire-pulse
        pipewire-alsa
        wireplumber
        lib32-pipewire
        realtime-privileges
    )

    detect_gpu
    if [[ "${GPU:-}" == "nvidia" ]]; then
        pkgs+=(lib32-nvidia-utils)
    fi

    if ! sudo pacman -S --needed --noconfirm "${pkgs[@]}"; then
        error "$(msg preflight_fail)"
        return 1
    fi

    success "$(msg dep_ok)"
}

# -----------------------------
# Custom Wine
# -----------------------------

install_custom_wine() {
    step "$(msg wine_check)"

    if [[ -x "$WINE" ]]; then
        success "$(msg wine_custom_ok)"
        "$WINE" --version || true
        return 0
    fi

    mkdir -p "$HOME/Downloads"

    info "$(msg wine_dl)"
    info "$(msgf wine_src "$WINE_URL")"

    if ! wget -O "$WINE_ARCHIVE" "$WINE_URL"; then
        warn "$(msg wine_dl_fail)"
        warn "$(msg wine_sys_fallback)"

        if command_exists wine; then
            WINE="$(command -v wine)"
            WINE_DIR=""
            success "$(msgf wine_sys_ok "$WINE")"
            return 0
        fi

        error "$(msg wine_missing)"
        return 1
    fi

    rm -rf "$HOME/wine-osu"
    mkdir -p "$HOME/wine-osu"

    if ! tar -xf "$WINE_ARCHIVE" -C "$HOME"; then
        error "$(msg wine_unpack_fail)"
        return 1
    fi

    # Архив обычно содержит wine-osu/
    if [[ -d "$HOME/wine-osu" ]]; then
        success "$(msg wine_installed)"
    else
        error "$(msg wine_dir_missing)"
        return 1
    fi

    chmod +x "$HOME/wine-osu/bin/"* 2>/dev/null || true

    if [[ -x "$WINE" ]]; then
        "$WINE" --version || true
        success "$(msg wine_ready)"
    else
        error "$(msgf wine_bin_missing "$WINE")"
        return 1
    fi
}

# -----------------------------
# osu! download
# -----------------------------

download_osu() {
    step "$(msg osu_step)"

    mkdir -p "$OSU_DIR"

    if [[ -f "$OSU_EXE" ]]; then
        success "$(msg osu_exists)"
        return 0
    fi

    info "$(msg osu_dl)"

    if ! wget \
        --show-progress \
        --output-document="$OSU_EXE" \
        "$OSU_URL"; then

        error "$(msg osu_dl_fail)"
        rm -f "$OSU_EXE"
        return 1
    fi

    success "$(msg osu_ok)"
}

# -----------------------------
# Wine prefix
# -----------------------------

setup_prefix() {
    step "$(msg prefix_step)"

    export WINEARCH=win32
    export WINEPREFIX="$PREFIX"

    if [[ ! -d "$PREFIX" ]]; then
        info "$(msg prefix_create)"
        "$WINE" wineboot -u >/dev/null 2>&1 || true
    else
        info "$(msg prefix_exists)"
    fi

    info "$(msg prefix_win)"
    info "$(msg prefix_mono)"

    "$WINE" wineboot -u >/dev/null 2>&1 || true

    WINEPREFIX="$PREFIX" \
    WINEARCH=win32 \
    winetricks -q dotnet45 cjkfonts gdiplus

    success "$(msg prefix_ok)"
}

# -----------------------------
# Low-latency audio (modern PipeWire)
# Safe drop-ins only — no PulseAudio daemon.conf, no full config overwrite.
# -----------------------------

current_audio_preset() {
    if [[ -f "$AUDIO_STATE" ]]; then
        tr -d '[:space:]' < "$AUDIO_STATE"
    else
        printf 'default\n'
    fi
}

write_audio_env() {
    local period="$1"
    local duration="$2"
    local preset="$3"

    mkdir -p "$CONFIG_DIR"

    cat > "$AUDIO_ENV" <<EOF
# Managed by osu-install.sh — do not edit by hand unless you know what you're doing.
# Preset: $preset
export STAGING_AUDIO_PERIOD=$period
export STAGING_AUDIO_DURATION=$duration
EOF

    printf '%s\n' "$preset" > "$AUDIO_STATE"
}

ensure_default_audio_env() {
    if [[ ! -f "$AUDIO_ENV" ]]; then
        # Stock Wine-osu values from the original tutorial
        write_audio_env 13333 13333 default
    fi
}

backup_audio_configs() {
    mkdir -p "$AUDIO_BACKUP_DIR"

    local stamp
    stamp="$(date +%Y%m%d-%H%M%S)"

    local bak="$AUDIO_BACKUP_DIR/$stamp"
    mkdir -p "$bak"

    [[ -f "$PW_DROPIN" ]] && cp -a "$PW_DROPIN" "$bak/"
    [[ -f "$PW_PULSE_DROPIN" ]] && cp -a "$PW_PULSE_DROPIN" "$bak/"
    [[ -f "$AUDIO_ENV" ]] && cp -a "$AUDIO_ENV" "$bak/"
    [[ -f "$AUDIO_STATE" ]] && cp -a "$AUDIO_STATE" "$bak/"

    # Keep a "latest" pointer for one-shot restore
    rm -rf "$AUDIO_BACKUP_DIR/latest"
    cp -a "$bak" "$AUDIO_BACKUP_DIR/latest"

    success "$(msgf backup_ok "$bak")"
}

install_realtime_privileges() {
    step "$(msg rt_step)"

    if ! pacman -Q realtime-privileges >/dev/null 2>&1; then
        info "$(msg rt_install)"
        sudo pacman -S --needed --noconfirm realtime-privileges || {
            error "$(msg rt_install_fail)"
            return 1
        }
    else
        success "$(msg rt_pkg_ok)"
    fi

    if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx realtime; then
        success "$(msgf rt_in "$TARGET_USER")"
    else
        info "$(msgf rt_add "$TARGET_USER")"
        sudo usermod -aG realtime "$TARGET_USER"
        success "$(msg rt_added)"
        warn "$(msg rt_relogin)"
    fi

    if getent group audio >/dev/null 2>&1; then
        if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx audio; then
            success "$(msgf audio_in "$TARGET_USER")"
        else
            info "$(msgf audio_add "$TARGET_USER")"
            sudo usermod -aG audio "$TARGET_USER"
            success "$(msg audio_added)"
        fi
    fi

    # Do NOT write nice -20 into limits.conf — realtime-privileges already
    # ships a safe drop-in (@realtime rtprio 98, nice -11, memlock unlimited).
}

write_pipewire_dropins() {
    local quantum="$1"
    local min_quantum="$2"
    local max_quantum="$3"
    local pulse_min="$4"

    mkdir -p "$PW_CONF_D" "$PW_PULSE_D"

    cat > "$PW_DROPIN" <<EOF
# Managed by osu-install.sh (osu! low-latency preset)
# Drop-in only — system defaults in /usr/share/pipewire stay untouched.
context.properties = {
    default.clock.rate          = 48000
    default.clock.allowed-rates = [ 48000 ]
    default.clock.quantum       = $quantum
    default.clock.min-quantum   = $min_quantum
    default.clock.max-quantum   = $max_quantum
}
EOF

    cat > "$PW_PULSE_DROPIN" <<EOF
# Managed by osu-install.sh (osu! low-latency preset)
pulse.properties = {
    pulse.min.req          = $pulse_min/48000
    pulse.default.req      = $pulse_min/48000
    pulse.min.quantum      = $pulse_min/48000
    pulse.default.quantum  = $pulse_min/48000
}
EOF

    success "$(msgf pw_written "$quantum")"
}

remove_pipewire_dropins() {
    rm -f "$PW_DROPIN" "$PW_PULSE_DROPIN"
}

restart_pipewire_stack() {
    step "$(msg pw_restart)"

    if ! run_user_cmd systemctl --user restart \
        pipewire.service pipewire.socket \
        wireplumber.service \
        pipewire-pulse.service pipewire-pulse.socket 2>/dev/null; then
        warn "$(msg pw_restart_fail)"
        warn "$(msg pw_restart_hint)"
        warn "  systemctl --user restart pipewire pipewire-pulse wireplumber"
        return 1
    fi

    success "$(msg pw_restart_ok)"
}

apply_audio_preset() {
    local preset="$1"

    local quantum min_q max_q pulse_min period duration

    case "$preset" in
        safe)
            # ~5.3 ms quantum — стабильно почти везде
            quantum=256; min_q=64; max_q=1024; pulse_min=256
            period=20000; duration=40000
            ;;
        balanced)
            # ~2.7 ms — хороший дефолт под osu!
            quantum=128; min_q=32; max_q=512; pulse_min=128
            period=13333; duration=26666
            ;;
        low)
            # ~1.3 ms — соревновательный
            quantum=64; min_q=32; max_q=512; pulse_min=64
            period=6666; duration=13333
            ;;
        ultra)
            # ~0.67 ms — только если CPU/диск тянут без crackle
            quantum=32; min_q=16; max_q=256; pulse_min=32
            period=3333; duration=6666
            ;;
        *)
            error "$(msgf preset_unknown "$preset")"
            return 1
            ;;
    esac

    step "$(msgf preset_step "$preset")"

    printf "\n"
    printf "  ${DIM}PipeWire quantum${RESET}  %s (min %s, max %s)\n" "$quantum" "$min_q" "$max_q"
    printf "  ${DIM}pulse.min.*${RESET}       %s/48000\n" "$pulse_min"
    printf "  ${DIM}STAGING period${RESET}    %s µs\n" "$period"
    printf "  ${DIM}STAGING duration${RESET}  %s µs  (= period × 2)\n" "$duration"
    printf "\n"

    ask "$(msgf apply_preset "$preset")"
    if [[ "${ASK_REPLY:-Y}" =~ ^[Nn]$ ]]; then
        info "$(msg cancel)"
        return
    fi

    backup_audio_configs
    install_realtime_privileges || return 1
    write_pipewire_dropins "$quantum" "$min_q" "$max_q" "$pulse_min"
    write_audio_env "$period" "$duration" "$preset"

    # Keep launchers in sync if they still hardcode STAGING_*
    if [[ -x "$OSU_LAUNCHER" ]]; then
        detect_gpu
        create_launcher
        create_file_handler
    fi

    restart_pipewire_stack || true

    printf "\n"
    success "$(msgf preset_ok "$preset")"
    info "$(msg preset_compat)"
    info "$(msg preset_pwtop)"
    warn "$(msg preset_crackle)"
}

restore_audio_defaults() {
    step "$(msg restore_step)"

    printf "\n"
    info "$(msg restore_info1)"
    info "$(msg restore_info2)"
    printf "    %s\n\n" "$AUDIO_BACKUP_DIR"

    ask "$(msg restore_ask)"
    if [[ "${ASK_REPLY:-Y}" =~ ^[Nn]$ ]]; then
        info "$(msg cancel)"
        return
    fi

    backup_audio_configs
    remove_pipewire_dropins
    write_audio_env 13333 13333 default

    if [[ -x "$OSU_LAUNCHER" ]]; then
        detect_gpu
        create_launcher
        create_file_handler
    fi

    restart_pipewire_stack || true

    success "$(msg restore_ok)"
}

audio_status() {
    title

    printf "  %b%s%b\n\n" "$BOLD" "$(msg audio_status_title)" "$RESET"

    local preset
    preset="$(current_audio_preset)"
    printf "  %s: %b%s%b\n\n" "$(msg preset_label)" "$CYAN" "$preset" "$RESET"

    if [[ -f "$PW_DROPIN" ]]; then
        printf "  %b●%b %-22s %s\n" "$GREEN" "$RESET" "$(msg pw_dropin)" "$(msg yes)"
        printf "      %s\n" "$PW_DROPIN"
    else
        printf "  %b●%b %-22s %s\n" "$DARK" "$RESET" "$(msg pw_dropin)" "$(msg sys_default)"
    fi

    if [[ -f "$PW_PULSE_DROPIN" ]]; then
        printf "  %b●%b %-22s %s\n" "$GREEN" "$RESET" "$(msg pw_pulse)" "$(msg yes)"
        printf "      %s\n" "$PW_PULSE_DROPIN"
    else
        printf "  %b●%b %-22s %s\n" "$DARK" "$RESET" "$(msg pw_pulse)" "$(msg no)"
    fi

    if [[ -f "$AUDIO_ENV" ]]; then
        printf "  %b●%b audio.env\n" "$GREEN" "$RESET"
        # shellcheck disable=SC1090
        source "$AUDIO_ENV"
        printf "      STAGING_AUDIO_PERIOD=%s\n" "${STAGING_AUDIO_PERIOD:-?}"
        printf "      STAGING_AUDIO_DURATION=%s\n" "${STAGING_AUDIO_DURATION:-?}"
    else
        printf "  %b●%b audio.env            %s\n" "$DARK" "$RESET" "$(msg no)"
    fi

    printf "\n"
    if id -nG "$TARGET_USER" 2>/dev/null | tr ' ' '\n' | grep -qx realtime; then
        printf "  %b●%b %-22s %s (%s)\n" "$GREEN" "$RESET" "$(msg group_rt)" "$(msg yes)" "$TARGET_USER"
    else
        printf "  %b●%b %-22s %s (%s)\n" "$YELLOW" "$RESET" "$(msg group_rt)" "$(msg no)" "$TARGET_USER"
    fi

    if id -nG "$TARGET_USER" 2>/dev/null | tr ' ' '\n' | grep -qx audio; then
        printf "  %b●%b %-22s %s\n" "$GREEN" "$RESET" "$(msg group_audio)" "$(msg yes)"
    else
        printf "  %b●%b %-22s %s\n" "$DARK" "$RESET" "$(msg group_audio)" "$(msg no)"
    fi

    if pacman -Q realtime-privileges >/dev/null 2>&1; then
        printf "  %b●%b %-22s %s\n" "$GREEN" "$RESET" "$(msg rt_pkg)" "$(msg installed)"
    else
        printf "  %b●%b %-22s %s\n" "$YELLOW" "$RESET" "$(msg rt_pkg)" "$(msg missing)"
    fi

    printf "\n"
    printf "  %b%s%b\n" "$DIM" "$(msg modern_path)" "$RESET"
    printf "  %b%s%b\n" "$DIM" "$(msg dont_touch)" "$RESET"

    pause
}


tune_staging_manual() {
    title

    printf "  %b%s%b\n\n" "$BOLD" "$(msg staging_title)" "$RESET"
    printf "  %s\n" "$(msg staging_help1)"
    printf "  %s\n\n" "$(msg staging_help2)"
    printf "  %s\n\n" "$(msg staging_help3)"

    local period
    ask "STAGING_AUDIO_PERIOD: "
    period="$ASK_REPLY"

    if ! [[ "$period" =~ ^[0-9]+$ ]] || [[ "$period" -lt 1000 || "$period" -gt 100000 ]]; then
        error "$(msg staging_bad)"
        pause
        return
    fi

    local duration=$((period * 2))
    printf "  STAGING_AUDIO_DURATION → %s\n\n" "$duration"

    ask "$(msg staging_write)"
    if [[ "${ASK_REPLY:-Y}" =~ ^[Nn]$ ]]; then
        info "$(msg cancel)"
        pause
        return
    fi

    backup_audio_configs
    write_audio_env "$period" "$duration" "custom-$period"

    if [[ -x "$OSU_LAUNCHER" ]]; then
        detect_gpu
        create_launcher
        create_file_handler
    fi

    success "$(msg staging_ok)"
    pause
}


audio_menu() {
    while true; do
        detect_gpu
        title

        local preset
        preset="$(current_audio_preset)"

        draw_menu_box "$(msg audio_menu_title)" \
            "1|$(msg a1)" \
            "2|$(msg a2)" \
            "3|$(msg a3)" \
            "4|$(msg a4)" \
            "5|$(msg a5)" \
            "6|$(msg a6)" \
            "7|$(msg a7)" \
            "8|$(msg a8)" \
            "9|$(msg a9)" \
            "0|$(msg back)"

        printf "\n  %b%s:%b %b%s%b\n" "$DIM" "$(msg cur_preset)" "$RESET" "$CYAN" "$preset" "$RESET"
        prompt_choice

        case "$CHOICE" in
            1) apply_audio_preset safe; pause ;;
            2) apply_audio_preset balanced; pause ;;
            3) apply_audio_preset low; pause ;;
            4) apply_audio_preset ultra; pause ;;
            5) tune_staging_manual ;;
            6) install_realtime_privileges; pause ;;
            7) audio_status ;;
            8) restore_audio_defaults; pause ;;
            9) restart_pipewire_stack; pause ;;
            0) return ;;
            *)
                warn "$(msg unknown_item)"
                sleep 1
                ;;
        esac
    done
}


# -----------------------------
# Launcher
# -----------------------------

create_launcher() {
    step "$(msg launcher_step)"

    mkdir -p "$BIN_DIR"
    ensure_default_audio_env

    cat > "$OSU_LAUNCHER" <<EOF
#!/usr/bin/env bash

export WINEARCH=win32
export WINEPREFIX="\$HOME/.wineosu"
export WINEFSYNC=1
export WINE_DISABLE_VK_CHILD_WINDOW_RENDERING_HACK=1

# Low-latency Wine audio (managed by osu-install.sh audio menu)
if [[ -f "\$HOME/.config/osu-stable-arch/audio.env" ]]; then
    # shellcheck disable=SC1091
    source "\$HOME/.config/osu-stable-arch/audio.env"
else
    export STAGING_AUDIO_DURATION=13333
    export STAGING_AUDIO_PERIOD=13333
fi

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

    success "$(msg launcher_ok)"
}

# -----------------------------
# Killer
# -----------------------------

create_killer() {
    step "$(msg killer_step)"

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

    success "$(msg killer_ok)"
}

# -----------------------------
# File handler
# -----------------------------

create_file_handler() {
    step "$(msg handler_step)"

    ensure_default_audio_env

    cat > "$OSU_HANDLER" <<EOF
#!/usr/bin/env bash

export WINEARCH=win32
export WINEPREFIX="\$HOME/.wineosu"
export WINEFSYNC=1
export WINE_DISABLE_VK_CHILD_WINDOW_RENDERING_HACK=1

if [[ -f "\$HOME/.config/osu-stable-arch/audio.env" ]]; then
    # shellcheck disable=SC1091
    source "\$HOME/.config/osu-stable-arch/audio.env"
else
    export STAGING_AUDIO_DURATION=13333
    export STAGING_AUDIO_PERIOD=13333
fi

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

    success "$(msg handler_ok)"
}

# -----------------------------
# Desktop entries
# -----------------------------

create_desktop_entries() {
    step "$(msg desktop_step)"

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

    success "$(msg desktop_ok)"
}

# -----------------------------
# MIME handlers
# -----------------------------

setup_handlers() {
    step "$(msg mime_step)"

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

    success "$(msg mime_ok)"
    success "$(msg mime_url_ok)"
}

# -----------------------------
# Full install
# -----------------------------

full_install() {
    title

    box_top
    box_line "$(msg full_install_title)" "$WHITE$BOLD"
    box_mid
    box_line_left "osu!    $OSU_EXE" "$DIM"
    box_line_left "Prefix  $PREFIX" "$DIM"
    box_line_left "Wine    $WINE" "$DIM"

    detect_gpu
    box_line_left "GPU     $GPU" "$DIM"
    box_bot

    printf "\n"
    ask "$(msg yes_no_install)"

    if [[ "$ASK_REPLY" =~ ^[Nn]$ ]]; then
        return
    fi

    preflight_and_offer || true

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

    box_top
    box_line "$(msg installed_banner)" "$GREEN$BOLD"
    box_bot
    printf "\n"
    printf "  %b%s:%b\n    osu\n\n" "$CYAN" "$(msg launch)" "$RESET"
    printf "  %b%s:%b\n    osukill\n\n" "$CYAN" "$(msg force_close)" "$RESET"
    printf "  %b%s:%b\n    %s\n\n" "$CYAN" "$(msg game)" "$RESET" "$OSU_EXE"
    printf "  %bWine prefix:%b\n    %s\n\n" "$CYAN" "$RESET" "$PREFIX"
    printf "  %bGPU:%b %s\n\n" "$CYAN" "$RESET" "$GPU"
    printf "  %bLow-latency audio:%b\n    %s\n\n" "$CYAN" "$RESET" "$(msg audio_menu_hint)"
    printf "  %b.osz / .osk / .osr / .osu / .osb → osu!\n  osu:// → osu!%b\n" "$DIM" "$RESET"

    pause
}


# -----------------------------
# Launch
# -----------------------------

launch_osu() {
    if [[ ! -x "$OSU_LAUNCHER" ]]; then
        error "$(msg not_installed)"
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
        success "$(msg wine_stopped)"
    else
        wineserver -k 2>/dev/null || true
        success "$(msg wine_stopped)"
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
    success "$(msg handlers_ok)"

    printf "\n"
    printf "  %s:\n\n" "$(msg check)"

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

    printf "  %b%s%b\n\n" "$BOLD" "$(msg status_title)" "$RESET"

    if [[ -f "$OSU_EXE" ]]; then
        printf "  %b●%b osu!.exe         %s\n" "$GREEN" "$RESET" "$(msg present)"
    else
        printf "  %b●%b osu!.exe         %s\n" "$RED" "$RESET" "$(msg missing)"
    fi

    if [[ -d "$PREFIX" ]]; then
        printf "  %b●%b Wine prefix       %s\n" "$GREEN" "$RESET" "$(msg exists)"
    else
        printf "  %b●%b Wine prefix       %s\n" "$RED" "$RESET" "$(msg absent)"
    fi

    if [[ -x "$WINE" ]]; then
        printf "  %b●%b Custom Wine       %s\n" "$GREEN" "$RESET" "$(msg present)"
    else
        printf "  %b●%b Custom Wine       %s\n" "$YELLOW" "$RESET" "$(msg missing)"
    fi

    if [[ -x "$OSU_LAUNCHER" ]]; then
        printf "  %b●%b osu launcher      %s\n" "$GREEN" "$RESET" "$(msg present)"
    else
        printf "  %b●%b osu launcher      %s\n" "$RED" "$RESET" "$(msg missing)"
    fi

    printf "\n"
    printf "  GPU: %b%s%b\n" "$CYAN" "$GPU" "$RESET"

    local ap
    ap="$(current_audio_preset)"
    printf "  Audio preset: %b%s%b\n" "$CYAN" "$ap" "$RESET"

    printf "\n"
    printf "  osu! path:\n"
    printf "    %s\n" "$OSU_EXE"

    printf "\n"
    printf "  Wine prefix:\n"
    printf "    %s\n" "$PREFIX"

    pause
}


# -----------------------------
# Uninstall
# -----------------------------

uninstall() {
    title

    printf "  %b%s%b\n\n" "$RED$BOLD" "$(msg uninstall_title)" "$RESET"

    printf "  %s\n\n" "$(msg will_remove)"
    printf "    %s\n" "$OSU_DIR"
    printf "    %s\n" "$PREFIX"
    printf "    %s\n" "$WINE_DIR"
    printf "    %s\n" "$OSU_LAUNCHER"
    printf "    %s\n" "$OSU_KILLER"
    printf "    %s\n" "$OSU_HANDLER"
    printf "    %s\n" "$DESKTOP_MAIN"
    printf "    %s\n" "$DESKTOP_FILE"
    printf "    %s\n\n" "$DESKTOP_URL"

    printf "  %b%s%b\n\n" "$DIM" "$(msg audio_also)" "$RESET"

    warn "$(msg warn_beatmaps)"

    ask "$(msg type_delete)"

    if [[ "$ASK_REPLY" != "DELETE" ]]; then
        info "$(msg cancel)"
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

    ask "$(msg remove_audio)"
    if [[ "$ASK_REPLY" =~ ^[Yy]$ ]]; then
        remove_pipewire_dropins
        rm -rf "$CONFIG_DIR"
        restart_pipewire_stack || true
        success "$(msg audio_removed)"
    fi

    if command_exists update-desktop-database; then
        update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
    fi

    success "$(msg uninstalled)"

    pause
}

# -----------------------------
# Menu
# -----------------------------

menu() {
    while true; do
        detect_gpu
        title

        draw_menu_box "$(msg menu_title)" \
            "1|$(msg m1)" \
            "2|$(msg m2)" \
            "3|$(msg m3)" \
            "4|$(msg m4)" \
            "5|$(msg m5)" \
            "6|$(msg m6)" \
            "7|$(msg m7)" \
            "8|$(msg m8)" \
            "0|$(msg exit)"

        prompt_choice

        case "$CHOICE" in
            1) full_install ;;
            2) launch_osu ;;
            3) kill_osu ;;
            4) repair_handlers ;;
            5) status ;;
            6) uninstall ;;
            7) audio_menu ;;
            8) preflight_and_offer; pause ;;
            0)
                clear_screen
                box_top 40
                box_line "$(msg shutdown)" "$CYAN" 40
                box_bot 40
                printf "\n"
                exit 0
                ;;
            *)
                warn "$(msg unknown_item)"
                sleep 1
                ;;
        esac
    done
}


# -----------------------------
# Main
# -----------------------------

ensure_lang() {
    if [[ -n "${UI_LANG:-}" ]]; then
        load_lang "$UI_LANG"
        return
    fi
    if [[ -f "$LANG_FILE" ]]; then
        load_lang "$(tr -d '[:space:]' < "$LANG_FILE")"
    else
        load_lang ru
    fi
}

if [[ "${1:-}" == "--install" ]]; then
    ensure_lang
    full_install
    exit $?
fi

if [[ "${1:-}" == "--status" ]]; then
    ensure_lang
    status
    exit $?
fi

if [[ "${1:-}" == "--repair" ]]; then
    ensure_lang
    repair_handlers
    exit $?
fi

if [[ "${1:-}" == "--kill" ]]; then
    ensure_lang
    kill_osu
    exit $?
fi

if [[ "${1:-}" == "--audio" ]]; then
    ensure_lang
    audio_menu
    exit $?
fi

if [[ "${1:-}" == "--audio-preset" ]]; then
    ensure_lang
    apply_audio_preset "${2:-balanced}"
    exit $?
fi

if [[ "${1:-}" == "--audio-restore" ]]; then
    ensure_lang
    restore_audio_defaults
    exit $?
fi

if [[ "${1:-}" == "--preflight" ]]; then
    ensure_lang
    detect_gpu
    preflight_and_offer
    exit $?
fi

select_language
detect_gpu

# Before menu: check PipeWire / multilib / deps and offer to install if missing
preflight_scan
if ((${#PF_MISSING_PKGS[@]})) || [[ "$PF_OK_MULTILIB" -eq 0 ]] || [[ "$PF_OK_PW" -eq 0 ]] || [[ "$PF_OK_WP" -eq 0 ]]; then
    preflight_and_offer
    pause
fi

menu
