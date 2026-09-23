# Следующий перенос: GUI / desktop-программы

Актуально на 2026-09-23.

## Общая стратегия

Для обычных desktop-приложений:

- **NixOS:** брать из `nixpkgs`, если пакет нормально поддерживает нужную архитектуру;
- **macOS:** proprietary/native GUI-приложения брать через `homebrew.casks`;
- не делать собственные repack/derivation только ради того, чтобы формально получить одинаковую feature на всех системах;
- если приложение официально не поддерживает платформу — feature для этой платформы пока не реализовывать;
- пользовательские конфиги, если позже будем их переносить, оставлять обычными файлами в `features/<name>/files/` и подключать ссылками, как и для остальных features.

---

## telegram

### macOS

Оставляем тот же вариант, который был в старом конфиге:

```nix
homebrew.casks = [
  "telegram"
];
```

Это нативный Telegram for macOS.

### NixOS

Брать из `nixpkgs`:

```nix
home.packages = with pkgs; [
  telegram-desktop
];
```

На современных nixpkgs сам executable называется `Telegram`, хотя package attribute остаётся `telegram-desktop`.

### Feature

```text
features/telegram/
├── default.nix
├── home.nix      # NixOS package
└── darwin.nix    # Homebrew cask
```

Поддерживать:

- `aarch64-linux`
- `x86_64-linux`
- `aarch64-darwin`
- `x86_64-darwin`

---

## tableplus

### macOS

Homebrew cask:

```nix
homebrew.casks = [
  "tableplus"
];
```

### NixOS

Брать из `nixpkgs`:

```nix
home.packages = with pkgs; [
  tableplus
];
```

Пакет unfree.

`nixpkgs` имеет Linux package и для `aarch64-linux`, поэтому он подходит текущему `nixos-1`.

### Feature

```text
features/tableplus/
├── default.nix
├── home.nix
└── darwin.nix
```

Поддерживать обе Linux-архитектуры и обе Darwin-архитектуры.

---

## raycast

### macOS

Homebrew cask:

```nix
homebrew.casks = [
  "raycast"
];
```

### NixOS

Не реализовывать.

Raycast официально поддерживает macOS и Windows, но Linux не поддерживает и сейчас не планирует Linux-версию.

### Feature

Darwin-only:

```text
features/raycast/
├── default.nix
└── darwin.nix
```

`systems`:

```nix
[
  systems.aarch64Darwin
  systems.x86_64Darwin
]
```

---

## chatgpt

### macOS

Использовать официальный ChatGPT desktop app через Homebrew cask:

```nix
homebrew.casks = [
  "chatgpt"
];
```

Это текущий официальный ChatGPT desktop app.

### NixOS

Пока **не добавлять в feature**.

На Linux уже появился официальный ChatGPT desktop preview, но официально сейчас заявлены Ubuntu, Debian и Fedora.

NixOS официально не поддерживается, а текущий `pkgs.chatgpt` в nixpkgs предназначен для Darwin.

Не делать собственную упаковку Linux preview на этом этапе.

Когда появится нормальная поддержка NixOS/nixpkgs — добавить Linux implementation отдельно.

### Feature

Пока Darwin-only:

```text
features/chatgpt/
├── default.nix
└── darwin.nix
```

---

## fonts

Старый Ansible вручную скачивал Nerd Fonts zip-архивы:

- JetBrains Mono;
- Martian Mono;
- Iosevka Term;
- IBM Plex Mono.

Так больше делать не нужно.

### NixOS и macOS

Использовать **одинаковый Nix system fragment** через `fonts.packages`.

Эта опция существует и в NixOS, и в nix-darwin.

```nix
{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.martian-mono
    nerd-fonts.iosevka-term
    nerd-fonts.blex-mono
  ];
}
```

`blex-mono` — Nerd Fonts variant IBM Plex Mono.

### Почему не Homebrew

Здесь Nix уже предоставляет нормальную декларативную font capability:

- на NixOS `fonts.packages` регистрирует fonts для приложений;
- nix-darwin устанавливает их в `/Library/Fonts/Nix Fonts`.

Поэтому:

- не скачиваем Nerd Fonts вручную;
- не храним zip;
- не используем Homebrew font casks;
- не кладём fonts в обычный `home.packages`.

### Feature

Можно использовать один system fragment для обеих OS:

```text
features/fonts/
├── default.nix
└── system.nix
```

```nix
{
  nixos = ./system.nix;
  darwin = ./system.nix;
}
```

---

# Очерёдность переноса

1. `fonts`
2. `telegram`
3. `tableplus`
7. `chatgpt`

---

# CLI, которые пока игнорируем

- `fd`
- `tmux`
- `txc`
- `psql`
- `mongosh`
- `pre-commit`
- `lefthook`
- `typos`
- `prettier`
- `stylua`
- `chafa`
- `pastel`
- `vegeta`
- `speedtest-cli`
- `dockutil`

фичи юзают излинукс чтобы проверить куда ставиться

иф из никсос ор иф издарвин спрятать бы

спрятать мелкие программы слай в одну фичу

Homebrew сейчас связан с каждым darwin-rebuild:
homebrew.onActivation.upgrade = true;
homebrew.onActivation.cleanup = "uninstall";
То есть apply — не просто применение декларативной конфигурации, но ещё и апгрейд Homebrew-пакетов плюс удаление unmanaged. Если именно этого ты хочешь — нормально. Но я бы для твоей идеи «предсказуемый rebuild» скорее отделила upgrade в отдельную команду обновления.

автовыводить систем нейм
