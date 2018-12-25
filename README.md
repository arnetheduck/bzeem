# Overview

Wikipedia contains a lot of data.
[Swarm](https://swarm-gateways.net/bzz:/theswarm.eth/) is a place to store data, so it's hard to lose it.
Bzeem is a proof-of-concept script that puts snapshots of Wikipedia on Swarm.

## Instructions

```bash
# Set up a swarm node on your local computer, and make sure it's running:
# https://swarm-guide.readthedocs.io/en/latest/gettingstarted.html

# Download ZIM file of choice - see https://wiki.kiwix.org/wiki/Main_Page
wget myfile.zim

# Make sure you have a local swarm node running before this:
./bzeem.sh myfile.zim

# Spread the link!
```

## How it works

* One of the ways to view Wikipedia content without wikipedia.org is Kiwix, which reads snapshots of Wikipedia stored in `.zim` files
* `.zim` files are compressed archives of HTML files and images, similar to `.zip`, `.tar` or `.epub`
* `bzeem.sh` expands `.zim` files to a local folder, makes some adjustments and uploads the result to swarm
* The content can now be viewed using any swarm gateway

## Where to get Wikipedia data

* [Kiwix](https://wiki.kiwix.org/wiki/Main_Page) hosts ZIM files for a wide range of open content
* [Wikimedia](https://en.wikipedia.org/wiki/Wikipedia:Database_download) has more recent and complete download options, but does not offer ZIM files directly

## Inspiration

Bzeem was inspired by:

* [distributed-wikipedia-mirror](https://github.com/ipfs/distributed-wikipedia-mirror), a similar project that stores Wikipedia on IPFS. Bzeem right now is basically a poor man's port of that project, without the nice features (like search!)
* [XOWA](http://xowa.org/) has an alternate approach: store raw Wikipedia markup and render it on the fly
* [This article](https://lwn.net/Articles/601055/) spells out the differences between Kiwix and XOWA

## Potential ways forward

### Short term & known issues

* need to add a footer to each page
* looks like swarm stores modification date or something, because writing the same zim again gives different hash - not good.

### Longer term

* Store raw data and render it on the fly
  * In browsers, it shouldn't be impossible to do this in JavaScript (scripts, anyone?)
  * The full history can be downloaded from the above site - each version could be stored
  * Since historical versions are immutable, need to find a good diff. git?
* ENS
* Swarm feeds?
