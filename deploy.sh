#!/bin/sh

# deploy.sh: Generate and deploy files to the 'thor' web server.

hugo && rsync -avz --delete public/ thor:/var/www/tdback.net/
