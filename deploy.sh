#!/bin/sh

# deploy.sh: Generate and deploy files to the 'hive' web server.

hugo && rsync -avz --delete public/ hive:/var/www/tdback.net/
