# osu! Stable — Arch Linux Инсталлятор

<p align="center">
  <img src="https://img.shields.io/badge/ОС-Arch%20Linux-blue?logo=arch-linux&style=for-the-badge" alt="Arch Linux" />
  <img src="https://img.shields.io/badge/Wine-osu!%20Stable-maroon?logo=wine&style=for-the-badge" alt="Wine osu" />
  <img src="https://img.shields.io/badge/Аудио-PipeWire%20Low--Latency-brightgreen?logo=pipewire&style=for-the-badge" alt="PipeWire" />
  <img src="https://img.shields.io/badge/Скрипт-Bash-4EAA25?logo=gnu-bash&style=for-the-badge" alt="Bash" />
</p>

Автоматизированный менеджер установки и оптимизатор производительности **osu! Stable** под **Arch Linux** на базе Wine.

[English Version](README.md) | **Русская версия**

<details>
<summary><b>Читать на русском / Read in Russian</b></summary>

Полная документация на русском языке доступна в файле [README.ru.md](README.ru.md).

</details>

---

## Зачем этот проект?

Я так и не нашёл действительно удобного инсталлятора osu! под Arch Linux, который работал бы из коробки без постоянных костылей и сам решал все возможные проблемы с зависимостями, звуком и Wine — поэтому решил сделать свой.

---

## Возможности

- **Автоматическая установка**: Скачивает оптимизированную сборку Wine, создает 32-битный префикс Wine с необходимым `.NET Framework 4.5` и графическими библиотеками.
- **Низкие задержки аудио (PipeWire)**: Встроенные аудио-пресеты (Safe, Balanced, Low, Ultra) и ручная подстройка `STAGING_AUDIO_*` для достижения суб-миллисекундного отклика без треска.
- **Интеграция с рабочим столом и MIME**: Полная поддержка открытия файлов `.osz` (карты), `.osk` (скины), `.osr` (реплеи), `.osu`, `.osb` и ссылок `osu://` прямо из браузера.
- **Предпроверка системы (Preflight)**: Автоматическое сканирование системы на наличие недостающих 32-битных библиотек multilib, user-сервисов PipeWire и установка недостающих пакетов.
- **Определение GPU**: Распознает видеокарты NVIDIA, AMD или Intel и выставляет оптимальные флаги производительности (`__GL_THREADED_OPTIMIZATIONS`, `vblank_mode=0`).
- **Двуязычный интерфейс**: Поддержка английского и русского языков в терминале.

---

## Требования

Перед запуском инсталлятора убедитесь, что:
1. У вас установлен **Arch Linux** (или дистрибутив на его базе: EndeavourOS, CachyOS, Manjaro).
2. В `/etc/pacman.conf` включён репозиторий `[multilib]` (необходим для 32-битных библиотек Wine).
3. Есть права `sudo` для установки системных пакетов.

---

## Быстрый старт

### 1. Клонируйте или скачайте скрипт

```bash
git clone https://github.com/mizukika/osu-stable-arch-linux.git
cd osu-stable-arch-linux
chmod +x osu-install.sh
```

### 2. Запустите инсталлятор

```bash
./osu-install.sh
```

Выберите пункт **`01. Установить / обновить osu!`** в главном меню и следуйте подсказкам на экране.

---

## Руководство пользователя

После установки вы можете запускать osu! из меню приложений или через терминал:

| Команда | Описание |
| :--- | :--- |
| `osu` | Запуск osu! Stable с окружением низких задержек аудио |
| `osukill` | Принудительное закрытие зависших процессов Wine и osu! |
| `./osu-install.sh` | Открытие интерактивного меню управления |

---

## Флаги командной строки

Скрипт поддерживает автоматические команды без открытия меню:

```bash
./osu-install.sh --install       # Полная автоматическая установка
./osu-install.sh --preflight     # Проверка системы и установка недостающих пакетов
./osu-install.sh --audio         # Меню настроек PipeWire
./osu-install.sh --repair        # Перерегистрация ассоциаций файлов и ассоциаций ссылок
./osu-install.sh --status        # Показать текущий статус установки
./osu-install.sh --kill          # Завершить все процессы Wine
```

---

## Настройка низких задержек звука (PipeWire)

Для уменьшения задержки звука выберите **Пункт 7** (`Low-latency audio`) в главном меню:

| Пресет | PipeWire Quantum | STAGING Period | Назначение |
| :--- | :--- | :--- | :--- |
| **Safe** | 256 (~5.3ms) | 20000 µs | Стандартный пресет / защита от треска звука |
| **Balanced** | 128 (~2.7ms) | 13333 µs | **Рекомендуемый** дефолт для большинства систем |
| **Low** | 64 (~1.3ms) | 6666 µs | Соревновательный режим / мощный процессор |
| **Ultra** | 32 (~0.67ms) | 3333 µs | Экспериментальный минимальный буфер |

> **Совет:** Проверить текущий размер буфера во время игры можно командой `pw-top` в терминале.

---

## Решение проблем и FAQ

<details>
<summary><b>1. Ошибка: <code>target not found: lib32-pipewire</code> или недостающие пакеты multilib</b></summary>

Убедитесь, что 32-битный репозиторий `[multilib]` раскомментирован в `/etc/pacman.conf`:

```bash
sudo sed -i '/^#\[multilib\]/,/^$/{s/^#//}' /etc/pacman.conf
sudo pacman -Sy
```
</details>

<details>
<summary><b>2. Ошибка <code>Wine Mono is not installed</code></b></summary>

osu! требует официальный Microsoft `.NET Framework 4.5`. Запустите Пункт 01 в меню или установите `.NET` вручную через `winetricks`:

```bash
sudo pacman -S --needed cabextract
WINEPREFIX=$HOME/.wineosu WINEARCH=win32 winetricks -q dotnet45 gdiplus cjkfonts
```
</details>

<details>
<summary><b>3. Треск или прерывания звука</b></summary>

Если на низких значениях quantum появляется треск звука, переключите пресет на более высокий (например, **Balanced** или **Safe**) в аудио-меню.
</details>

---

## Удаление

Чтобы полностью удалить osu!, префикс Wine, созданные команды и ярлыки:

1. Запустите `./osu-install.sh`.
2. Выберите пункт **`06. Удалить osu!`**.
3. Введите `DELETE` для подтверждения.

---

## Авторы и благодарности

- **Мейнтейнер:** [exteraDere](https://osu.ppy.sh/users/39692242) *(нуб, играет херово)*
- **Оригинальный гайд:** Основано на материале [osu-on-linux](https://github.com/Vudek/osu-on-linux/blob/main/README.md) от игрока [Vudek](https://osu.ppy.sh/users/8816345/osu).

---

## Лицензия

Распространяется под лицензией MIT.
