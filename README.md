# Bedtime's Repository

An apt repository of macOS tweaks for Installer (this folder is `bytenight`). Serve this folder as static files and add its URL as a source in Installer.

| Package | What it is | Built from |
|---|---|---|
| `net.bedtime.ammonia` | Ammonia, the tweak loader | The newest `ammonia.pkg` release on GitHub, wrapped unchanged |
| `com.kbedtime.lisa` | Lisa, CSS themes for every app | The Lisa checkout named in `repo.conf` |

## Publishing

From the Lisa checkout, after committing:

```bash
Scripts/Publish.sh
```

Or from here, `Scripts/publish.sh` (it's what Lisa's script calls). It rebuilds, re-indexes, signs, commits and pushes; GitHub Pages serves it at https://kbedtime.github.io/bytenight a minute later. `Scripts/update.sh` does the same without committing, to check things locally first.

`update.sh` wraps the newest Ammonia release (once per release), builds Lisa from its checkout, keeps the two newest versions of each package, copies Lisa's banners and screenshots, and rewrites `Packages`, its compressed copies, `Release` and `depictions/`, signing `Release` as `InRelease` and `Release.gpg`.

Versions take care of themselves:

- **Lisa** is `<CMake version>~b<commit count>`, e.g. `1.0.0~b55`. Every Lisa commit is a newer beta. A release build (`LISA_RELEASE=1`) is plain `1.0.0` and upgrades over every beta.
- **Ammonia** is `<release tag>-<revision>`, e.g. `1.6.3-1`. Bump `src/net.bedtime.ammonia/revision` only when the wrapper scripts change but Ammonia doesn't.

## Depictions

`REPO_URL` in `repo.conf` is where the folder is served from (GitHub Pages). Depictions live in `src/<package>/depiction.json`: `{{REPO_URL}}` in them is filled in, and a `{"class": "@screenshots"}` view becomes the screenshots in `assets/screenshots/<package>`.

## Banners

The featured banners are real app windows in each Lisa theme. Make them in the Lisa checkout (or run `Scripts/Publish.sh --promo` there):

```bash
Scripts/Promo/shoot.py      # takes over the screen for a few minutes
Scripts/Promo/compose.py
```

`FEATURED_THEMES` in `repo.conf` picks which themes are featured.

## Signing

`Release` is signed with the GPG key named in `repo.conf` (`SIGNING_KEY`). Its public half is served as `key.gpg`. The private key lives only in this Mac's `~/.gnupg`; export it somewhere safe (`gpg --export-secret-keys --armor <key>`), because a new key means everyone has to trust the repo again.

## Layout

```
repo.conf          settings
CydiaIcon.png      repo icon (served)
assets/            featured banners and package icons (served)
Scripts/           publish.sh, update.sh, build-ammonia.sh, build-lisa.sh, promo.sh, index.sh, depiction.py
src/<package>/     depiction source, and for Ammonia its maintainer scripts and revision
debs/              built packages (served)
depictions/        generated depictions (served)
Packages*, Release, InRelease, Release.gpg, key.gpg, sileo-featured.json
                   generated indexes (served)
.cache/            downloaded Ammonia releases (not served)
```

Building needs `dpkg` (`brew install dpkg`), `gnupg`, `xz`, `zstd` and the GitHub CLI.

## What the packages change on a Mac

- **Ammonia** runs its own installer package, which installs `/private/var/ammonia`, the `com.bedtime.ammonia` launch daemon, the `-arm64e_preview_abi` boot argument and turns off library validation. The wrapper keeps any existing boot arguments (Ammonia's package on its own replaces them). Removing it deletes Ammonia's files and daemon but leaves other tweaks, the boot argument and library validation alone. Needs a restart.
- **Lisa** installs `/Library/Lisa`, the `com.lisa.monalisad` launch daemon, its tweak in Ammonia's tweak folder, Lisa Editor and `/usr/local/bin/lisa`, and turns off SwiftUI's new design (`SwiftUI/Solarium`) until it's removed. Needs a logout.
