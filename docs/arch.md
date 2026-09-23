# Архитектура личных dotfiles

Статус: проект архитектуры с нуля. Документ описывает будущую реализацию;
примеры опций и команд задают её интерфейс и ещё не означают наличия готового кода.

Цель — одним репозиторием управлять несколькими личными и рабочими компьютерами
на macOS и NixOS. Сейчас на каждой машине один управляемый пользователь.
NixOS должен поддерживать `x86_64-linux` и `aarch64-linux`; macOS —
`aarch64-darwin`, а при наличии Intel Mac — `x86_64-darwin`.

## 1. Основное решение

Архитектура состоит из трёх пользовательских сущностей:

- **Feature** — независимо включаемая программа или возможность системы.
  Она может установить пакет, подключить конфиг, настроить сервис или только
  задать системную опцию. Вся её реализация находится в `features/<name>/`.
- **Preset** задаёт типичный набор включённых features и значения их опций.
  Например, `common`, `work`, `personal`, `darwin` или `aarch64-linux`.
- **Компьютер** выбирает presets, переопределяет отдельные features и задаёт
  платформу, пользователя и аппаратные особенности.

Feature имеет короткое `description` в своём descriptor как обычные метаданные
и включается одним флагом `dots.features.<name>.enable`, который
`mk-feature-modules` создаёт автоматически по имени feature из реестра. Флаг управляет всеми частями
feature:
пользовательской, NixOS или Darwin. Отдельного выбора feature для Home Manager
нет.

Все собственные Nix-опции репозитория находятся в namespace `dots`.
`dots.features` — публичные настройки features. Пользовательские файлы и
каталоги подключаются напрямую штатным `home.file` из Home Manager через
`mkOutOfStoreSymlink`.
Встроенные опции NixOS, nix-darwin и Home Manager остаются в своих namespace.

