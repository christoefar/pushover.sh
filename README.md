pushover.sh
===========

Shell script wrapper around curl for sending messages through [Pushover][1]. This is an unofficial script which is not released or supported by Superblock. All requests directly related to this script should be addressed through the [Github issue tracker][2].


Installation
============

To install `pushover.sh`, run

```
git clone https://github.com/christoefar/pushover.sh.git;
cd pushover.sh;
chmod +x pushover.sh;
```

Usage
=====

    pushover.sh <options> <message>
     -c <callback>
     -d <device>
     -D <timestamp>
     -e <expire>
     -p <priority>
     -r <retry>
     -t <title>
     -T <TOKEN> (required if not in config file)
     -s <sound>
     -u <url>
     -m <msg_file>
     -U <USER> (required if not in config file)

To use this script, you must have TOKEN and USER (or GROUP) keys from [PushOver][1]. These may then be specified on the terminal with `-T` and `-U`.

The message can be passed as arguments on the command line, or by using the -m switch to load the message from a file. 

[1]: http://www.pushover.net
[2]: https://github.com/jnwatts/pushover.sh/issues
