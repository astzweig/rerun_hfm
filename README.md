hfm (rerun)
=========
This is a little terminal host file manager. It is a [rerun][1] module, but you can download an archieved (.bin) version which is directly runable.

[1]: https://github.com/rerun/rerun

Installation
-----
#### Without Rerun
Download the archieved file (.bin). It can be run directly from terminal

#### With Rerun
For Installation of [rerun][1] see [here][3]. After installing rerun:

1. [Download ZIP][2] of HFM.
2. Copy folder to rerun module directory

[2]: https://github.com/astzweig/rerun_hfm/archive/master.zip
[3]: https://github.com/rerun/rerun/wiki/Installation

Usage
-----

    rerun hfm:<command> [options]

To see the available commands run:

    rerun hfm
    
or if you have rerun autocompletion installed type:

    rerun hfm:<tab><tab>

Quickstart
-----
Add "example.de" host with default IP "127.0.0.1" to "development" host file:

	# Creates a copy of /etc/host > renames it to
	# development and adds host line
    rerun hfm:add -h example.de
    
    # Backup /etc/host and replace it with newly created
    # development host file
    rerun hfm:activate

To get original host file back run:

    rerun hfm:activate -e default

Features
----
 - Add/Remove/Update host in host file
 - Manage multiple host files (production, development, default)
 - Master templating
 - Backup of original /etc/host file (before initial use of hfm module)
