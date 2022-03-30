# Torsions

The torsions server is a wrapper around the TorsionAnalyzer commandline application and is its intermediary into the 
web. It consists of a django backend server with infrastructure to run asynchornous jobs on a redis cluster, as well as
various management functionality for Torsion Library and TorsionAnalyzer data. More information can be found in the
following publication:

Patrick Penner, Wolfgang Guba, Robert Schmidt, Agnes Meyder, Martin Stahl, and Matthias Rarey. (2022).
The Torsion Library: Semiautomated Improvement of Torsion Rules with SMARTScompare. J.Chem.Inf.Model. [https://doi.org/10.1021/acs.jcim.2c00043](https://doi.org/10.1021/acs.jcim.2c00043)

The frontend submodule can be found here: [https://github.com/rareylab/torsions_frontend](https://github.com/rareylab/torsions_frontend)

A running instance can be found here: [https://torsions.zbh.uni-hamburg.de/](https://torsions.zbh.uni-hamburg.de/)

# Setup

Get python dependencies with [conda](https://docs.conda.io/en/latest/miniconda.html).
```bash
conda create --name torsions -c anaconda -c conda-forge python=3.8 django celery psycopg2 redis redis-py vine pylint pylint-django coverage
conda activate torsions
```

At this point either set the environment variables `$USER`, `$PASSWORD` and
`$DATABASE` to the ones configured in the `torsions/settings.py` or replace them with appropriate values below.

torsions requires a postgres database and a separate database user. You can
create both with this:
```bash
psql -d postgres -c "CREATE ROLE $USER WITH ENCRYPTED PASSWORD '$PASSWORD'; ALTER ROLE $USER WITH LOGIN CREATEDB;"
psql -d postgres -c "CREATE DATABASE $DATABASE;"
```

Perform the torsions migrations and seed the database with:
```bash
python manage.py migrate
python manage.py seed
```

Ensure the `bin` directory exists and contains the `TorsionAnalyzer` binary.

The default configured backend and result system for celery is redis. Redis
must be installed and available at the url configured in the
`torsions/settings.py`.

Redis is run with the following:
```bash
redis-server
```

Celery workers can be run with:
```bash
celery -A torsions worker --loglevel=INFO
```
...or in a more debug and IDE friendly way:
```bash
python /path/to/conda/envs/torsions/bin/celery -A torsions worker --loglevel=INFO
```

# Code Quality

| Criteria               | Threshold     |
| -------------          |:-------------:|
| pylint                 | \>9.0         |
| coverage (overall)     | \>90%         |
| coverage (single file) | \>80%         |

Run pylint with the django plugin using:
```bash
find torsion* -type f -name "*.py" | xargs pylint --load-plugins pylint_django --django-settings-module=torsions.settings
```

Run coverage generation:
```bash
coverage run manage.py test
coverage html
```
This will generate an HTML coverage report int `htmlcov`

# Deployment

The preferred deployment server is gunicorn. It can be installed like this:
```bash
conda install -c anaconda gunicorn
```

Two scripts, `start.sh` and `stop.sh`, are provided as utilities to start and
stop all necessary processes. The necessary processes are the following:

 - redis
 - celery worker
 - gunicorn

Each process has its own directory where it will log to and save its PID file
to. All processes are daemonized for an unprivileged user. The assumption is
made that if a PID file exists the process is running as intended. This may not
always be the case if the process encounters an unexpected error or is
configured incorrectly. Configuration is kept as close to default as possible
and modified values in default configuration files are marked with 'modified'.

A static torsion library is necessary for the torsion\_analyzer. Paths to one
can be set in torsion\_analyzer/settings.py. The `STATIC_TORLIB_URL` is
especially dependent on how static data is served in the deployment.

