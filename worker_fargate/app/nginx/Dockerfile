From nginx:alpine

COPY default.tmp /etc/nginx/conf.d/default.tmp


EXPOSE 80

STOPSIGNAL SIGTERM

CMD envsubst '\$PHP_FPM_SOCK' < /etc/nginx/conf.d/default.tmp > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
