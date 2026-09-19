# Dotfiles Architecture

## Цель

Один репозиторий `dotfiles` должен описывать окружение и для **NixOS**,
и для **macOS**.

Основные принципы:

-   один `flake.nix` --- точка входа для всех машин;
-   **NixOS** управляется через `nixosConfigurations`;
-   **macOS** управляется через `nix-darwin` и `darwinConfigurations`;
-   пользовательское окружение управляется через **Home Manager**;
-   каждая программа живёт в **собственном модуле/директории**,
    аналогично `./dotfiles/roles/*` в текущем Ansible-конфиге;
-   общий конфиг программы используется на обеих ОС;
-   OS-specific настройки остаются внутри модуля программы либо в
    host/system-конфигурации.

------------------------------------------------------------------------

## Структура репозитория

``` text
dotfiles/
├── flake.nix
├── flake.lock
│
├── hosts/
│   ├── nixos/
│   │   └── default.nix
│   └── macbook/
│       └── default.nix
│
├── home/
│   └── default.nix
│
└── modules/
    ├── nvim/
    │   └── default.nix
    ├── git/
    │   └── default.nix
    ├── bat/
    │   ├── default.nix
    │   └── files/
    │       └── config
    ├── zsh/
    │   └── default.nix
    ├── zen/
    │   └── default.nix
    ├── chatgpt/
    │   └── default.nix
    ├── hyprland/
    │   └── default.nix
    └── walker/
        └── default.nix
```

Это примерно соответствует старой модели:

``` text
roles/bat/tasks/main.yaml
roles/nvim/tasks/main.yaml
roles/anki/tasks/main.yaml
```

→

``` text
modules/bat/default.nix
modules/nvim/default.nix
modules/anki/default.nix
```

------------------------------------------------------------------------

## Уровни конфигурации

### 1. `flake.nix`

Главная точка входа.

Он:

-   подключает `nixpkgs`;
-   подключает Home Manager;
-   подключает `nix-darwin`;
-   описывает NixOS-машины;
-   описывает macOS-машины;
-   связывает system-конфигурацию с Home Manager.

Концептуально:

``` nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";

      modules = [
        ./hosts/nixos
        home-manager.nixosModules.home-manager

        {
          home-manager.users.stounfo = import ./home;
        }
      ];
    };

    darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      modules = [
        ./hosts/macbook
        home-manager.darwinModules.home-manager

        {
          home-manager.users.stounfo = import ./home;
        }
      ];
    };
  };
}
```

------------------------------------------------------------------------

### 2. `hosts/`

Здесь находится **системная конфигурация конкретной машины**.

Она не должна содержать обычные пользовательские программы, если их
можно нормально описать через Home Manager.

#### `hosts/nixos/default.nix`

Например:

-   boot;
-   filesystem;
-   hardware;
-   networking;
-   systemd;
-   display manager;
-   системные сервисы;
-   NixOS-specific настройки.

#### `hosts/macbook/default.nix`

Например:

-   macOS system defaults;
-   Dock;
-   Finder;
-   keyboard;
-   системные настройки `nix-darwin`;
-   другие настройки непосредственно macOS.

То есть:

``` text
hosts/
    ↓
операционная система / конкретная машина
```

------------------------------------------------------------------------

### 3. `home/default.nix`

Это агрегатор пользовательских модулей.

``` nix
{
  imports = [
    ../modules/nvim
    ../modules/git
    ../modules/bat
    ../modules/zsh
    ../modules/zen
    ../modules/chatgpt
    ../modules/hyprland
    ../modules/walker
  ];
}
```

Он не должен содержать большой объём конфигурации сам.

Его задача --- определить, **из каких модулей состоит пользовательское
окружение**.

------------------------------------------------------------------------

## Модель: одна программа = один модуль

Каждая программа получает собственную директорию:

``` text
modules/
└── bat/
    ├── default.nix
    └── files/
        └── config
```

Все файлы, которые модуль устанавливает в домашний каталог пользователя
(конфиги, темы, скрипты и другие dotfiles), всегда хранятся в подкаталоге
`files/` соответствующего модуля. В корне директории модуля остаются только
Nix-файлы самого модуля.

Например, модуль Ghostty хранит исходники пользовательской конфигурации так:

``` text
modules/
└── ghostty/
    ├── default.nix
    └── files/
        ├── config.ghostty
        └── themes/
```

`default.nix` отвечает за:

-   установку программы;
-   Home Manager configuration;
-   dotfiles программы;
-   environment variables;
-   необходимые сервисы;
-   OS-specific различия этой программы.

Например:

``` nix
# modules/bat/default.nix

{ ... }:

{
  programs.bat = {
    enable = true;
  };
}
```

------------------------------------------------------------------------

## Кроссплатформенные программы

Если программа одинаково работает на Linux и macOS, модуль вообще не
должен знать, на какой ОС он запущен.

Например:

``` nix
# modules/git/default.nix

{ ... }:

{
  programs.git = {
    enable = true;
  };
}
```

Этот же файл используется:

``` text
macOS ───┐
         ├── modules/git
NixOS ───┘
```

Это предпочтительный вариант.

------------------------------------------------------------------------

## OS-specific программы

Если программа существует только на одной ОС, **всё равно сохраняем
отдельный модуль программы**.

Например ChatGPT сейчас нужен только на macOS:

