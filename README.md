# Yet Another git Guide for svn Users

## Table of Contents
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
Thanks to the COVID-19 pandemic, I'm stuck at home. My work team is migrating from `svn` to `git` and I was going to put together a brown bag or two for them, but since I'm doing it from home I'm able to put a copy on GitHub.

There are many sites out there that cover similar things, but many seem to be "how to migrate a repo" or simple [cheat sheets](https://www.git-tower.com/blog/git-for-subversion-users-cheat-sheet/). I want a simple set of things I can present over a lunch session or two.

## Terminology
We know every technical thing has to have its own jargon and lingo, and there is some overlap between the two. I'd like to make sure we're always on the same page. Here a few key terms that we've been using already with svn and how they apply:
| Term         | `svn`                                                                    | `git`                                                                                                                            |
|--------------|--------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| working copy | your local checkout                                                      | N/A, but kinda the same                                                                                                          |
| repository   | the One True Copy(TM)                                                    | a _copy_ of the codebase; some people (incorrectly) say "_the repository_" to indicate a central copy, _e.g._ the repo on GitHub |
| revision     | snapshot of the state of all files across all branches                   | snapshot of the file tree at any specific time                                                                                   |
| branch       | another full copy of entire file tree                                    | a pointer into a revision                                                                                                        |
| commit       | save your changes into a new revision for _everybody_ to immediately see | save your changes into a new revision _in your local repository_                                                                 |
| index        | N/A                                                                      | the "staging area" between your local file system (working copy-ish) and the repository                                          |

## TODO: Add reference / refs and put somewhere

## What is "The Index?"
Many of us learn better with example, so let's provide an example. This is my file tree:
```
LICENSE
README.md
```
I don't have them in a git repository yet, so I will create one. Details omitted, because it's easy to search and not relevant here. Since the files are new to the repository, I need to `git add` them. What actually happens when I do that?
 * `git` beings to create a new revision, called _the index_, and adds the contents of `LICENSE` and `README.md` to it _immediately_.

Why did I emphasise the word _immediately_? Because `svn add` says "from now on, I need to start watching `LICENSE` and `README.md`", while `git add` _stages_ the contents of the files _as it is right now_ in the index. If I then do `echo FOO >> README.md`, a commit in `svn` would have "FOO" added to the end of the file. In `git`, the `add` adds a snapshot of the file _now_. I'll try to illustrate it a little:

![](img/repo_index.png)

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
And if we want to see "how much" has changed (compared to what would be committed):
```
$ git diff --stat
 README.md | 1 +
 1 file changed, 1 insertion(+)
```
Again, **the default of `git diff` tells you the difference between the file system and the index**. This is important, because `git commit` and `svn commit` are very similar, but act differently.

The subversion mindset is "but these **files** changed, I want them checked in." The git mindset is "only check in the **changes** I explicitly tell you to."

This is further illustrated here, along with the `git diff` variation you need to use to see what is _about to be committed_:

![](img/diffs.png)

**This is a major source of confusion for subversion users and it's extremely important in unlocking some of the power of git!**

So many times, you'll see the advice to "just run `git add --all` (or `git commit -a`) to add it all." This is using a halberd when you want a scalpel, but it's the default mindset of a svn user, because that's the only tool they had.

### An Index Usage Example
I've been working for a few hours on a small feature, and I didn't have it in a branch (so I'm working in `master`). My local working copy has about six files changed, but mostly added debug statements and other stuff that I don't want checked in. My coworker asks me to tweak a file with some secret sauce that only I know about and nobody else.

#### How To Fix in Subversion
You probably already have two or three working copies from the same repo, right? So you switch to one of the others, do an `svn update` (more on that later), make the change, and then `svn commit`.

#### How to Fix in git (Solution 1)
You fix the two magic files that needed to be fixed. You run `git add -p` which is a special mode of adding that will ask you _each **p**atch_ if it should be added to the index. You know certain files don't need to ask, so you can either tell it not to ask any more about that file ("`d`"") or just give it the two files on the command line, `git add -p file1 file2`. If you had no unrelated changes in the files, you could've skipped the `-p` but we're going to say you had debug enabled at the top of the file, and you don't want that committed. When you're done:
* `git diff --cached` shows you _only_ the changes needed to fix your coworker's problem
* `git commit` will commit _only_ those changes, with all your other files still modified

Hopefully this has shown you some of the power of the index. But what if somebody made changes on the central repo, and you haven't been keeping up to date? Then your `push` might fail. 

## The Stash
#### How to Fix in git (Solution 2)
Another useful tool in the git toolbox is _The Stash_. It is a place where you can stash changes temporarily for various reasons. In this example, it's because you need to make changes but didn't get the latest "official" code (see below for more).
```
$ git stash save "need to fix something"
Saved working directory and index state On master: need to fix something
$ git stash list
stash@{0}: On master: need to fix something
stash@{1}: WIP on master: 2ca9eec diffs image
```
The stash can be thought of as a special branch that stores changesets that are _only available to the local repository_. That means they won't ever leave that working copy. So we've saved off our work (all that ghetto debugging with `printf` etc.) and now have a clean version of `master` again!
```
$ git pull
# code code code and fix the problem
$ git diff
$ git commit -am "Fixed the doohickey again"  # git commit -a is NOT RECOMMENDED
$ git push
$ git stash pop
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
Dropped refs/stash@{0} (ed5e73f01a6c0de518cdc24a9cf2da4dd7a6fff5)
```

### Another Stash Usage Example
See there that `stash@{0}` is a revision? It _was_ `ed5e73f01a6c0de518cdc24a9cf2da4dd7a6fff5`, but now it's gone. Since a revision is _roughly_ a changeset, you can actually `apply` it instead and it will stay in there. So you could actually do something like this:
```
# write code to enable debug mode in a submodule
$ git stash save "Enable debug mode in submodule X"
```
What would this do? Three weeks from now, you can be working in submodule X. You already have a snippet that enables all the debugging that you can apply automatically at any time!
```
$ git stash list
# find the one you want, let's say it's stash@{3}
$ git stash apply stash@{3}
# your working copy now has debug enabled on submodule X!
```

## Committing Your Changes - add, fetch, pull, push, etc.
This is another sticky point for svn users, so let's talk about what happens when. As a reminder:

![](img/repo_index_origin.png)

`origin` is the default name for an upstream ("remote") repository; the "main" copy hosted on a corporate server or GitHub, etc. It's where you originally "cloned" from above.

Earlier we talked about `git add` and how to put your changes into the index. If you then `git commit` them, they are put into _your_ repository. In subversion, it's _everybody's_ repository, so you know you were always working with the latest code (because you were forced to `svn update` before you could commit if you weren't!).

## TODO: Sort / rearrange table to sections below
Terminology:
| Command    | Usage                                                                          |
|------------|--------------------------------------------------------------------------------|
| `checkout` | copies file(s) from the repository to the localfs                              |
| `add`      | adds a file to the index to be _committed_                                     |
| `commit`   | writes a set of changes into the repository as a _revision_                    |
| `fetch`    | synchronizes the database from a remote repository _to_ the local (read-only)  |
| `merge`    | merges two _revisions_ into a single _revision_ (not _always_ a branch!)       |
| `pull`     | combines fetch and merge into a single command                                 |
| `push`     | synchronizes the database from a local repository _to_ the remote (write-only) |

_This assumes you set `autosetuprebase` as noted in the Setup section._

`git pull` is _roughly_ equivalent to `svn update` and is the command you will likely use the most. However, for completeness, let's examine the two underlying commands because they can be useful in their own.

![](img/fetch_etc.png)

### git fetch
This will read all the changes from a remote repository (by default `origin`) and replicate them in the local repository. These revisions are _now all available_ immediately in our repository. _However_ they are _not_ expressed in our local filesystem. If I was working yesterday on a branch named `branchA`, and I pushed it to the server, the one revision `24f3b8fecf` in my repository is _referenced_ as my branch `branchA` and also `origin/branchA`. However, if my coworker made some changes this morning and pushed them, I just received them in my repostory. `branchA` on _my_ repository has not changed, but `origin/branchA` is now `fcbd2855f`. An example of this:
```
$ git status
On branch branchA
Your branch is behind 'origin/branchA' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean
```
![](img/after_fetch.png)

### git merge
This command is usually used for another reason (which we'll touch on, but as an svn user, you already know). But, as noted above, `git merge` will merges two _revision_ into a single _revision_ and we want to merge "our" `branchA` (`24f3b8fecf`) with "their" `branchA` (`origin/branchA` or `fcbd2855f`). So to do that (assuming the local branch is already in `branchA`), we use the same merge command but the "target" of the merge looks special:
```
$ git merge origin/branchA
```
![](img/after_merge.png)

### git pull
So that leaves us with `git pull`. It's basically a shortcut - it is _mostly_ equivalent to `git fetch && git merge origin/<branchname>`. As noted above, it is what you will do 99% of the time, and can be treated as a rough equivalent of `svn update`. The difference is that if the merge fails, the fetch did happen, so you can locally examine what is wrong, _e.g._:
```
$ git diff origin/branchA README.md
```
Because (don't forget) your local repository has _all the information_.
_Note_: I'm handwaving here a bit, because I hope you set `autosetuprebase`. If you did, then it's actually doing a "`git rebase`" in between the `fetch` and `merge`. This makes our repo a lot cleaner and easier to follow. Essentially, it "rolls back" all your changes since you last synchronized to the upstream. Then, it updates your branch to match what is upstream. Once that is complete, it re-applies your changesets but based off of the "new" branch. If this is able to happen cleanly, then a merge revision was never needed. It will clearly tell you when it is doing it as well:
```
$ git pull --rebase  # This is your default if you set autosetuprebase
remote: Enumerating objects: 8, done.
remote: Counting objects: 100% (8/8), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 6 (delta 4), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (6/6), done.
From https://github.com/AaronDMarasco/git4svn
   eba6752..c44bf7f  branchA    -> origin/branchA
First, rewinding head to replay your work on top of it...
Applying: Image tweaked
```

### git push
This command simply sends your latest changes to the remote repository. If the remote has "moved on" past what your repo "knew" about, it will fail and require you to `pull` again. There are server-side hooks that may also reject your changes for various reasons (branch control, etc.).

### git checkout
This command is another source of confusion because subversion's `checkout` is _totally_ different (it's the same as `git clone`). As shown in the illustration above, `git checkout` checks _file(s)_ out of the repo. The normal 99.44% use case is to check out a branch to work on. When you want to create a new branch, you can add `-b` to the command and it will branch from wherever you are, including a "dirty" workspace. But yes, you can `checkout` a single file (and it will auto-`add`, which I don't like).
```
$ git checkout master README.md
$ git status
On branch branchA
Your branch is up to date with 'origin/branchA'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   README.md

```
This also covers the "just throw away everything I did to this file and bring it back to what's in the repo":
```
$ git checkout -- README.md
$ git status
On branch branchA
Your branch is up to date with 'origin/branchA'.

nothing to commit, working tree clean
```

#### Branches - A Diversion
Branching is _yet another_ paradigm shift that you should embrace. With subversion, a new branch meant you sacrificed a ton of disk space and had to wait while things were copied, etc. Then when you re-build, all the files are new so `make` runs forever. In git, a branch is a 41-byte file because it's simply a _reference_ into the repository at a certain revision. This is why they are often referred to as "lightweight" and branching is _extremely encouraged_. Because of the decentralized nature of git, your branches are **unknown to anybody else unless you `push` them** to a remote repository. This means you can make branches for the tiniest of things if you think you would need to rollback. **You should almost always be working in a branch** even if it is local-only. You can always merge it back into the mainline development on your schedule and with your sanitized notes (see "squashed commits" elsewhere). For example, you may want to commit to your branch:
1. Hourly. Seriously, you can then `diff` and see what you changed in the past hour.
2. After code successfully compiled. Then you can always get back to it. **Do this _before_ trying to clean anything up.**
3. When you're about to experiment with an alternative option with something.

It's difficult to emphasize how much of a life-changer this can be until you actually start using it. Especially when you combine it with `git diff` to see the differences.

### git merge (part deux)
There are actually three kinds of merges, and you should be familiar with them because they make things a lot easier to follow if used properly.
1. The first kind of merge is a "fast-forward" merge:  
![](img/after_fetch.png)  
Since there are no changes in the local repository between what the upstream considers `branchA` and what we have as `branchA`, we can simply "fast forward" the reference to the new revision:  
![](img/after_merge.png)  
2. The second kind of merge is a "standard" merge:
![](img/remote_changes.png)  
For this, we both have changes, so we need to create a new revision that merges them. (Again, this wouldn't happen with `autosetuprebase`, but you could imagine two different branches instead; it's the same.)
![](img/remote_merged.png)  
Of course, this still needs to be _pushed_ as noted above.
3. The last kind of merge is a "squashed" merge:
![](img/squashed_merge.png)  
In this image, there's a dotted arrow between `7589a237e` and `2c57a9eec` because the merge happened and all the data is there, but the metadata _doesn't_ record it. The log message is (by default) a culmination of all the changesets in between. At this point, all the "my_work" and revisions `7589a237e` are now _orphans_ and are subject to garbage collection in the future. A much more detailed example of squashed merges (I'm a huge fan of them) is below.

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

# What's Not Here
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
 * [gh-md-toc](https://github.com/ekalinin/github-markdown-toc) for the (offline) generation of the Table of Contents
 * [Tables Generator](https://www.tablesgenerator.com/markdown_tables) for online table generation
 * [WebGraphviz](http://www.webgraphviz.com/) for online Graphviz graphics

# TODOs
 * Anywhere
* Speculative / trial branches super light weight
* `git add -p`
* `git grep`
* git diff - nearly anything
* The Index
* repo vs repo vs repo vs remotes
* Squashing and FF
* cherry-pick
* refs
 ### Once back at work
* Name of other prompt program
* update vs fetch vs pull

