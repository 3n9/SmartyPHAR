#!/usr/bin/env bash
# Build a single smarty.phar containing Smarty and its dependencies.
# Requirements: php (with ext-phar) and composer available on PATH.

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-build}"
SMARTY_MAJOR="${SMARTY_MAJOR:-5}"
OUTPUT_DIR="${OUTPUT_DIR:-dist}"
KEEP_PROJECT_DIR="${KEEP_PROJECT_DIR:-0}"
COMPOSER_BIN="${COMPOSER_BIN:-composer}"

if ! command -v "$COMPOSER_BIN" >/dev/null 2>&1; then
	echo "Composer binary '$COMPOSER_BIN' not found on PATH." >&2
	exit 1
fi

if ! command -v php >/dev/null 2>&1; then
	echo "PHP not found on PATH." >&2
	exit 1
fi

if [ -d "$PROJECT_DIR" ] && [ -n "$(ls -A "$PROJECT_DIR" 2>/dev/null)" ] && [ "${ALLOW_DIR_REUSE:-0}" != "1" ]; then
	echo "Refusing to use non-empty PROJECT_DIR: $PROJECT_DIR (set ALLOW_DIR_REUSE=1 to reuse)" >&2
	exit 1
fi

mkdir -p "$PROJECT_DIR"
PROJECT_DIR_ABS="$(cd "$PROJECT_DIR" && pwd)"

pushd "$PROJECT_DIR" >/dev/null

"$COMPOSER_BIN" init \
	--name local/smarty-phar \
	--description "Smarty packaged as a PHAR" \
	--type library \
	--license LGPL-3.0 \
	--require "smarty/smarty:^${SMARTY_MAJOR}.0" \
	--no-interaction

"$COMPOSER_BIN" install --no-interaction --prefer-dist
"$COMPOSER_BIN" dump-autoload --optimize

popd >/dev/null

SMARTY_LOCK_VERSION="$(php -r '
$lock = $argv[1];
if (!is_file($lock)) { exit(1); }
$data = json_decode(file_get_contents($lock), true);
if (!isset($data["packages"]) || !is_array($data["packages"])) { exit(1); }
foreach ($data["packages"] as $pkg) {
    if (($pkg["name"] ?? "") === "smarty/smarty" && isset($pkg["version"])) {
        echo ltrim($pkg["version"], "v");
        exit(0);
    }
}
exit(1);
' "$PROJECT_DIR_ABS/composer.lock" 2>/dev/null || true)"

if [ -z "${OUTPUT_PHAR:-}" ]; then
	VERSION_FOR_NAME="${SMARTY_LOCK_VERSION:-${SMARTY_MAJOR}}"
	VERSION_FOR_NAME="${VERSION_FOR_NAME#v}"
	OUTPUT_PHAR="${OUTPUT_DIR}/Smarty-v${VERSION_FOR_NAME}.phar"
fi

mkdir -p "$OUTPUT_DIR"

if [ -e "$OUTPUT_PHAR" ]; then
	if [ "${ALLOW_PHAR_OVERWRITE:-0}" = "1" ]; then
		rm -f "$OUTPUT_PHAR"
	else
		echo "Refusing to overwrite existing PHAR: $OUTPUT_PHAR (set ALLOW_PHAR_OVERWRITE=1 to overwrite)" >&2
		exit 1
	fi
fi

php -d phar.readonly=0 -r "$(cat <<'PHP'
$projectDir = $argv[1];
$pharPath = $argv[2];
$pharName = basename($pharPath);

if (!is_dir($projectDir . "/vendor")) {
    fwrite(STDERR, "Vendor directory not found. Did Composer finish?\n");
    exit(1);
}

$phar = new Phar($pharPath, 0, $pharName);
$phar->startBuffering();
$iter = new RecursiveIteratorIterator(
    new RecursiveDirectoryIterator($projectDir . "/vendor", FilesystemIterator::SKIP_DOTS)
);
foreach ($iter as $file) {
    /** @var SplFileInfo $file */
    if ($file->isDir()) {
        continue;
    }
    $fullPath = $file->getPathname();
    $relative = substr($fullPath, strlen($projectDir . "/vendor/"));
    $phar->addFile($fullPath, "vendor/" . $relative);
}
if (file_exists($projectDir . "/composer.json")) {
    $phar->addFile($projectDir . "/composer.json", "composer.json");
}
if (file_exists($projectDir . "/composer.lock")) {
    $phar->addFile($projectDir . "/composer.lock", "composer.lock");
}

$aliasExport = var_export($pharName, true);
$stub  = "#!/usr/bin/env php\n";
$stub .= "<?php\n";
$stub .= "Phar::mapPhar({$aliasExport});\n";
$stub .= "require 'phar://' . {$aliasExport} . '/vendor/autoload.php';\n";
$stub .= "__HALT_COMPILER();\n";

$phar->setStub($stub);
$phar->stopBuffering();
PHP
)" "$PROJECT_DIR_ABS" "$OUTPUT_PHAR"

chmod +x "$OUTPUT_PHAR"

if [ "$KEEP_PROJECT_DIR" != "1" ]; then
	rm -rf "$PROJECT_DIR"
fi

echo "Built $OUTPUT_PHAR with Smarty inside. Use it via: require '$OUTPUT_PHAR';"
