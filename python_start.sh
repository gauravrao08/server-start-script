#!/bin/bash
case $1 in
        start)
               # source /usr/src/yourvitualenv/bin/activate
               # gunicorn --bind 0.0.0.0:5000 wsgi:app &
		/usr/local/bin/gunicorn --bind 0.0.0.0:5000 server:app --daemon
                ;;
        stop)
#                kill -9 $(ps -ef |grep gunicorn| grep -v grep| awk '{print $2}')
                                pkill gunicorn ;

                ;;
        *)
                echo "start/stop only"
                ;;
esac

