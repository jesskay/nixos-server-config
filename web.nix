{ config, pkgs, ... }:

with (import ./simple-nginx.nix { lib = pkgs.stdenv.lib; });
let retired = hostname : (withPath "retired" (basicSite hostname [] ""));
in
serveSites true
           [ ### bigmacintosh.net
             (withIndexes ["/brogue/recs/" "/f/rps/"]
               (basicSite "www.bigmacintosh.net" ["bigmacintosh.net"] ""))
             (basicSite "bitshift.bigmacintosh.net" [] "")
             (withPhp (basicSite "butt.bigmacintosh.net" [] ''
               rewrite ^/authorize/?$ /authorize.php last;
             ''))
             (withPhp(basicSite "ocdb.bigmacintosh.net" [] ''
               client_max_body_size 15M;
               
               rewrite "^(.*)/_images/([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{28}).*$" /$1/images/$2/$2$3$4 break;
               rewrite "^(.*)/_thumbs/([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{28}).*$" /$1/thumbs/$2/$2$3$4 break;
               rewrite "^(.*)/(.*)\.(php|css|js|gif|png|jpg|ico|html|manifest|appcache|txt|jar)$" /$1/$2.$3 break;
               rewrite "^(.*)/(.*)\?(.*)$ /$1/index.php?q=$2&$3" last;
               rewrite "^(.*)/(.*)$ /$1/index.php?q=$2" last;
               rewrite ^/(.*)$ /index.php?q=$1 last;
               
               location ~ /_?(images|thumbs)/ {
                 default_type image/jpeg;
               }
             ''))

             ### identicurse.net
             (withIndexes ["/release/"]
               (basicSite "www.identicurse.net" ["identicurse.net"] ''
                 location / {
                   ssi on;
                   rewrite ^/([^./]+)\.php$ /$1.html last;
                   rewrite ^/([^./]+)$ /$1.html last;
                 }
               ''))
             (redirect "issues.identicurse.net" ["bugzilla.identicurse.net"] true
               "https://github.com/identicurse/IdentiCurse/issues")

             ### psquid.eu
             (domainRedirect "psquid.eu" "psquid.net")

             ### psquid.net
             (basicSite "dl.psquid.net" [] "")
             (withIndexes ["/"] (basicSite "dl-public.psquid.net" [] ""))
             (redirect "node.psquid.net" [] true "http://dl-public.psquid.net$request_uri")
             (retired "deb.psquid.net")
             (retired "rpm.psquid.net")
             (retired "humphrey.psquid.net")
             (retired "mspa.psquid.net")
             (retired "pony.psquid.net")
             (retired "projects.psquid.net")
             (withPhp (basicSite "pxl.psquid.net" [] ''
               location = /favicon.ico {}
               location = /pxl.min.js {}
               location = /robots.txt {}
               
               location = /log.txt {
                 auth_basic "pxl";
               }
               
               location / {
                 rewrite ^/(.*)$ /log.php?u=$1&geoip_country_name=$geoip_country_name&geoip_city=$geoip_city last;
               }
             ''))
             (withSsl "/srv/www/ssl/owncloud.crt" "/srv/www/ssl/owncloud.key"
               (withCustomPhp (basicSite "cloud.psquid.net" [] ''
                 client_max_body_size 10G;
                 fastcgi_buffers 64 4K;
                 
                 rewrite ^/caldav(.*)$ /remote.php/caldav$1 redirect;
                 rewrite ^/carddav(.*)$ /remote.php/carddav$1 redirect;
                 rewrite ^/webdav(.*)$ /remote.php/webdav$1 redirect;
                 
                 error_page 403 /core/templates/403.php;
                 error_page 404 /core/templates/404.php;
                 
                 location = /robots.txt {
                   allow all;
                   log_not_found off;
                   access_log off;
                 }
                 
                 location ~ ^/(data|config|\.ht|db_structure\.xml|README) {
                   deny all;
                 }
                 
                 location / {
                   rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
                   rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
                   
                   rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
                   rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;
                   
                   rewrite ^(/core/doc/[^\/]+/)$ $1/index.html;
                   
                   try_files $uri $uri/ index.php;
                 }
                 
                 location ~ ^(.+?\.php)(/.*)?$ {
                   try_files $1 =404;
                   
                   ${fastcgiParams}
                   fastcgi_param SCRIPT_FILENAME $document_root$1;
                   fastcgi_param PATH_INFO $2;
                   fastcgi_pass unix:/run/phpfpm/nginx;
                 }
                 
                 location ~* ^.+\.(jpg|jpeg|gif|bmp|ico|png|css|js|swf)$ {
                   expires 30d;
                   access_log off;
                 }
               '')))

             ### default
             (basicSite "_" [] "")
           ]
