# Smarty PHAR Builder

> **_NOTE:_** This project was generated using AI as a proof of concept; feel free to use, modify, or share it however you like.

Scripts to package the Smarty templating engine (plus its dependencies) into a single PHAR and smoke-test it.

## Build

- Run `./build-smarty-phar.sh`
- Output: `dist/Smarty-v{resolved_version}.phar`
- Requires: PHP with `phar` extension enabled, Composer, network access (first build).

Environment toggles:

- `SMARTY_MAJOR` (default `5`): target major; picks latest in that major (`^MAJOR.0`), e.g. `3` resolves to latest 3.x.
- `PROJECT_DIR` (default `build`): temp Composer workspace.
- `OUTPUT_DIR` (default `dist`): where the PHAR is written.
- `OUTPUT_PHAR`: override full output path/name (bypasses default naming).
- `ALLOW_DIR_REUSE=1`: reuse a non-empty `PROJECT_DIR` (otherwise script refuses).
- `ALLOW_PHAR_OVERWRITE=1`: overwrite an existing PHAR at the target path.
- `KEEP_PROJECT_DIR=1`: keep the temp project directory (otherwise removed after build).
- `COMPOSER_BIN` (default `composer`): path to composer binary.

Examples:

- Latest Smarty 5.x (default): `./build-smarty-phar.sh`
- Latest Smarty 3.x, overwrite existing build: `SMARTY_MAJOR=3 ALLOW_PHAR_OVERWRITE=1 ./build-smarty-phar.sh`
- Custom output name: `OUTPUT_PHAR=dist/smarty-custom.phar ./build-smarty-phar.sh`

## Test

- Run `php test.php [path/to/phar]`
- If no argument is provided, it picks the newest `dist/Smarty-v*.phar`.
- The test loads the PHAR, creates a `Smarty` instance, and renders a small string template including the PHAR path.
