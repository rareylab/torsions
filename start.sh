# start all processes needed to run the torsions server

if [ ! -f ./redis/redis_6379.pid ]; then
  echo 'start redis'
  redis-server ./redis/redis.conf
fi

if [ ! -f ./celery/run/torsions_worker.pid ]; then
  echo 'start celery worker'
  celery -A torsions multi start torsions_worker --pidfile="$(pwd)/celery/run/%n.pid" --logfile="$(pwd)/celery/log/%n%I.log" --concurrency=4 --loglevel=INFO
fi

if [ ! -f ./gunicorn/gunicorn.pid ]; then
  echo 'start gunicorn'
  gunicorn --config gunicorn/gunicorn.conf.py torsions.wsgi
fi

