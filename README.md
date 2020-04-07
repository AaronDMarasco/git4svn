# Yet Another git Guide for svn Users

## Why (An Intro)?
Thanks to the COVID-19 pandemic, I'm stuck at home. My work team is migrating from `svn` to `git` and I was going to put together a brown bag or two for them, but since I'm home I'm able to put a copy on GitHub.

There are many sites out there that cover similar things, but many seem to be "how to migrate a repo" or simple [cheat sheets](https://www.git-tower.com/blog/git-for-subversion-users-cheat-sheet/). I want a simple set of things I can present over a lunch session or two.

# Other Resources

## Learning Git
I started learning git back in 2015, and I noted that the following sites were great help, and I highly recommend them still:
 * A [one-hour preview talk](https://www.youtube.com/watch?v=8dhZ9BXQgc4) from 2007 by Randal Schwartz (of perl fame)
   * Great intro, including around 3:20 when he simply asks "What is git?" and notes it tracks **"Changes to a tree of files over time"**
  * Ignore what he says about `git rebase` - in my experience, it's rarely used
* [The Thing About Git](https://tomayko.com/blog/2008/the-thing-about-git) by Rtan Tomayko was a good intro to the usage side
* [Think Like (a) Git](http://think-like-a-git.net/) by Sam Livingston-Gray was an **excellent** site that I used that really helped me understand the (graph) theory, the way it all comes together
* [Git Immersion](http://gitimmersion.com/index.html) by Neo Innovation is a **great** hands-on lab-like approach to learning

## Tools and Setup
In my previous office, we had "free reign" so I was able to use any tools I wanted. In a perfect world, I'd still have access to them all:
 * `git dag` - from [git-cola](https://git-cola.github.io/)
 * `git lg` - an alias I use daily - possibly [from here](https://coderwall.com/p/euwpig/a-better-git-log) but I'll need to confirm once I'm back at work
 * Bash prompt support
   * Found in various locations but part of git's "contributed" - see [this git page](https://git-scm.com/book/id/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Bash) for more

## What's Not Here
There are some other things I've already documented on an internal wiki for my team that may interest public users; treat this as a breadcrumb that you might want to search the internet for more information:
* Using `git bisect` to automate finding where something is broken
* Using `git bundle` when traveling and needing a minimal set of files with you

## Special Thanks
 * [Dillinger](https://dillinger.io/), an online Markdown editor
 * [WebGraphviz](http://www.webgraphviz.com/) for online Graphviz graphics


## TODOs
 * Anywhere
* Speculative / trial branches super light weight
* `git add -p`
* The Index
* repo vs repo vs repo vs remotes
* Squashing and FF
  ### Once back at work
* `git lg` verify
* Location on CentOS 7 (and RPM) for bash completion
* Name of other prompt program

