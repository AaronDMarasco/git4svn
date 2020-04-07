# Yet Another git Guide for svn Users

## Table of Contents
   * [Yet Another git Guide for svn Users](#yet-another-git-guide-for-svn-users)
   * [Table of Contents](#table-of-contents)
      * [Why (An Intro)?](#why-an-intro)
   * [TODO](#todo)
      * [Squashing Commits - An Example](#squashing-commits---an-example)
      * [What's Not Here](#whats-not-here)
   * [Other Resources](#other-resources)
      * [Learning Git](#learning-git)
      * [Tools and Setup](#tools-and-setup)
      * [Special Thanks](#special-thanks)
      * [TODOs](#todos)
         * [Once back at work](#once-back-at-work)

## Why (An Intro)?
Thanks to the COVID-19 pandemic, I'm stuck at home. My work team is migrating from `svn` to `git` and I was going to put together a brown bag or two for them, but since I'm home I'm able to put a copy on GitHub.

There are many sites out there that cover similar things, but many seem to be "how to migrate a repo" or simple [cheat sheets](https://www.git-tower.com/blog/git-for-subversion-users-cheat-sheet/). I want a simple set of things I can present over a lunch session or two.

## Terminology
We know every technical thing has to have its own jargon and lingo, and there is some overlap between the two. I'd like to make sure we're always on the same page. Here a few key terms and how they apply:
| Term         | `svn`                                                  | `git`                                                                                                                          |
|--------------|--------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| working copy | your local checkout                                    | N/A, but kinda the same                                                                                                        |
| repository   | the One True Copy(TM)                                  | a _copy_ of the codebase; some people (incorrectly) say "_the repository_" to indicate a central copy, _e.g._ the repo on GitHub |
| revision     | snapshot of the state of all files across all branches | snapshot of the file tree at any specific time                                                                                 |
| branch       | another full copy of entire file tree                  | a pointer into a revision                                                                                                      |
| index        | N/A                                                    | the "staging area" between your local file system (working copy-ish) and the repository                                        |

## What is Happening
Many of us learn better with example, so let's provide an example. This is my file tree:
```
LICENSE
README.md
```
I don't have them in a git repository yet, so I will create one. Details omitted, because it's easy to search and not relevant here. Since the files are new to the repository, I need to `git add` them. What actually happens when I do that?
 * `git` beings to create a new revision, called _the index_, and adds the contents of `LICENSE` and `README.md` to it _immediately_.

Why did I emphasise the word _immediately_? Because `svn add` says "from now on, I need to start watching `LICENSE` and `README.md`", while `git add` _stages_ the contents of the files in the index. If I then do `echo FOO >> README.md`, a commit in `svn` would have "FOO" added to the end of the file. In `git`, the `add` adds a snapshot of the file _now_. I'll try to illustrate it a little:
![repo shown with arrows](img/repo_index.png)
After that set of commands, the index has the original file, while the file system has the new "FOO" at the end:
```
$ git diff
diff --git a/README.md b/README.md
index 1a29b06..24b5c0a 100644
--- a/README.md
+++ b/README.md
<extra info removed>
+FOO
```
And if we want to see "how much" has changed:
```
$ git diff --stat
 README.md | 1 +
 1 file changed, 1 insertion(+)
```
Again, **the default of `git diff` tells you the difference between the file system and the index**. This is important, because `git commit` and `svn commit` are very similar, but act differently.

The subversion mindset is "but these files changed, I want them checked in." The git mindset is "only check in the changes I explicitly tell you to." 

# LEFT OFF HERE...
Why? Now, to show you some of the power of the index.
 - example with bouncing between commits for different reasons
 - expand to branches
 - show add -p

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
2. A totally blank line.

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
 * [Dillinger](https://dillinger.io/) an online Markdown editor
 * [Tables Generator](https://www.tablesgenerator.com/markdown_tables) for online table generation
 * [WebGraphviz](http://www.webgraphviz.com/) for online Graphviz graphics
 * [gh-md-toc](https://github.com/ekalinin/github-markdown-toc) for the (offline) generation of the Table of Contents

# TODOs
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

