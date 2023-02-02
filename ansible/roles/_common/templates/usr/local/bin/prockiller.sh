#!/usr/bin/env #!/usr/bin/env bash
#
# This scripts kills stuck processes, that seems to happen for ansible and curl.
# Probably because of networking glitches?
#

kill -15 \
  $( ps -p $( pgrep -d, "ansible|curl" ) \
        -h -o etimes,pid,comm 2>/dev/null | awk '{if ($1 >= 3600) print $2}' ) 2>/dev/null

sleep 5

kill -9 \
  $( ps -p $( pgrep -d, "ansible|curl" ) \
        -h -o etimes,pid,comm 2>/dev/null | awk '{if ($1 >= 3600) print $2}' ) 2>/dev/null
