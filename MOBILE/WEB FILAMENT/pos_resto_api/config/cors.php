<?php

return [

    'paths' => ['api/*', 'sanctum/csrf-cookie', 'storage/*'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://localhost:8000',
        // 'http://localhost:62309/',
        'http://localhost:49669', 
         'http://localhost:53081/', 
        'http://192.168.57.65:8000',// ganti dengan port Flutter Web kamu
        'http://127.0.0.1:8000',
        '*'
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => true,

];

