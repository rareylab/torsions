# end processes started with the start.sh in the reverse order of starting them to avoid errors

if [ -f ./gunicorn/gunicorn.pid ]; then
  echo 'stop gunicorn'
  kill $(cat ./gunicorn/gunicorn.pid)
fi

if [ -f ./celery/run/torsions_worker.pid ]; then
  echo 'stop celery worker'
  celery -A torsions multi stop torsions_worker --pidfile="$(pwd)/celery/run/%n.pid" --logfile="$(pwd)/celery/log/%n%I.log" --loglevel=INFO
fi

if [ -f ./redis/redis_6379.pid ]; then
  echo 'stop redis'
  redis-cli shutdown
fi

