<?php
// prints APP_KEY from getenv, from .env file, and decoded byte length
$envKey = getenv('APP_KEY');
echo "getenv: " . ($envKey === false ? '(none)' : $envKey) . PHP_EOL;
$envFile = __DIR__ . '/../.env';
$envContents = is_readable($envFile) ? file_get_contents($envFile) : '';
if (preg_match('/^APP_KEY=(.*)$/m', $envContents, $m)) {
    echo "from .env: " . $m[1] . PHP_EOL;
} else {
    echo "from .env: (none)" . PHP_EOL;
}
$keyToDecode = $envKey !== false ? $envKey : ($m[1] ?? '');
$raw = preg_replace('/^base64:/', '', $keyToDecode);
$decoded = base64_decode($raw, true);
if ($decoded === false) {
    echo "decoded: (invalid base64)" . PHP_EOL;
} else {
    echo "decoded length: " . strlen($decoded) . PHP_EOL;
    echo "decoded hex: " . bin2hex($decoded) . PHP_EOL;
}
