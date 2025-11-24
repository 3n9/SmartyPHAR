<?php

// Simple test runner: loads the built Smarty PHAR and renders a tiny template.
// Usage: php test.php [path/to/Smarty-vX.Y.Z.phar]

$pharPath = $argv[1] ?? null;

if ($pharPath === null) {
    $candidates = glob(__DIR__.'/dist/Smarty-v*.phar');
    if (! $candidates) {
        fwrite(STDERR, "No PHAR found in dist/. Build one first with build-smarty-phar.sh.\n");
        exit(1);
    }
    usort($candidates, static fn ($a, $b) => filemtime($b) <=> filemtime($a));
    $pharPath = $candidates[0];
}

if (! file_exists($pharPath)) {
    fwrite(STDERR, "PHAR not found: {$pharPath}\n");
    exit(1);
}

require $pharPath;

if (class_exists('Smarty')) {
    $smarty = new Smarty;
} else {
    $smarty = new Smarty\Smarty;
}

$tpl = 'Hello {$name}! Today is {$day}. Using PHAR: {$phar}';
$output = $smarty->fetch('string:'.$tpl, [
    'name' => 'Smarty',
    'day' => date('l'),
    'phar' => $pharPath,
]);

echo $output.PHP_EOL;