NixOS управляет Linux-системой, nix-darwin — настройками macOS, которые он
поддерживает. Home Manager встроен в системную конфигурацию и применяется
вместе с ней. Это штатная схема интеграции
[Home Manager с NixOS и nix-darwin](https://nix-community.github.io/home-manager/nix-flakes.html).

Обычные конфиги остаются файлами в родном формате программы. По умолчанию
пользовательские конфиги подключаются к изменяемой рабочей копии Git.
Системные файлы применяются через системную сборку.

## 2. Структура репозитория

```text
flake.nix
flake.lock
arch.md
bin/
  dots                        # POSIX sh: применение конфигурации
  bootstrap                   # POSIX sh: первоначальная подготовка
lib/
  mk-configurations.nix      # собирает flake outputs для всех hosts
  mk-host.nix                 # собирает system module конкретной машины
  mk-feature-modules.nix      # собирает modules из feature descriptors
  wrap-fragment-as-module.nix # оборачивает config fragment в Nix module
  systems.nix                 # имена поддерживаемых платформ
system/
  nixos.nix                   # общие настройки NixOS
  darwin.nix                  # общие настройки macOS и Homebrew
  home.nix                    # общие настройки Home Manager
presets/
  common.nix
  work.nix
  personal.nix
  darwin.nix
  linux.nix
  aarch64-linux.nix
  x86_64-linux.nix
hosts/
  work-mac/
    descriptor.nix            # статические данные машины
    default.nix               # Nix module: presets, overrides, параметры системы
  personal-linux/
    descriptor.nix
    default.nix
    hardware-configuration.nix
features/
  default.nix                 # реестр всех известных features
  git/
    default.nix               # поддержка платформ и пути к модулям
    options.nix
    home.nix
    files/
      personal/
        gitconfig
      work/
        gitconfig
  ssh/
    default.nix
    options.nix
    home.nix
    nixos.nix
    darwin.nix
    files/
      personal/
        config
      work/
        config
  nvim/
    default.nix
    home.nix
    files/                      # Git submodule с отдельным конфигом Neovim
  dock/
    default.nix
    darwin.nix
  sway/
    default.nix
    nixos.nix
    home.nix
    files/
```

`system/` содержит общие настройки ОС и механизмы подключения. Настройки
конкретных features остаются в `features/`. Хост выбирает параметры feature
через её опции; конфиги программы хранятся рядом с feature этой программы.

`lib/mk-configurations.nix` строит flake outputs для явного списка хостов.
Он читает `descriptor.nix`, выбирает NixOS или nix-darwin по `system` и передаёт
в `mk-host.nix` descriptor вместе с `hosts/<name>/default.nix` как host module.

SSH-модуль рабочей станции описывает клиент и интеграцию агента.
SSH-сервер по умолчанию не включается.

## 3. Описание компьютера

`hosts/<name>/descriptor.nix` — обычный Nix attrset со статическими данными
конкретной машины. Это собственный descriptor репозитория, а не набор встроенных
опций NixOS или nix-darwin. `mk-configurations` читает descriptor, выбирает
`nixosSystem` или `darwinSystem`, а `mk-host` собирает system/Home Manager module
конкретной машины:

```nix
let
  systems = import ../../lib/systems.nix;
in {
  system = systems.aarch64Darwin;
  user = {
    name = "stounfo";
    home = "/Users/stounfo";
  };
  repoRoot = "/Users/stounfo/Desktop/dotfiles";

  systemStateVersion = 6;
  homeStateVersion = "26.05";
}
```

Имя машины берётся из ключа в реестре хостов flake. Семейство ОС выводится
из `system` до вычисления Nix-модулей. `user.home` и `repoRoot` — абсолютные
строки, а не значения из окружения процесса сборки.

Повторяющиеся наборы платформ хранятся в `lib/systems.nix`, чтобы feature не
дублировали строковые литералы:

```nix
# lib/systems.nix
{
  aarch64Linux = "aarch64-linux";
  x86_64Linux = "x86_64-linux";

  aarch64Darwin = "aarch64-darwin";
  x86_64Darwin = "x86_64-darwin";
}
```

Каждая конкретная платформа имеет собственное имя-константу. Групповых
алиасов вроде `linux`, `darwin` или `all` нет: feature явно перечисляет все
поддерживаемые платформы. Благодаря этому по её `default.nix` сразу видно
точный список поддерживаемых систем, а строковые значения платформ не
размазываются по репозиторию.

Это обычные данные Nix, а не новый слой модульной системы. Конкретный хост всё
равно задаёт одно точное значение `system`, например `systems.aarch64Darwin`
(его строковое значение — `"aarch64-darwin"`).

Пример:

```nix
systems = [
  systems.aarch64Linux
  systems.x86_64Linux
  systems.aarch64Darwin
  systems.x86_64Darwin
];
```

`hosts/<name>/default.nix` — обычный системный Nix-модуль конкретной машины:

```nix
{
  imports = [
    ../../presets/common.nix
    ../../presets/work.nix
    ../../presets/darwin.nix
  ];

  dots.features.nvim.enable = false;
}
```

Для NixOS этот модуль также импортирует аппаратную конфигурацию и задаёт
загрузчик, диски и другие особенности машины. Поддержка ARM сама по себе
не означает поддержку любого ARM-компьютера: необходимый модуль железа
добавляется явно для соответствующего устройства.

`mk-host` собирает конкретную машину и использует `mk-feature-modules` для
подключения всей feature-инфраструктуры. `mk-host` настраивает один аккаунт и
одну запись `home-manager.users`. Логин может отличаться между компьютерами. Значения `system.stateVersion`
и `home.stateVersion` фиксируются при первоначальной настройке; обновление
зависимостей не меняет их автоматически.

`hostDescriptor` и `inputs` передаются системным модулям через `specialArgs`, а
пользовательским — через `home-manager.extraSpecialArgs`. Это образует общий
явный набор аргументов для config fragments. Flake экспортирует именованные
`nixosConfigurations` и `darwinConfigurations`.

## 4. Presets: техническая реализация

Preset — обычный Nix-модуль, подключаемый через `imports`. Это соглашение
репозитория; оно не связано с Ansible roles или командой `nix profile`.

```nix
# presets/common.nix
{ lib, ... }: {
  dots.features.git.enable = lib.mkDefault true;
  dots.features.ssh.enable = lib.mkDefault true;
  dots.features.nvim.enable = lib.mkDefault true;
}
```

```nix
# presets/work.nix
{ lib, ... }: {
  dots.features.slack.enable = lib.mkDefault true;
}
```

Все упомянутые features должны быть зарегистрированы в `features/default.nix`.
Presets задают значения по умолчанию через `lib.mkDefault`. Явное значение
на хосте, например `dots.features.nvim.enable = false`, имеет больший приоритет.

Порядок импортов не является механизмом «последнее значение побеждает».
Два несовместимых значения одинакового приоритета дают конфликт: его нужно
разрешить в конфигурации машины. Для обычных исключений `mkForce` не требуется.

Presets разрешено комбинировать по разным осям. `common` содержит features для
всех машин, `personal` и `work` описывают назначение, `darwin` и `linux` — ОС,
а `aarch64-linux` и `x86_64-linux` — архитектуру. Feature только одного хоста
включается прямо в `hosts/<name>/default.nix`. Preset сам не пропускает
несовместимые features.

Запреты рабочего компьютера выражаются выбором presets и явным `enable = false`.
Отдельный механизм корпоративных политик сейчас не вводится. Отключение
программы не запрещает её использование как зависимости другого пакета.

## 5. Контракт feature и сборка модулей

`features/default.nix` содержит статический реестр descriptors. Если descriptor
нужны flake inputs, реестр передаёт их при импорте:

```nix
{ inputs }:

{
  git = import ./git { inherit inputs; };
  ssh = import ./ssh { inherit inputs; };
  nvim = import ./nvim { inherit inputs; };
  sway = import ./sway { inherit inputs; };
  # остальные features добавляются аналогично
}
```

Дескриптор feature — данные, независимые от итогового `config`:

```nix
# features/git/default.nix
{ inputs, ... }:

let
  systems = import ../../lib/systems.nix;
in {
  description = "Git";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
    systems.x86_64Darwin
  ];

  options = ./options.nix;
  home = ./home.nix;
}
```

Поле `description` обязательно и содержит короткое человекочитаемое описание
feature, например `"Git"`, `"SSH client"` или `"Zen Browser"`. Это метаданные
самой feature.

Необязательные поля `home`, `nixos` и `darwin` указывают на config fragments.
Если feature нужно подключить сторонний полноценный модуль, descriptor может
дополнительно объявить статические списки `homeImports`, `nixosImports` или
`darwinImports`.

Список `systems` описывает поддержку всей выбранной интеграции feature,
включая её пакет, статические imports и необходимые компоненты.

В descriptor обязательны `description` и `systems`. `systems` явно перечисляет
платформы, для которых feature полностью поддержана. Остальные поля появляются
по необходимости: `options.nix`, config fragments и списки imports необязательны.
Для собственного пакета можно добавить `package.nix` в каталог feature.

### 5.1. Состав feature

Полная feature может выглядеть так:

```text
features/example/
  default.nix       # descriptor: description, platforms, fragments и imports
  options.nix       # полноценный module с dots.features.example.*
  home.nix          # Home Manager config fragment
  nixos.nix         # NixOS config fragment
  darwin.nix        # nix-darwin config fragment
  package.nix       # собственная сборка пакета
  files/            # конфиги в родном формате программы
  scripts/          # вспомогательные скрипты, если нужны
  patches/          # патчи для собственной сборки, если нужны
```

Обязателен только `default.nix`, а в descriptor обязательны поля
`description` и `systems`. Остальные файлы создаются по необходимости:

- общий `dots.features.<name>.enable` не объявляется в самой feature:
  `mk-feature-modules` автоматически создаёт его по имени feature из реестра;
- `options.nix` — полноценный Nix-модуль. Он объявляет только дополнительные
  настройки feature помимо общего `enable`, например режим работы SSH agent;
- `home.nix`, `nixos.nix` и `darwin.nix` — config fragments. Они только задают
  значения уже объявленных опций соответствующей модульной системы и сами не
  содержат `imports`, `options` или внешний `config = ...`;
- проверку `enable` config fragments не повторяют: её централизованно добавляет
  инфраструктурная обёртка;
- если feature нужен сторонний полноценный модуль, он подключается статически
  через `homeImports`, `nixosImports` или `darwinImports` в descriptor;
- `package.nix` описывает собственный Nix-пакет, если подходящего нет в Nixpkgs;
- `files/` содержит конфиги программы в родном формате. Feature может выбрать
  нужный файл или каталог по своим `files.*`-опциям, а `home.nix` подключает
  выбранный путь через `home.file` и `mkOutOfStoreSymlink`;
- другие каталоги остаются внутренними деталями feature и не получают
  отдельного общего протокола без реальной необходимости.

Feature не обязана устанавливать программу. Например, настройка Dock состоит
из `default.nix` и `darwin.nix`, а её полезная часть может быть одной опцией:

```nix
# features/dock/darwin.nix
{
  system.defaults.dock.autohide = true;
}
```

Сам `darwin.nix` не проверяет `dots.features.dock.enable`.
`mk-feature-modules` передаёт его в `lib/wrap-fragment-as-module.nix` вместе с условием
`config.dots.features.dock.enable`; helper добавляет `lib.mkIf` снаружи.

### 5.2. Пользовательский и системные config fragments

Одна feature может иметь одновременно `home.nix`, `nixos.nix` и `darwin.nix`.
Это не произвольные Nix-модули, а config fragments с ограниченным контрактом:

```nix
# features/ssh/default.nix
{ inputs, ... }:

let
  systems = import ../../lib/systems.nix;
in {
  description = "SSH client";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
    systems.x86_64Darwin
  ];

  home = ./home.nix;
  nixos = ./nixos.nix;
  darwin = ./darwin.nix;
}
```

На NixOS сборщик подключает `home.nix` и `nixos.nix`. На macOS он подключает
`home.nix` и `darwin.nix`. Пользовательская часть может подключить один общий
SSH-конфиг, а системные части — по-разному настроить агент или интеграцию
с хранилищем ключей.

Здесь работают два независимых механизма. Статический `hostDescriptor.system` определяет,
какие платформенные части вообще импортируются: `darwin.nix` не загружается на
NixOS, а `nixos.nix` — на macOS. Итоговое
`dots.features.<name>.enable` не выбирает `imports`; оно только определяет,
вносит ли уже выбранный модуль свой вклад в итоговый `config`.

Даже при одинаковом намерении системные части остаются отдельными: NixOS
и nix-darwin имеют разные пространства системных опций. Системный модуль одной
ОС никогда не вычисляется как модуль другой ОС. Feature может состоять только
из одной системной части, как `dock`, либо только из `home.nix`, как простая
переносимая CLI-программа.

### 5.3. Статические imports сторонних модулей

Config fragment сам не может объявлять `imports`. Если feature нужен сторонний
полноценный Nix-модуль, он подключается статически через descriptor.

Например Zen Browser может экспортировать собственный Home Manager module:

```nix
# features/zen/default.nix
{ inputs, ... }:

let
  systems = import ../../lib/systems.nix;
in {
  description = "Zen Browser";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  homeImports = [
    inputs.zen-browser.homeModules.twilight
  ];

  home = ./home.nix;
}
```

`homeImports` подключается Home Manager независимо от `enable`, поэтому
объявленные сторонним модулем опции доступны во время всего вычисления. Сам
вклад feature по-прежнему условный и остаётся в fragment:

```nix
# features/zen/home.nix
{
  programs.zen-browser.enable = true;
}
```

Общая обёртка превратит этот fragment в условный config через
`dots.features.zen.enable`.

По тому же принципу descriptor может использовать:

```nix
{
  homeImports = [ ... ];
  nixosImports = [ ... ];
  darwinImports = [ ... ];
}
```

Эти списки являются статической частью descriptor и не зависят от
`dots.features.<name>.enable`.

### 5.4. Способы установки программы

Feature выбирает способ установки отдельно для каждой поддерживаемой платформы.
Приоритет способов такой:

1. Пакет из Nixpkgs. Если он доступен везде, общий `home.nix` добавляет его
   в `home.packages`.
2. Разные штатные источники на разных ОС. Например, на NixOS используется
   пакет Nixpkgs, а на macOS — Homebrew formula или cask из `darwin.nix`.
3. Собственный `package.nix`, если программу можно воспроизводимо собрать
   или упаковать средствами Nix.
4. Специализированный декларативный источник, например Mac App Store или
   менеджер расширений конкретной программы.
5. Управляемый bootstrap- или activation-шаг, только если предыдущие способы
   неприменимы. Такая установка обязана отдельно описать проверку, обновление
   и отключение, потому что она хуже воспроизводится и откатывается.

Одна и та же feature может использовать разные способы установки, сохраняя
единый внешний интерфейс:

```nix
dots.features.example.enable = true;
```

Например, если обычная пользовательская программа есть в Nixpkgs только на
`x86_64-linux`, `home.nix` может использовать `pkgs.foo` там, подключать
собственный `package-aarch64-linux.nix` на ARM Linux и не добавлять Nix-пакет
на macOS, где `darwin.nix` устанавливает её через Homebrew. Если же программа
является системным сервисом, её системная часть может владеть установкой сама.

В `systems` перечисляются платформы, для которых в репозитории реально
реализован полный путь установки и настройки. Теоретическая совместимость
программы без реализованной установки не считается поддержкой feature.

### 5.5. Собственный `package.nix`

`package.nix` — обычная функция Nix, которую вызывают через `pkgs.callPackage`.
Она получает зависимости по именам, фиксирует исходники и возвращает пакет:

```nix
# features/example/package.nix
{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "example";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "author";
    repo = "example";
    rev = "v1.0.0";
    hash = "sha256-...";
  };

  dontBuild = true;

  installPhase = ''
    install -Dm755 example $out/bin/example
  '';

  meta.platforms = lib.platforms.unix;
}
```

Пользовательская часть подключает результат как любой другой пакет:

```nix
# features/example/home.nix
{ pkgs, ... }:

let
  example = pkgs.callPackage ./package.nix { };
in {
  home.packages = [ example ];
}
```

`home.nix` описывает только то, что должно появиться при включённой feature.
Условие `dots.features.example.enable` добавляется общей обёрткой при подключении
модуля.

Если реализация сборки существенно различается, feature может иметь
`package-linux.nix` и `package-darwin.nix` и статически выбрать подходящий файл.
Небольшие различия можно выразить внутри одного `package.nix` через
`stdenv.hostPlatform`. Поле `meta.platforms` должно соответствовать реально
работающим платформам пакета; список `systems` feature дополнительно учитывает
наличие всей конфигурации вокруг него.

Отдельный `flake.nix` внутри feature не нужен. Корневой flake уже фиксирует
Nixpkgs и собирает все хосты, а `package.nix` является обычным выражением
внутри этого дерева. Отдельный flake оправдан, если пакет живёт в независимом
репозитории, разрабатывается и используется отдельно. Тогда этот репозиторий
подключается как input корневого flake, а его ревизия фиксируется в общем
`flake.lock`.

### 5.6. Сборка feature modules

Feature-механика вынесена из `mk-host` в отдельный helper
`lib/mk-feature-modules.nix`. Его задача — по реестру descriptors и статической
платформе хоста построить один агрегирующий Nix module.

`mk-feature-modules`:

1. Для каждой feature проверяет наличие обязательных `description` и `systems`.
2. Автоматически объявляет `dots.features.<name>.enable` по ключу feature в
   реестре. Default остаётся `false`.
3. Подключает имеющийся `options.nix` как полноценный module для дополнительных
   feature-specific options.
4. По статическому `system` выбирает допустимые платформенные части:
   на NixOS — `home`, `nixos`, `homeImports`, `nixosImports`; на macOS —
   `home`, `darwin`, `homeImports`, `darwinImports`.
5. На неподдерживаемой платформе implementation feature не подключается, но
   общий `enable`, feature-specific options и проверка совместимости остаются
   доступны.
6. Подключает соответствующие `*Imports` статически как обычные modules.
7. Каждый выбранный config fragment передаёт в
   `wrap-fragment-as-module.nix` вместе с ленивой функцией `condition`.
8. Добавляет assertion `!enable || supported` с понятным сообщением об ошибке.

Концептуальный интерфейс:

```nix
mkFeatureModules {
  inherit features;
  system = hostDescriptor.system;
  userName = hostDescriptor.user.name;
}
```

Результат — один полноценный system module, который:

```nix
{
  imports = [
    # feature.options
    # nixosImports или darwinImports
    # обёрнутые nixos/darwin fragments
  ];

  options.dots.features = {
    # автоматически сгенерированные <name>.enable
  };

  config = {
    assertions = [
      # descriptor validation
      # platform compatibility
    ];

    home-manager.users.${userName}.imports = [
      # homeImports
      # обёрнутые home fragments
    ];
  };
}
```

`mk-host.nix` отвечает за сборку system module конкретной машины. Он получает
уже прочитанный `hostDescriptor` и `hostModule`, подключает Home Manager,
`mk-feature-modules`, общий `system/nixos.nix` или `system/darwin.nix`,
`hosts/<name>/default.nix` и прокидывает `hostDescriptor`/`inputs`.

Концептуальный вход `mk-host`:

```nix
{
  features,
  hostDescriptor,
  hostModule,
}:
```

`hostDescriptor` — данные из `descriptor.nix`, а `hostModule` — путь на каталог
хоста, то есть `hosts/<name>/default.nix` как обычный module.

`mk-configurations.nix` находится уровнем выше: он принимает attrset вида
`{ name = ./hosts/name; }`, читает `descriptor.nix` каждого хоста, по полю
`system` выбирает `nixpkgs.lib.nixosSystem` или `nix-darwin.lib.darwinSystem`,
вызывает `mk-host` и объединяет получившиеся `nixosConfigurations` и
`darwinConfigurations` в flake outputs.

Его текущая форма:

```nix
{
  lib,
  inputs,
  features,
}:

hosts:

let
  mkHost = import ./mk-host.nix {
    inherit lib inputs;
  };

  mkConfiguration =
    name: hostDir:

    let
      hostDescriptor = import (hostDir + "/descriptor.nix");

      configurationArgs = {
        specialArgs = {
          inherit hostDescriptor inputs;
        };

        modules = [
          (mkHost {
            inherit features hostDescriptor;
            hostModule = hostDir;
          })
        ];
      };
    in
    if lib.hasSuffix "-linux" hostDescriptor.system then
      {
        nixosConfigurations.${name} =
          inputs.nixpkgs.lib.nixosSystem configurationArgs;
      }
    else
      {
        darwinConfigurations.${name} =
          inputs.nix-darwin.lib.darwinSystem configurationArgs;
      };
in
lib.foldl'
  (result: name:
    lib.recursiveUpdate
      result
      (mkConfiguration name hosts.${name}))
  { }
  (lib.attrNames hosts)
```

Концептуально корневой `flake.nix` после этого остаётся тонким:

```nix
mkConfigurations {
  test-mac = ./hosts/test-mac;
  test-nixos = ./hosts/test-nixos;
}
```

Список хостов остаётся явным; автоматического сканирования `hosts/` нет.

Общая option создаётся независимо от `description`:

```nix
{
  options.dots.features =
    lib.mapAttrs
      (name: _: {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable feature ${name}.";
        };
      })
      features;
}
```

`description` остаётся отдельной метаинформацией descriptor и не используется как
текст `mkEnableOption`.

`enable` нельзя использовать для выбора `imports`: его итоговое значение само
получается после объединения presets, хоста и остальных modules. Поэтому
`options.nix` и descriptor `*Imports` подключаются статически для выбранной
платформы, а условность config fragments добавляется уже к их definitions через
`mkIf`.

Helper для fragments:

```nix
# lib/wrap-fragment-as-module.nix
{ lib }:

{ condition, fragment }:

let
  fragmentValue = import fragment;

  fragmentArgs =
    if builtins.isFunction fragmentValue
    then lib.functionArgs fragmentValue
    else { };

  conditionArgs = lib.functionArgs condition;

  argumentNames =
    lib.unique (
      lib.attrNames fragmentArgs
      ++ lib.attrNames conditionArgs
    );

  moduleArgs =
    lib.genAttrs argumentNames (
      name:
      (fragmentArgs.${name} or true)
      && (conditionArgs.${name} or true)
    );

  module = args: {
    config =
      lib.mkIf
        (condition args)
        (
          if builtins.isFunction fragmentValue
          then fragmentValue args
          else fragmentValue
        );
  };
in

lib.setFunctionArgs module moduleArgs
```

`wrap-fragment-as-module.nix` не знает ни имя feature, ни платформу, ни разницу
между Home Manager, NixOS и nix-darwin. Он получает путь `fragment` и функцию
`condition`.

Fragment может быть функцией:

```nix
{ pkgs, ... }: {
  home.packages = [ pkgs.cowsay ];
}
```

или готовым attrset без аргументов:

```nix
{
  system.defaults.dock.autohide = true;
}
```

Если fragment — функция, helper через `lib.functionArgs` выясняет, какие module
arguments нужны fragment и `condition`, объединяет эти требования и через
`lib.setFunctionArgs` сообщает их модульной системе. Один полученный `args`
передаётся и в `condition`, и во fragment. Если fragment уже attrset, он
используется напрямую.

Для системного fragment условие строится так:

```nix
wrapFragmentAsModule {
  fragment = feature.darwin;

  condition = { config, ... }:
    config.dots.features.${name}.enable;
}
```

Для Home Manager:

```nix
wrapFragmentAsModule {
  fragment = feature.home;

  condition = { osConfig, ... }:
    osConfig.dots.features.${name}.enable;
}
```

Поэтому дерево imports остаётся статическим, а итоговое значение `enable`
разрешается лениво уже внутри module evaluation.

`options.nix` и descriptor `*Imports` являются полноценными Nix modules.
`home.nix`, `nixos.nix` и `darwin.nix` — config fragments. Если feature нужны
дополнительные собственные опции, системный fragment может читать
`config.dots.features.<name>`, а пользовательский — `osConfig.dots.features.<name>`.

На неподдерживаемой платформе implementation feature не загружается. Это важно:
`mkIf false` не используется как способ спрятать неизвестные другой ОС опции или
недоступный пакет. При этом declaration `dots.features.<name>.enable` существует,
поэтому включение несовместимой feature завершается нашей assertion-ошибкой.

Реестр — перечень доступных features, а не второй перечень включённого.
Единственный источник выбора — итоговые значения `dots.features.*.enable`.

## 6. Несовместимая feature

При включении feature на неподдерживаемой платформе проверка и сборка
завершаются до активации системы:

```text
Feature sway включена для work-mac.
Платформа компьютера: aarch64-darwin.
Поддерживаемые платформы: x86_64-linux, aarch64-linux.
```

Поведение одинаково для прямого включения и включения через preset.
Пользователь выключает feature на хосте либо выбирает другую.
Автоматического пропуска нет.

На неподдерживаемой платформе загружаются только объявления опций и проверка,
а модули установки не подключаются. Это позволяет выдать нашу диагностику
до обращения к отсутствующему пакету.

Проверка учитывает ОС и архитектуру. Она выявляет известную несовместимость;
успешная проверка не гарантирует сборку или работу любой версии пакета.
Обычные ограничения Nixpkgs также сохраняются.

## 7. Пакеты и настройки системы

Способ установки определяется владельцем программы, а не самой ОС:

- обычная пользовательская программа устанавливается через Home Manager;
- если пакет нужно собирать самостоятельно, `package-*.nix` возвращает пакет,
  который затем всё равно подключает `home.nix`;
- системный сервис или компонент устанавливается и настраивается через
  `nixos.nix` или `darwin.nix`;
- на macOS Homebrew formula/cask допускается как отдельный способ установки,
  когда программу решено ставить через Homebrew.

`nixos.nix` и `darwin.nix` не используются как ещё одно произвольное место для
установки обычных пользовательских программ. Один исполняемый файл без
необходимости не устанавливается двумя разными механизмами.

Выбор конкретного источника остаётся внутри feature. Например, одна feature
может брать `pkgs.foo` на `x86_64-linux`, собственный
`package-aarch64-linux.nix` на `aarch64-linux` и Homebrew cask на macOS, сохраняя
единый внешний флаг `dots.features.foo.enable`.

Nixpkgs, Home Manager и nix-darwin фиксируются в `flake.lock` в согласованных
версиях. Home Manager использует системный набор пакетов через
`home-manager.useGlobalPkgs = true`; пользовательские пакеты устанавливаются
через `home-manager.useUserPackages = true`. Это соответствует примерам
интеграции для [NixOS](https://nix-community.github.io/home-manager/nix-flakes/nixos.html)
и [nix-darwin](https://nix-community.github.io/home-manager/nix-flakes/nix-darwin.html).

## 8. Файлы и каталоги

Все пользовательские конфиги feature хранятся в её каталоге `files/` либо,
если конфиг живёт отдельным репозиторием, в Git submodule внутри этого каталога.

Отдельной самописной сущности для файлов нет. Feature использует штатный
`home.file` из Home Manager и `mkOutOfStoreSymlink`, чтобы конечный путь
оставался живой ссылкой на редактируемый checkout:

```nix
# features/ghostty/home.nix
{ config, hostDescriptor, ... }: {
  home.file.".config/ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${hostDescriptor.repoRoot}/features/ghostty/files/config";
}
```

Логически:

```text
~/.config/ghostty/config → <repoRoot>/features/ghostty/files/config
```

`source` может указывать как на отдельный файл, так и на целый каталог:

```nix
# features/ghostty/home.nix
{ config, hostDescriptor, ... }: {
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink
      "${hostDescriptor.repoRoot}/features/ghostty/files/work";
}
```

В этом случае:

```text
~/.config/ghostty → <repoRoot>/features/ghostty/files/work
```

Целый каталог подключается одной ссылкой только если программа не пишет в него
runtime-данные, кэши или другое изменяемое состояние. Это ответственность
реализации конкретной feature: Home Manager не может запретить программе запись
через symlink. Если программа смешивает конфиг и runtime-данные в одном каталоге,
feature подключает только нужные файлы или подкаталоги, а сам каталог остаётся
обычной директорией программы.

Содержимое живых файлов и каталогов можно редактировать напрямую через пути в
домашнем каталоге. Изменение содержимого сразу меняет исходник в Git и не
требует `dots apply`. `apply` нужен при добавлении, удалении или изменении
самой декларации `home.file`.

У одного пути назначения один владелец. Перекрытия управляемого файла и
родительского управляемого каталога считаются конфликтом.

## 9. Различия конфигов между компьютерами

Разные варианты файлов выбираются опциями самой feature в namespace
`dots.features.<name>.files.*`. Home Manager не знает о понятиях `work`,
`personal` или других вариантах: feature сама выбирает нужный `source` и
передаёт его в обычный `home.file`.

Например Git descriptor уже даёт общий `enable`, поэтому `options.nix`
объявляет только дополнительную настройку:

```nix
# features/git/options.nix
{ lib, ... }: {
  options.dots.features.git.files.variant = lib.mkOption {
    type = lib.types.enum [ "personal" "work" ];
    default = "personal";
  };
}
```

Файлы:

```text
features/git/files/
  personal/
    gitconfig
  work/
    gitconfig
```

Пользовательская часть feature выбирает нужный исходник:

```nix
# features/git/home.nix
{ config, pkgs, osConfig, hostDescriptor, ... }:

let
  variant = osConfig.dots.features.git.files.variant;
in {
  home.packages = [ pkgs.git ];

  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink
      "${hostDescriptor.repoRoot}/features/git/files/${variant}/gitconfig";
}
```

Снаружи preset или конкретный хост задаёт только вариант:

```nix
dots.features.git.files.variant = "work";
```

Тот же механизм работает для целых каталогов. Например:

```text
features/ghostty/files/
  personal/
    config
    themes/
  work/
    config
    themes/
```

```nix
# features/ghostty/home.nix
{ config, osConfig, hostDescriptor, ... }:

let
  variant = osConfig.dots.features.ghostty.files.variant;
in {
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink
      "${hostDescriptor.repoRoot}/features/ghostty/files/${variant}";
}
```

Опция `files.variant` не является обязательной общей опцией всех features.
Feature объявляет её только если ей действительно нужны несколько вариантов
файлов или каталогов. Другие настройки feature остаются рядом в собственных
namespace, например `dots.features.ssh.agent.*`.

Настоящие секреты текущая файловая схема специально не решает. Если позже
понадобятся API keys, пароли или приватные ключи, для них подключается отдельный
механизм вроде `sops-nix` или `agenix`.

## 10. Отдельные конфиг-репозитории

Самописной сущности для управления репозиториями нет. Если большой конфиг должен
жить в отдельном Git-репозитории, он подключается как Git submodule прямо в
`files/` соответствующей feature.

Например Neovim:

```text
features/nvim/
  default.nix
  home.nix
  files/              # Git submodule с отдельным Neovim-репозиторием
```

Feature Neovim подключает этот каталог точно так же, как любой другой живой
`source`:

```nix
# features/nvim/home.nix
{ config, hostDescriptor, ... }: {
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${hostDescriptor.repoRoot}/features/nvim/files";
}
```

В результате:

```text
~/.config/nvim → <repoRoot>/features/nvim/files
```

Для `home.file` неважно, является ли живой `source` обычным каталогом основного
репозитория или Git submodule. Клонирование, commit, pull и другие операции
остаются ответственностью Git, а не Nix и не `dots apply`.

Первоначальный clone dotfiles должен получать submodules, например через
`git clone --recurse-submodules`. Основной dotfiles-репозиторий фиксирует commit
submodule, а изменения самого Neovim-конфига коммитятся в его собственном
репозитории.

В текущей схеме Neovim подключается по абсолютному пути рабочей копии через
`mkOutOfStoreSymlink`, поэтому содержимое submodule не требуется самому flake
как часть его source. Если позже Nix начнёт непосредственно читать файлы из
submodule как flake source, корневой flake включает их явно:

```nix
inputs.self.submodules = true;
```

## 11. Применение и обновление

Пользовательский интерфейс первой версии минимален:

```text
dots apply <host>       вычислить, собрать и применить систему вместе с Home Manager
```

`bin/dots` и `bin/bootstrap` реализуются на обычном POSIX `sh`. Для CLI
первой версии не вводятся Python, Node.js или отдельный runtime: shell-код
должен оставаться небольшой обёрткой над Nix и системными командами.

`dots apply` выполняет следующие шаги:

1. Вычисляет итоговую Nix-конфигурацию выбранного хоста.
2. Собирает системную конфигурацию, включая Home Manager, без переключения.
3. Активирует уже собранный результат через механизм соответствующей ОС.

Вычисление и системная сборка должны относиться к одному снимку
Nix-конфигурации. После успешной сборки активируется именно собранный результат,
без повторного выбора конфигурации из потенциально изменившихся Nix-исходников.

Git-операции и редактирование выполняются от пользователя. Повышение прав
используется только там, где оно нужно системному применению. CLI проверяет
коды завершения, включая фактический результат активации Home Manager;
успешная сборка сама по себе не означает успешное применение.

Одна команда не означает общей атомарной транзакции: системная активация,
Home Manager и Homebrew могут завершиться частично. При ошибке CLI сообщает
неуспешный этап и возвращает ненулевой код. Повторный запуск должен сохранять редактируемые файлы.

Применение не обновляет `flake.lock`, Git submodules или автоматически все
установленные Homebrew-пакеты. Обновления выполняются отдельно:

- Nix-зависимости — явное обновление lockfile, затем проверка и применение.
- Обычные дотфайлы — редактирование и обычный Git workflow.
- Вариант конфигурации feature — изменение её опции и повторный `dots apply`.
- Конфиг Neovim — обычный Git workflow внутри `features/nvim/files` и обновление commit
  указателя submodule в основном репозитории.
- Homebrew-приложения — отдельное явное обновление; автообновление самого
  GUI-приложения при наличии регулируется его собственными настройками.

Добавление управляемого пути, изменение его назначения или переключение
варианта feature требует `apply`. Новые файлы, используемые flake, необходимо
добавить в Git index; коммит до каждого применения не обязателен. Изменение
содержимого уже подключённого живого файла или каталога rebuild не требует.

## 12. Отключение feature и владение файлами

Удаление feature из presets или `enable = false` на хосте после применения
убирает её вклад в пакеты, сервисы и управляемые файлы.
Если другой preset продолжает включать feature, она остаётся включённой;
явное `false` на хосте переопределяет значения presets по умолчанию.

Home Manager удаляет принадлежащие старому поколению ссылки, которых нет
в новом. Такое поведение реализовано в его
[механизме активации файлов](https://github.com/nix-community/home-manager/blob/master/modules/files.nix).
Исходники, Git checkout, пользовательские данные и кэши сохраняются.

Если пользователь заменил управляемую ссылку обычным файлом, этот файл уже
нельзя автоматически считать принадлежащим конфигурации. Если feature
остаётся включённой, проверка нового назначения сообщает конфликт. Если
feature отключается, Home Manager сохраняет файл с предупреждением:
в новом плане его уже нет. Для этого случая отдельный журнал владения
и блокирующая проверка старого плана не вводятся.

Безусловного удаления или глобального `force = true` нет. Первоначальное
подключение поверх существующих дотфайлов тоже даёт конфликт; их перенос
или сохранение копии относится к первоначальной настройке.

Удаление пакета означает удаление из нового управляемого окружения. Он может
остаться зависимостью, в старых поколениях, в другом менеджере пакетов или
в Nix store до сборки мусора. Отключение feature не выполняет общий GC.

Для системных параметров macOS отключение определения не всегда восстанавливает
прежнее значение. Если настройке нужен обратный переход, Darwin-модуль feature
должен описывать его явно. Гарантию снятия пользовательских ссылок нельзя
распространять на произвольные побочные эффекты установки.

## 13. Границы управления Homebrew и macOS

Если Homebrew используется, конфигурация становится источником состава пакетов
в используемом Homebrew prefix. Перед первым применением существующие пакеты
нужно учесть. Для удаления исключённых formulae и casks выбирается
`homebrew.onActivation.cleanup = "uninstall"`; режим `zap` не используется.

Общий модуль Homebrew остаётся включённым даже при пустом списке приложений,
чтобы удаление последнего приложения тоже запускало cleanup. Его включение —
настройка машины, которая использует Homebrew, а не условие наличия casks.

Этот cleanup затрагивает все неописанные пакеты prefix, включая установленные
вручную. Поэтому смешивать ручное управление этим prefix с обещанием полного
декларативного удаления нельзя. Для обычного применения задаются
`autoUpdate = false` и `upgrade = false` в `homebrew.onActivation`.
Установка нового пакета всё же может потребовать изменения его зависимостей.
Область действия cleanup описана в
[документации Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile).

Mac App Store — отдельный случай: нужны вход в аккаунт и права на приложения,
а удаление записи из `masApps` не удаляет приложение автоматически. Поддержка
такого приложения должна явно учитывать этот предел; гарантировать одинаковое
удаление для casks и App Store нельзя. Эти особенности описаны в
[опциях Homebrew для nix-darwin](https://nix-darwin.github.io/nix-darwin/manual/#opt-homebrew.onActivation.cleanup).

macOS не становится полностью управляемой как NixOS: входы в аккаунты,
некоторые разрешения и корпоративные ограничения могут потребовать ручных
действий. При реализации bootstrap фиксируется короткий список таких условий.

## 14. Первоначальная настройка

Целевой результат — одна команда bootstrap с именем заранее описанной машины.
Она устанавливает недостающие инструменты, получает репозиторий в ожидаемый
путь и вызывает тот же `dots apply`.

На этом этапе считаем ОС, диск и первоначальный доступ к аккаунту подготовленными.
Разметка диска, установка NixOS с нуля и особые действия для конкретного железа
проектируются отдельно, когда появятся реальные машины. Переустановка работающей
ОС не является скрытым действием bootstrap.

Для новой машины нужно добавить статическое описание хоста, выбрать presets
и подготовить её аппаратные параметры. Реализации features переиспользуются.

## 15. Воспроизводимость и откат

| Часть окружения                     | Где фиксируется                                          | Как возвращается прежнее состояние                                 |
| ----------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------ |
| Nix-пакеты и системная конфигурация | Репозиторий и `flake.lock`                               | Прежнее поколение или сборка прежнего коммита                      |
| Размещение управляемых файлов       | Nix-конфигурация                                         | Применение соответствующей конфигурации                            |
| Содержимое живых файлов и каталогов | Рабочая копия и её Git-история                           | Git; незакоммиченные изменения требуют отдельного сохранения       |
| Конфиг Neovim                       | Git submodule и его Git-история                          | Git в `features/nvim/files`                                        |
| Homebrew и GUI-приложения           | Заявленный набор, доступные версии и состояние менеджера | Отдельные действия менеджера; lockfile не фиксирует весь результат |

Откат поколения Nix не откатывает содержимое живых файлов, каталогов,
Git submodules и состояние Homebrew. Ссылка старого поколения продолжает читать
текущее содержимое своего внешнего пути, если этот путь существует.

Для возвращения всего окружения к определённому моменту нужны соответствующие
коммиты каждого участвующего репозитория и отдельный учёт изменяемых приложений.

## 16. Секреты и возможное расширение на нескольких пользователей. Планы на будущее

Обычные несекретные файлы и каталоги подключаются через штатный `home.file`.
Секреты не получают отдельной самописной сущности `dots.secrets`: для них
используется специализированный механизм, например `sops-nix`.

Зашифрованные secret-файлы могут храниться рядом с feature и коммититься в Git.
Например SSH:

```text
features/ssh/
  default.nix
  options.nix
  home.nix
  files/
    personal/
      config
    work/
      config
  secrets/
    personal.yaml
    work.yaml
```

Снаружи хост или preset выбирает вариант обычных SSH-файлов:

```nix
dots.features.ssh.files.variant = "work";
```

`home.nix` подключает несекретный SSH config через `home.file`, а секретный
материал объявляет напрямую через API `sops-nix`. Например SSH config может
ссылаться на стабильный runtime-путь расшифрованного приватного ключа.

Таким образом разделение остаётся простым:

```text
home.file → обычные live-файлы и каталоги
sops-nix  → расшифрованные runtime-секреты
feature   → связывает их при необходимости
```

Ключ, которым новая машина может расшифровать SOPS-данные, является
bootstrap-secret и не хранится открытым в dotfiles. Его нужно один раз безопасно
доставить на новую машину до первого применения секретов.

Сейчас preset относится к компьютеру с одним пользователем. Если позже появится
несколько пользователей, выбор пользовательских приложений можно перенести на
уровень «пользователь на машине». Это потребует изменения пространства опций и
подключения Home Manager, а не просто перестановки `imports`. Системные сервисы
и системные параметры останутся общими и будут нуждаться в явном разрешении
конфликтов. Каталог features и обычные файлы конфигурации можно будет сохранить.

## 17. Критерии готовности реализации

1. На NixOS обеих архитектур и на используемых Mac конфигурации вычисляются
   с одной и той же структурой. Реальные сборки проверяются подходящими builders.
2. Каждая feature имеет обязательные `description` и `systems` в descriptor;
   `description` остаётся независимой метаинформацией, а общий
   `dots.features.<name>.enable` автоматически создаётся по имени feature из
   реестра и по умолчанию равен `false`. Home Manager- и системные config
   fragments не повторяют собственный `mkIf`: `mk-feature-modules` передаёт
   fragment и ленивую функцию условия в единый `wrap-fragment-as-module.nix`, а необходимые
   сторонние модули подключаются статически через descriptor `*Imports`.
3. Preset включает features по умолчанию, а явное `false` на хосте
   отключает все принадлежащие feature части.
4. Несовместимая feature даёт понятную ошибку до активации, в том числе
   если включена через preset. Неизвестное имя feature тоже является ошибкой.
5. Feature подключает живые файлы и каталоги напрямую через штатный
   `home.file` и `mkOutOfStoreSymlink`; отдельной самописной файловой
   инфраструктуры нет, а редактирование содержимого исходника не требует rebuild.
6. Разные варианты файлов выбираются опциями самой feature, например
   `dots.features.git.files.variant = "work"`; feature передаёт выбранный `source`
   в обычный `home.file`.
7. Конфиг Neovim хранится как Git submodule прямо в `features/nvim/files` и
   подключается через обычный `home.file`; `dots apply` не реализует собственный
   Git checkout-manager.
8. Отключение feature снимает принадлежащие ей Home Manager-ссылки, сохраняя
   исходники в основном репозитории и содержимое Git submodules.
9. Пользовательские операции не создают файлы от root; ошибки активации
   доходят до пользователя и ненулевого кода CLI.
10. Bootstrap и обычное применение используют одну схему сборки. Обновление
    зависимостей отделено от применения, а пределы отката явно отражены в CLI.

Документ задаёт архитектуру. Реализация модулей, перенос конкретных features
и применение к действующим компьютерам — следующие отдельные этапы.
