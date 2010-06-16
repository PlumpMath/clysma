# Clysma

**status:** unknown

It's a reasonable example of using cl-gtk2 and Glade but I'm not sure
if I'll ever work on it again.


## A Tool to See What's Inside


### Introduction

This is nothing more than an example of using
[cl-gtk2](http://common-lisp.net/project/cl-gtk2/) for now and a
little experiment to see what kind of information I can pull from a
running CL session.

Double-click on a row in one of the tabs to get the `#'describe`
output for that row.

Also the progress bar at the bottom is not used yet.


### Windows Issues

Sorting columns by clicking on their headers doesn't work with the GTK
I'm using which is 2.16.something off the top of my head.


### Screenshot

<img src="http://www.aerique.net/software/clysma/clysma-20100127.jpg">
