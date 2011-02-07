Getting the sandbox working for the first time
----------------------------------------------

First, you have to shut off MySQL if it's running.  This is because
there's a bug either in MySQL or DBD::mysql whereby it hangs during
the make test phase of the installation.  Yes, this is probably
a bug that we shouldn't ignore but I don't have time to figure out what's
going on, or try to find an older version of DBD::mysql that does work
in OSX.

So, the first time you install the sandbox, do this:  (fix up
your paths accordingly)

sudo /Library/StartupItems/MySQLCOM/MySQLCOM stop
export IF_SANDBOX=~/LocalProjects/Idealist/i2/sandbox
cd $IF_SANDBOX
make

During the make process, the installation of the perl modules will
annoyingly ask you some questions.  Refuse to install optional modules
and accept all other defaults.

If all goes well, you can activate the sandbox using

source $IF_SANDBOX/activate.sh

and you'll be good to go.  Remember to restart MySQL:

sudo /Library/StartupItems/MySQLCOM/MySQLCOM start


NOTE:  In order to use the sandbox with i2 (or ICA), you will also
need to update your conf files to point to the new locations of 
apache and memcached:

In IF.conf:

	MEMCACHED_PATH => "$ENV{'IF_SANDBOX'}/local/bin/memcached",

In you app's Config.pm:

	HTTPD_PATH => "$ENV{'IF_SANDBOX'}/local/apache2/bin/httpd",

	...

    MODULE_PATH => "$ENV{'IF_SANDBOX'}/local/apache2/modules",

And that's it.
