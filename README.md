# Yet Another git Guide for svn Users

Table of Contents
=================

   * [Yet Another git Guide for svn Users](#yet-another-git-guide-for-svn-users)
      * [Why (An Intro)?](#why-an-intro)
   * [Other Resources](#other-resources)
      * [Learning Git](#learning-git)
      * [Tools and Setup](#tools-and-setup)
      * [What's Not Here](#whats-not-here)
      * [Special Thanks](#special-thanks)
      * [TODOs](#todos)
         * [Once back at work](#once-back-at-work)

## Why (An Intro)?
Thanks to the COVID-19 pandemic, I'm stuck at home. My work team is migrating from `svn` to `git` and I was going to put together a brown bag or two for them, but since I'm home I'm able to put a copy on GitHub.

There are many sites out there that cover similar things, but many seem to be "how to migrate a repo" or simple [cheat sheets](https://www.git-tower.com/blog/git-for-subversion-users-cheat-sheet/). I want a simple set of things I can present over a lunch session or two.

# TODO
(Actual meat here)

## Squashing Commits - An Example
Squashing commits is a useful way to keep related changes within a single changeset for later examination. There are good arguments both _for_ squashing ("no need to see how the sausage was made and these intermediate changesets that make no sense on their own") and _against_ ("the way this document was tweaked is unique enough that I might want to reference that specific changeset later"). 

The following is an example of merging in a branch "`feature--cool-intro`" from the top-level of the repository:
* `git checkout master`

Ensure latest sync with server:
* `git pull --rebase`
* `git merge --no-commit --squash feature--cool-intro`

At this point, the merge is staged in the "index,"" but the git-proposed commit message is not very human-readable (it includes the full logs of all intermediate commits). This information is stored in your repository in `.git/SQUASH_MSG`:
```
$ grep commit .git/SQUASH_MSG | tail -3
commit 5faf49f11536fbae7819c559a62a21a47ec505c3
commit 0cd5cd8ae470377ed11b22058a45a895e318d4fa
commit 1b4f298de3ae062063c02b767f045aa3ecf3be82
```
Note the last commit ID, in this example `1b4f298de3ae062063c02b767f045aa3ecf3be82`, which is the first change in the branch when it first came out of "`master`" (or when it was last pushed there).

Now we will create a new proposed log message in a prettier format and condensed information:
 * `git log --format=’%h (%cD)%+s%+b’ --graph 1b4f298de3ae062063c02b767f045aa3ecf3be82^..feature--cool-intro > /tmp/commit_message`

Don’t miss the "^" which indicates that the log should begin at the changeset _before_ the requested, which makes it include that changeset as well.
* `git commit -eF /tmp/commit message`

This will launch your editor. If your editor is git-savvy, it will note that your current commit format is invalid. Be sure to insert two lines into the beginning:
1. Your one-line commit summary, used to generate log messages like the one currently being edited. It should probably be something like "Squashed commit of feature--cool-intro".
1. A totally blank line.

## What's Not Here
There are some other things I've already documented on an internal wiki for my team that may interest public users; treat this as a breadcrumb that you might want to search the internet for more information:
* Using `git bisect` to automate finding where something is broken
* Using `git bundle` when traveling and needing a minimal set of files with you

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
 * `git dag` - from [git-cola](https://git-cola.github.io/) (also has a nice diff viewer)
 * `git lg` - an alias I use daily - possibly [from here](https://coderwall.com/p/euwpig/a-better-git-log) and old notes of mine are below
 * Bash prompt support
   * Found in various locations but part of git's "contributed" - see [this git page](https://git-scm.com/book/id/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Bash) for more
   * Source is [here](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh)
   * For CentOS7, it was at `/usr/share/git-core/contrib/completion/git-prompt.sh` after installing (???)
   * Add the following to your `~/.bashrc` file to get immediate feedback from the shell concerning the status of your working copy:
```
if [ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
. /usr/share/git-core/contrib/completion/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWUPSTREAM="auto"
PROMPT_COMMAND='history -a;__git_ps1 "\u@\h:\w" "\\\$ "'
fi
```
* Some settings to add to your `~/.gitconfig` for some nice aliases:
```
[branch]
autosetuprebase = always
[alias]
last = log -1 HEAD
g = grep --break --heading --line-number -i
lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --full-history --simplify-merges
```
* `meld` as your merge resolver (when conflicts occur, running `git mergetool` will launch)
```
$ git config --global diff.tool meld
$ git config --global merge.tool meld
```

## Special Thanks
 * [Dillinger](https://dillinger.io/), an online Markdown editor
 * [WebGraphviz](http://www.webgraphviz.com/) for online Graphviz graphics
 * [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

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

