# BashTotalTime

This is a quick little Bash script I made to count the total duration of all the mp3 and mp4 files in a directory.
It'll count all files in the subdirectories as well, so it's not just the directory you give.
It may not be 100% accurate it's really just to have a general idea of duration.
I know I truncate the decimal for content that is less than a minute.
I don't have any protection for overflows, so hopefully one of the tracking variables doesn't go beyond your system's max integer value.
