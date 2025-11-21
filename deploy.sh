#!/bin/bash

echo "===clean==="
npx hexo clean

echo "===generate==="
npx hexo g

echo "===copy to /var/www/html==="
rm -rf /var/www/html/kimblog
cp -r public /var/www/html/kimblog

echo "===reload nginx==="
nginx -s reload