``` text
modules/
└── chatgpt/
    └── default.nix
```

Сам модуль проверяет платформу:

``` nix
{ pkgs, lib, ... }:

{
  home.packages = lib.optionals pkgs.stdenv.isDarwin [
    # ChatGPT package
  ];
}
```

Таким образом `home/default.nix` всё равно импортирует:

``` nix
../modules/chatgpt
```

и на Linux модуль просто ничего не делает.

Если позже появится подходящий Linux-пакет, Linux-поддержка добавляется
**в этот же модуль**, а структура репозитория не меняется.

------------------------------------------------------------------------

## Linux-only пример

Hyprland существует только на Linux:

``` nix
# modules/hyprland/default.nix

{ pkgs, lib, ... }:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    wayland.windowManager.hyprland.enable = true;
  };
}
```

На macOS этот модуль становится пустым.

------------------------------------------------------------------------

## Когда делать OS-specific логику внутри модуля

Если различие относится именно к программе:

``` text
modules/chatgpt/
modules/hyprland/
modules/zen/
```

условие должно находиться **в модуле этой программы**.

Например:

``` nix
lib.mkIf pkgs.stdenv.isDarwin {
  ...
}
```

или:

``` nix
lib.mkIf pkgs.stdenv.isLinux {
  ...
}
```

Это позволяет не превращать `home/default.nix` в набор условий.

Плохо:

``` nix
imports =
  commonModules
  ++ lib.optionals isLinux [
    ../modules/hyprland
    ../modules/walker
    ../modules/foo
    ../modules/bar
  ]
  ++ lib.optionals isDarwin [
    ../modules/chatgpt
    ../modules/baz
  ];
```

Предпочтительнее:

``` nix
imports = [
  ../modules/hyprland
  ../modules/walker
  ../modules/chatgpt
];
```

а каждый модуль самостоятельно ограничивает платформу.

------------------------------------------------------------------------

## Когда НЕ использовать Home Manager

Не всё является пользовательской программой.

Если настройка относится к самой ОС, она должна находиться в `hosts/`.

Например:

``` text
Hyprland user config
→ modules/hyprland/

NixOS bootloader
→ hosts/nixos/

Git config
→ modules/git/

macOS Dock settings
→ hosts/macbook/

Neovim
→ modules/nvim/

NixOS filesystem
→ hosts/nixos/
```

Простое правило:

> **`modules/` описывает пользовательское окружение.\
> `hosts/` описывает машину и операционную систему.**

------------------------------------------------------------------------

## Большие модули

Если программе нужна интеграция с ОС, рядом с Home Manager-модулем
`default.nix` размещается `system.nix` (например, у Hyprland и SSH).
Эти системные модули подключаются в общем `sharedConfig` в `flake.nix`.
Flake передаёт `isNixOS` через `specialArgs`, а сам модуль решает,
когда включать настройки. NixOS-опции не объявляются на macOS.
Так настройки программы остаются в её директории, а в `hosts/`
остаются оборудование, сеть, пользователи и системные сервисы.

Модуль программы не обязан состоять из одного файла.

Если Neovim станет большим:

``` text
modules/
└── nvim/
    ├── default.nix
    ├── plugins.nix
    ├── lsp.nix
    ├── keymaps.nix
    └── files/
        └── config/
            ├── init.lua
            └── lua/
```

При этом снаружи он всё равно выглядит как один модуль:

``` nix
imports = [
  ../modules/nvim
];
```

То есть внутренняя сложность программы не протекает в общую архитектуру.

------------------------------------------------------------------------

## Применение конфигурации

### NixOS

``` bash
sudo nixos-rebuild switch --flake .#nixos
```

### macOS

``` bash
darwin-rebuild switch --flake .#macbook
```

Обе команды используют один репозиторий и одни общие `modules/*`.

------------------------------------------------------------------------

## Архитектурное правило

Итоговая зависимость выглядит так:

``` text
                       flake.nix
                      /         \
                     /           \
            NixOS system       macOS system
                 |                  |
          hosts/nixos         hosts/macbook
                 \                  /
                  \                /
                   Home Manager
                        |
                  home/default.nix
                        |
        ┌───────────────┼────────────────┐
        │               │                │
     modules/         modules/         modules/
       nvim              git           chatgpt
        │                 │                │
   Linux + macOS     Linux + macOS      macOS
```

------------------------------------------------------------------------

## Основные правила проекта

1.  **Один репозиторий для macOS и NixOS.**
2.  **Одна программа = одна директория в `modules/`.**
3.  Максимально использовать один и тот же модуль на обеих ОС.
4.  OS-specific различия программы держать внутри её модуля.
5.  Системные настройки держать в `hosts/`.
6.  `home/default.nix` использовать преимущественно как список импортов.
7.  Не дублировать конфиги между macOS и Linux без необходимости.
8.  Пользовательские конфиги и другие устанавливаемые файлы модулей всегда
    хранить в `modules/<program>/files/`.
8.  Большой модуль можно разбивать на внутренние `.nix`/config-файлы, не
    меняя внешний интерфейс.
9.  Добавление новой ОС или машины не должно требовать копирования
    пользовательских модулей.
10. Репозиторий должен оставаться понятным по принципу текущих Ansible
    `roles`: чтобы по имени директории сразу было понятно, где лежит
    конфигурация конкретной программы.
