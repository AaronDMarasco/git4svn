# Yet Another git Guide for svn Users
## Table of Contents
   * [Yet Another git Guide for svn Users](#yet-another-git-guide-for-svn-users)
      * [Table of Contents](#table-of-contents)
      * [Why? (An Intro)](#why-an-intro)
      * [Terminology](#terminology)
         * [References, Refs, Branches, and Tags (Oh My!)](#references-refs-branches-and-tags-oh-my)
      * [What is "The Index?"](#what-is-the-index)
         * [An Index Usage Example](#an-index-usage-example)
            * [How To Fix in Subversion](#how-to-fix-in-subversion)
            * [How to Fix in git (Solution 1)](#how-to-fix-in-git-solution-1)
      * [The Stash](#the-stash)
         * [How to Fix in git (Solution 2)](#how-to-fix-in-git-solution-2)
         * [Another Stash Usage Example](#another-stash-usage-example)
      * [Committing Your Changes - add, fetch, pull, push, etc.](#committing-your-changes---add-fetch-pull-push-etc)
         * [git fetch](#git-fetch)
         * [git merge](#git-merge)
         * [git pull](#git-pull)
         * [git push](#git-push)
         * [git revert](#git-revert)
         * [git checkout](#git-checkout)
            * [Branches - A Diversion](#branches---a-diversion)
         * [git merge (part deux)](#git-merge-part-deux)
      * [Squashing Commits - An Example](#squashing-commits---an-example)
   * [Other Subjects](#other-subjects)
      * [Directed Acyclic Graph](#directed-acyclic-graph)
      * [git help](#git-help)
      * [git status](#git-status)
      * [git grep](#git-grep)
      * [Git Anywhere](#git-anywhere)
      * [git diff](#git-diff)
         * [git difftool](#git-difftool)
      * [git log](#git-log)
      * [git mergetool](#git-mergetool)
      * [git cherry-pick](#git-cherry-pick)
   * [A Day In The Life Of...](#a-day-in-the-life-of)
      * [Create a Branch to Work](#create-a-branch-to-work)
      * [Do Stuff](#do-stuff)
      * [Keep Up-to-Date](#keep-up-to-date)
      * [Wrap It Up](#wrap-it-up)
      * [Clean The Repo](#clean-the-repo)
   * [Special Examples](#special-examples)
      * [Unbreak Your Code](#unbreak-your-code)
         * [Step-By-Step example](#step-by-step-example)
      * [Working Offline](#working-offline)
         * [Before You Leave](#before-you-leave)
         * [On the Road](#on-the-road)
         * [Done with Changes](#done-with-changes)
         * [Importing Your Changes](#importing-your-changes)
   * [What's Not Here](#whats-not-here)
   * [Other Resources](#other-resources)
      * [Learning Git](#learning-git)
      * [Tools and Setup](#tools-and-setup)
      * [Special Thanks](#special-thanks)

## Why? (An Intro)
Thanks to the COVID-19 pandemic, I'm stuck at home. My work team is migrating from `svn` to `git` and I was going to put together a brown bag or two for them, but since I'm doing it from home I'm able to put a copy on GitHub.

There are many sites out there that cover similar things, but many seem to be "how to migrate a repo" or simple [cheat sheets](https://www.git-tower.com/blog/git-for-subversion-users-cheat-sheet/). I want a simple set of things I can present over a lunch session or two.

## Terminology
We know every technical thing has to have its own jargon and lingo, and there is some overlap between the two. I'd like to make sure we're always on the same page. Here a few key terms that we've been using already with svn and how they apply along with a few extra you'll need:
| Term         | `svn`                                                                    | `git`                                                                                                                            |
|--------------|--------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| working copy | your local checkout                                                      | N/A, but kinda the same                                                                                                          |
| repository   | the One True Copy(TM)                                                    | a _copy_ of the codebase with _all history included_; some people (incorrectly) say "_the repository_" to indicate a central copy, _e.g._ the repo on GitHub |
| revision     | snapshot of the state of all files across all branches                   | snapshot of the file tree at any specific time                                                                                   |
| branch       | another full copy of entire file tree                                    | a special type of _reference_ (see below)                                                                                        |
| commit       | save your changes into a new revision for _everybody_ to immediately see | save your changes into a new revision _in your local repository_                                                                 |
| reference    | N/A                                                                      | a pointer into a specific revision                                                                                               |
| index        | N/A                                                                      | the "staging area" between your local file system (working copy-ish) and the repository                                          |

A full reference is available with `git help gitglossary`.

### References, Refs, Branches, and Tags (Oh My!)
As noted above, a revision is a snapshot of _everything_ at a specific time. Each of these snapshots, when combined with their metadata (author, comment, ancestors, etc.), is hashed into a SHA-1 hash to create the unique identifier to label that revision.

| Reference   | Location           | Use                                                                                                               |
|-------------|--------------------|-------------------------------------------------------------------------------------------------------------------|
| `HEAD`      | N/A                | Points to a specific revision in the repository that the localfs is "based on."                                   |
| branch name | `.git/refs/heads/` | Points to the `HEAD` of the given branch. A new commit to this ref will move ("follow") this to the new revision. |
| tag         | `.git/refs/tags/`  | Points to a specific revision. If currently `HEAD` of a branch, it will _not_ move on a new commit.               |

_Tags_ are special references that don't move, similar to subversion's tags. If you `cat` any of the files listed above, _e.g._ `.git/refs/heads/master`, you will see it is simply the 40-hex SHA-1 hash and a newline.

Often the shortened version of the hash is unique enough (7 chars), and you can use "`R^N`" to say "N references before R" (no N means 1). References can be used in _many_ places on the command line and are very useful. For example, if I want to see what files were changed in the last commit, knowing that the most recent revision is always `HEAD`:
```
$ git diff HEAD^ HEAD
# shortened with bash shortcut:
$ git diff HEAD{^,}
$ git diff HEAD{^,} --stat
 README.md | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 62 insertions(+), 29 deletions(-)
$ git diff HEAD{^,} --stat -b -w # ignore whitespace
 README.md | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 55 insertions(+), 22 deletions(-)
```
The `git lg` alias below is very helpful to see history from the command line along with important refs:
```
* 5845e57 - (HEAD -> scratch, origin/scratch) WIP done for now (21 hours ago) <Aaron D. Marasco>
* b0cfc5e - WIP: Need to see those images (22 hours ago) <Aaron D. Marasco>
*   eba6752 - Merge branch 'scratch' of https://github.com/AaronDMarasco/git4svn into scratch (22 hours ago) <Aaron D. Marasco>
|\
| * 725b186 - WIP save to see new images (23 hours ago) <Aaron D. Marasco>
* | a7c7334 - More images (22 hours ago) <Aaron D. Marasco>
* | 564d80d - More images (23 hours ago) <Aaron D. Marasco>
|/
* ef4aec1 - New image with fetch etc (23 hours ago) <Aaron D. Marasco>
...
* 8dc42ff - (origin/master, origin/HEAD, master) Initial commit (3 days ago) <Aaron D. Marasco>
```
What you cannot see here is the colors - all the refs on the side (_e.g._ `564d80d`) are red and the named refs (_e.g._ `origin/scratch`) are in yellow. This makes them easy to identify. You can also see it uses ASCII art to show when two copies of the source code diverged (after `ef4aec1`) and then merged (`eba6752`) because I was creating the images on my local machine while using an online editor for the main document.

## What is "The Index?"
Many of us learn better with example, so let's provide an example. This is my file tree:
```
LICENSE
README.md
```
I don't have them in a git repository yet, so I will create one. Details omitted, because it's easy to search and not relevant here. Since the files are new to the repository, I need to `git add` them. What actually happens when I do that?
 * `git` begins to create a new revision, called _the index_, and adds the contents of `LICENSE` and `README.md` to it _immediately_.

Why did I emphasize the word _immediately_? Because `svn add` says "from now on, I need to start watching `LICENSE` and `README.md`", while `git add` _stages_ the contents of the files _as it is right now_ in the index. If I then do `echo FOO >> README.md`, a commit in `svn` would have "FOO" added to the end of the file. In `git`, **the added "FOO" won't be committed**. I'll try to illustrate it a little:

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

The subversion mindset is "but these **files** changed, I want them checked in." The git mindset is "only check in the **changes** I _explicitly_ tell you to."

This is further illustrated here, along with the `git diff` variation you need to use to see what is _about to be committed_:

![](img/diffs.png)

**This is a major source of confusion for subversion users and it's extremely important in unlocking some of the power of git!**

So many times, you'll see the advice to "just run `git add --all` (or `git commit -a`) to add it all." This is using a halberd when you want a scalpel, but it's the default mindset of a svn user, because that's the only tool they had.

### An Index Usage Example
I've been working for a few hours on a small feature, and I didn't have it in a branch (so I'm working in `master`). My local working copy has about six files changed, but mostly added debug statements and other stuff that I don't want checked in. My coworker asks me to tweak a file with some secret sauce that only I know about and nobody else.

#### How To Fix in Subversion
You probably already have two or three working copies from the same repo, right? So you switch to one of the others, do an `svn update` (more on that later), make the change, and then `svn commit`.

#### How to Fix in git (Solution 1)
You fix the two magic files that needed to be fixed. A changeset is effectively a series of modifications (patches) to a file, and you can run `git add -p` which is a special mode of `add`ing that will present to you _each **p**atch_ asking if it should be added to the index. You know certain files don't need to ask, so you can either tell it not to ask any more about that file ("`d`") or just give it the two files on the command line: `git add -p file1 file2`. If you had no unrelated changes in the files, you could've skipped the `-p` but we're going to say you had debug enabled at the top of the file, and you don't want that committed. When you're done:
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
What would this do? Three weeks from now, you can be working in submodule X. You already have a snippet that enables all the debugging that you can `apply` automatically at any time!
```
$ git stash list
# find the one you want, let's say it's stash@{3}
$ git stash apply stash@{3}
# your working copy now has debug enabled on submodule X!
```

If you didn't catch the subtle difference, `pop` is a combination of `apply` and then, if successful, a `drop` which I didn't cover. So `apply` leaves the revision in the stash.

## Committing Your Changes - add, fetch, pull, push, etc.
This is another sticky point for svn users, so let's talk about what happens when. As a reminder:

![](img/repo_index_origin.png)

`origin` is the default name for an upstream ("remote") repository; the "main" copy hosted on a corporate server or GitHub, etc. It's where you originally "cloned" from previously.

Earlier we talked about `git add` and how to put your changes into the index. If you then `git commit` them, they are put into _your_ repository. In subversion, it's _everybody's_ repository, so you know you were always working with the latest code (because you were forced to `svn update` before you could commit if you weren't!). In git, you're also responsible for keeping your _entire repository_ synchronized with other(s).

| Command    | Usage                                                                                           |
|------------|-------------------------------------------------------------------------------------------------|
| `add`      | adds a file to the index to be _committed_ (covered above in index discussion)                  |
| `commit`   | writes a set of changes into the repository as a _revision_ (covered above in index discussion) |
| `clone`    | copies a repository from a remote location (not covered here)                                   |
| `fetch`    | synchronizes the database from a remote repository _to_ the local (read-only)                   |
| `merge`    | merges two _revisions_ into a single _revision_ (not _always_ a branch!)                        |
| `pull`     | combines `fetch` and `merge` into a single command                                              |
| `push`     | synchronizes the database from a local repository _to_ the remote (write-only)                  |
| `checkout` | copies file(s) from the repository to the localfs                                               |

_This section's examples and text assumes you set `autosetuprebase` as noted in the [Setup section below](#tools-and-setup)._

`git pull` is _roughly_ equivalent to `svn update` and is the command you will likely use the most. However, for completeness, let's examine the two underlying commands because they can be useful in their own.

![](img/fetch_etc.png)

### git fetch
> git-fetch - Download objects and refs from another repository

This will read all the changes from a remote repository (by default `origin`) and replicate them in the local repository. These revisions are _now all available_ immediately in our repository. _However_ they are _not_ expressed in our local filesystem. If I was working yesterday on a branch named `branchA`, and I pushed it to the server, the one revision `24f3b8fecf` in my repository is _referenced_ as my branch `branchA` and also `origin/branchA`. However, if my coworker made some changes this morning and pushed them, I just received them in my repository. `branchA` on _my_ repository has not changed, but `origin/branchA` is now `fcbd2855f`. An example of this:
```
$ git status
On branch branchA
Your branch is behind 'origin/branchA' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean
```
![](img/after_fetch.png)

### git merge
> git-merge - Join two or more development histories together

This command is usually used for another reason (which we'll touch on, but as an svn user, you already know). But, as noted above, `git merge` will merges two _revisions_ into a single _revision_ and we want to merge "our" `branchA` (`24f3b8fecf`) with "their" `branchA` (`origin/branchA` or `fcbd2855f`). So to do that (assuming the local branch is already in `branchA`), we use the same merge command, but the source of the merge looks special (the target is the current `HEAD`):
```
$ git merge origin/branchA
```
![](img/after_merge.png)

### git pull
> git-pull - Fetch from and integrate with another repository or a local branch

So that leaves us with `git pull`. It's basically a shortcut - it is _mostly_ equivalent to `git fetch && git merge origin/<branchname>`. As noted above, it is what you will do 99% of the time, and can be treated as a rough equivalent of `svn update`. The difference is that if the merge fails, the fetch did happen, so you can locally examine what is wrong, _e.g._:
```
$ git diff origin/branchA README.md
```
Because (don't forget) your local repository has _all the information_, and the _reference_ to what the upstream has for `branchA` is `origin/branchA`.

_Note_: I'm hand-waving here a bit, because I hope you set `autosetuprebase` as noted in the [Setup section below](#tools-and-setup). If you did, then it's actually doing a "`git rebase`" in between the `fetch` and `merge`. This makes our repo a lot cleaner and easier to follow. Essentially, it "rolls back" all your changes since you last synchronized to the upstream. Then, it updates your branch to match what is upstream. Once that is complete, it re-applies your changesets but based off of the "new" branch. If this is able to happen cleanly, then a merge revision was never needed. It will clearly tell you when it is doing it as well:
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
> git-push - Update remote refs along with associated objects

This command simply sends your latest changes to the remote repository. If the remote has "moved on" past what your repo "knew" about, it will fail and require you to `pull` again. There are server-side hooks that may also reject your changes for various reasons (branch control, etc.). There is no equivalent in subversion, because `commit` handled that. **Don't forget to do this if you are expecting somebody else to see your code!**

### git revert
> git-revert - Revert some existing commits

A "revert" is explicitly _an additional revision_ that will undo a previous revision. To maintain history, both the insertion and the deletion remain in the repo. If your code was ever pushed to a remote, this is what you should be doing. **It does not rollback to a previous revision.** If you never pushed the change and you want to rollback, there are tricks you can do with `git checkout` that can be found online.

### git checkout
> git-checkout - Switch branches or restore working tree files

This command is another source of confusion because subversion's `checkout` is _totally_ different (it's the same as `git clone`). As shown in the illustration above, `git checkout` checks _file(s)_ out of the repo. The normal 99.44% use case is to change what branch you are currently working on:
```
$ git checkout master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.
$ git checkout branchA
Switched to branch 'branchA'
Your branch is up to date with 'origin/branchA'.
```
When you want to create a new branch, you can add `-b` to the command and it will branch from wherever you are, including a "dirty" workspace.

But yes, you can `checkout` a single file (and it will auto-`add`, which I don't like).
```
$ git checkout master README.md
$ git status
On branch branchA
Your branch is up to date with 'origin/branchA'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   README.md

```
This also covers the "just throw away everything I did to this file and bring it back to what's in the repo" scenario (equivalent to `svn revert`):
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
2. After code successfully compiled. Then you can always get back to the working state. **Do this _before_ trying to clean anything up.**
3. When you're about to experiment with an alternative option with something.

It's difficult to emphasize how much of a life-changer this can be until you actually start using it. Especially when you combine it with `git diff` to see the differences.

### git merge (part deux)
There are actually three kinds of merges, and you should be familiar with them because they make things a lot easier to follow if used properly.
1. The first kind of merge is a "fast-forward" merge:
![](img/after_fetch.png)
Since there are no changes in the local repository between what the upstream considers `branchA` and what we have as `branchA`, we can simply "fast forward" the reference to the new revision:
![](img/after_merge.png)
```
$ git pull
...
Fast-forward
 README.md | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 62 insertions(+), 29 deletions(-)
Current branch branchA is up to date.
```
If you think this is what should happen, you can use `git merge --ff-only` to ensure that's the case. If, for some reason, you find this unacceptable, you can use the `--no-ff` flag.

2. The second kind of merge is a "standard" merge:
![](img/remote_changes.png)
For this, both repositories (ours and the remote) have new revisions that we both consider part of `branchA`, so we need to create a new revision that merges them. (Again, this wouldn't happen with `autosetuprebase`, but you could imagine two different branches instead; it's the same.)
![](img/remote_merged.png)
Of course, this still needs to be _pushed_ as noted above.
When performing this kind, I highly recommend using the `--no-commit` flag so you can review what the merge _would have done_ and then manually `git commit`; it will autopopulate the commit message properly for a merge.
3. The last kind of merge is a "squashed" merge:
![](img/squashed_merge.png)
In this image, there's a dotted arrow between `7589a237e` and `2c57a9eec` because the merge happened and all the data is there, but the metadata _doesn't_ record it. The log message is (by default) a culmination of all the changesets in between. At this point, all the "my_work" and revisions `7589a237e` are now _orphans_ and are subject to garbage collection in the future. A much more detailed example of squashed merges (I'm a huge fan of them) is below.

## Squashing Commits - An Example
Squashing commits is a useful way to keep related changes within a single changeset for later examination. There are good arguments both _for_ squashing ("no need to see how the sausage was made and these intermediate changesets that make no sense on their own") and _against_ ("the way this document was tweaked is unique enough that I might want to reference that specific changeset later").

The following is an example of merging in a branch "`feature--cool-intro`" from the top-level of the repository:
* `git checkout master`

Ensure latest sync with server:
* `git pull --rebase`
* `git merge --no-commit --squash --no-ff feature--cool-intro`

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

# Other Subjects
This is stuff that I think is important / useful but I couldn't fit it elsewhere.

## Directed Acyclic Graph
AKA "DAG" is how the revisions are related to each other - see [Wikipedia](https://en.wikipedia.org/wiki/Directed_acyclic_graph) and the `git dag` add-on mentioned [elsewhere](#tools-and-setup). For example, the illustrations shown for "[git fetch](#git-fetch)" and "[git merge](#git-merge)" show DAGs.

## git help
> git-help - Display help information about Git

This command is how you access the documentation for git, _e.g._:
* `git help diff`
* `git help commit`
* `git help checkout`
* `git help gitglossary`
* `git help`

## git status
> git-status - Show the working tree status

This one is used _all the time_ and you should probably scan through `git help status` to see how powerful it can be.
Some reminders:
 * `--stat` can show _roughly_ how much you've deviated from what's currently checked in
 * With no parameters, it shows the _entire_ repo, so you often want to give it a path (or just `.`)

## git grep
> git-grep - Print lines matching a pattern

If you're on a system that you cannot get `ripgrep` installed, then `git grep` is the next best thing. It's just like `grep -r` but will use all your available CPUs in parallel to search the repository database, which is insanely faster. By default it will only search actively-monitored files, but you can also ask it to search `--untracked` files as well. I cannot emphasize enough how useful this capability is.

The options I prefer for `grep` are listed [in the config info below](#tools-and-setup) so I can just do `git g <expression>`.

## Git Anywhere
Because a repository is "only" a subdirectory `.git` at the top-level of a directory tree, you can put a git repository _anywhere_ you think having history and the ability to rollback would be useful. Some examples:
 * `/etc/` before upgrading some RPMs
 * Any configuration directory before you make a bunch of changes
   * Don't forget that Windows 10 has embedded Ubuntu with git available
 * Inside a subversion repo (if you're stuck in svn and don't want to use the built-in git-svn capabilities)
   * If doing this, it's useful to `git tag` svn revisions

Then when you're done with whatever "risky" thing you were doing, simply `rm -rf .git`.

## git diff
> git-diff - Show changes between commits, commit and working tree, etc

Yes, it was tangentially covered above, but you really need to play with it to start to understand the power. You can effectively get a diff of nearly _anything_ across all space and time. You can compare a file in one branch to another file (different name) in another branch, etc.

### git difftool
> git-difftool - Show changes using common diff tools

If you'd prefer a graphical interface, you can configure one and then use `git difftool` to launch it. See below for configuring it for `meld`. Also supports `--cached` and any other `git diff` options.

## git log
> git-log - Show commit logs

This tool has many amazing options, like `--since` and `--before/--after`, _e.g._ `git log --since="yesterday"` or `git log --since="last month"` or even "`last tues`"

The configuration below has two aliases with `git log` options - `git lg` (shown before) and `git last` which shows the last change.

## git mergetool
> git-mergetool - Run merge conflict resolution tools to resolve merge conflicts

When a merge fails, subversion leaves you high and dry. Git lets you define a graphical tool (See below for configuring it for `meld`) to launch to attempt to fix the broken merge.

## git cherry-pick
> git-cherry-pick - Apply the changes introduced by some existing commits

This is very helpful when you are deep in a branch for weeks and somebody tells you, "in my branch, I fixed that really important bug that you've been hitting."
```
$ git fetch
$ git lg origin/helpful_branch
$ git cherry-pick -x <ref> # if last, can simply be origin/helpful_branch
```
This fixes that one important issue without a full merge of the other branch, putting that off until you are ready later. The `-x` records its source for later reference.

# A Day In The Life Of...
* See also: `git help giteveryday`

What you'll need to do every day is covered elsewhere within this document, but let's reiterate one more time the workflow that will happen 90% of the time. This assumes a multi-day change that _might_ be peer-reviewed, etc.:

## Create a Branch to Work
```
$ git checkout master  # switches our localfs to master (or whatever the main development branch is named)
$ git pull  # always ensure you have the latest
$ git checkout -b my_branch  # the -b tells it to make the new branch from current revision
$ git push --set-upstream origin my_branch
```
You don't need to remember that last command; I don't myself. If you try to do a "regular" push, `git` tells you exactly what to do:
```
$ git push
fatal: The current branch my_branch has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin my_branch
```

## Do Stuff
```
# 10:
# Do some work
$ git diff
$ git commit  # remember - this is NOT visible by coworkers
# goto 10
```
You probably want to throw in a `git push` at least once a day; hard drives fail sometimes.

## Keep Up-to-Date
If you worry about missing major changes in `master`, it's a good idea to occasionally bring it into your branch. This helps minimize your conflicts later down the road, and ensures the code you test is "more realistic."
```
$ git fetch
$ git merge origin/master
```
**OR**
```
$ git checkout master
$ git pull --rebase
$ git checkout my_branch
$ git merge master
```
The latter ensures your local `master` is also in sync; this is useful if you want to keep an eye on your differences with `git diff master` as part of your development cycle.

## Wrap It Up
It's been a few days, and you're done. Your work has possibly even been peer reviewed, run through a test harness, etc.
```
$ git checkout master
$ git pull --rebase
$ git merge --no-commit my_branch  # might be --squash, --no-ff, etc...
$ git difftool  # Make sure everything looks sane
$ git commit
$ git push
```
As noted above, we have options when merging; we need to decide if we will have a standard merge with every revision of `my_branch` or if we want to throw away the intermediate steps (squashed merge).

## Clean The Repo
There is now a branch we no longer care about in our repository, which isn't a big deal. The bigger concern is it's on the central copy we all share, and that can get cluttered very easily. Especially if we have a CI/CD infrastructure like Jenkins operating on _every_ branch in the repo!
```
$ git branch -d my_branch
Deleted branch my_branch (was 36fa99f).
$ git push --delete origin my_branch
To https://github.com/AaronDMarasco/git4svn.git
 - [deleted]         my_branch
```

If the squash was merged, or for some other reason you want to abandon the branch without merging, `git` will try to protect you and remind you one last time how to get to that revision:
```
$ git branch -d my_branch
warning: deleting branch 'my_branch' that has been merged to
         'refs/remotes/origin/my_branch', but not yet merged to HEAD.
Deleted branch my_branch (was 3fb9dd3).
```
At this point, I could still `git checkout 3fb9dd3` to get it back. It won't be there forever; there is a garbage collector.

# Special Examples
## Unbreak Your Code
If something broke and you're not sure where, you want to use `git bisect`. In subversion, if you knew `r200` was broken, and you're sure that `r100` worked, you could manually split the problem space and say "let's check `r150`!" This is impossible in git when there's no way to figure out what is halfway between `6fb166f` and `e29fff0` without more metadata. That's where `git bisect` comes in.

This example is fairly automatic; if you can simply run a test script to say good/bad, then it can be fully automated! If not, you can manually tell `git` "OK, this one worked" etc. You can find more resources online or under `git help bisect`.

### Step-By-Step example
Note: This is a real example with hashes from a private git repo and anonymized

1. Write a script that will be able to tell if a specific version works or not. Here's my example script that I manually tested on the known good and known bad. Basically, my program would crash nearly immediately as the failure, so I launch it in the background and then check on it in five seconds.
```
#!/bin/bash -x
set -e
cd common/build # git bisect must be run from the top-level of the repo
make -j distclean
../bootstrap.sh
make -j
make check
./myprog &
sleep 5
jobs %% # This will fail if it is not still running
kill -9 %%
wait
```

2. Determine where you want to start and end the search. In my example, I know that my branch "`adm`" has something broken, while "`master`" is good (_n.b._ `master` hasn't changed since I branched off).

3. Run it!
```
user@host$ git bisect start adm master
Bisecting: 29 revisions left to test after this (roughly 5 steps)
[3b30109-fullhash] [commit message]
user@host ((3b30109...)|BISECTING)$ git bisect run ./test_script.sh
...
Bisecting: 7 revisions left (roughly 3 steps)
...
[hash] is the first bad commit
commit [hash]
Author, Date, etc.
...
bisect run success
```
Be sure to check the help with `git help bisect` for lots of interesting options, like the ability to skip a certain revision if it is _totally_ unusable but independently of your actual problem. For example, after running the above, I added "`|| exit 125`" to the `make` calls to indicate that this revision should be skipped but _not_ blamed because I was also messing with `Makefile`s previously. I could have also forced the working `Makefile` into every check by adding `git checkout adm Makefile` to my testing script.

4. Fix it
You now know what was broken, and you fix it. But you now have a patch for a revision from three weeks ago - what to do with that?
Make a branch from the first broken (`git checkout -b my_hotfix`) and then commit the patch (`git commit -am "Hotfix"`). Switch back to the original branch (`git checkout adm`) and then bring in the patch (`git merge --no-commit my_hotfix ; git merge --reset`). From there, manipulate as needed. When done, delete the temporary branch (`git branch -D my_hotfix`) since nobody needs it / cares any more.

## Working Offline
This section is fairly esoteric; you might say "`git` is always offline unless I tell it to `fetch` or something." That would be correct, but sometimes you might have to work only with a subset of the repository; for example you don't want to have the _entire_ repository's history taking up space in your dropbox. It was written as an example where you go on a trip to a customer location and find a bug in the code that you can easily fix. "What now?"

**Note**: There's nothing special about _your_ copy of the branch. If you didn't `bundle` before your trip, somebody back at the office can drop you a bundle!

### Before You Leave
1. Decide which branch you want your changes to be based on. In this example, we'll say "`my_branch`".
2. Back up the branch using "`git bundle`":
    1. `git bundle create my_branch.bundle my_branch`
    2. The `my_branch.bundle` is the filename to dump to
    3. The "`my_branch`" is _any_ git reference, in this case the `HEAD` of your chosen branch
        * If you wanted to make sure you had the latest, you can add another "`master`" to the end if you'd like
        * You can add as many branches as you might need; feel free to tweak as needed and see the filesize trade-off
3. Check what you've done
    * `git bundle list-heads my_branch.bundle`
        * Should show your current `HEAD`'s hash with `refs/heads/my_branch`
        * Test run the next section somewhere
4. Upload `my_branch.bundle` to dropbox, USB key, etc.

### On the Road
1. Download `my_branch.bundle` to working PC
2. Clone a new working copy from the bundle
    1. `git clone /tmp/my_branch.bundle`
        * It's OK if it says something like "`warning: remote HEAD refers to nonexistent ref, unable to checkout.`"
    2. `cd my_branch`
    3. `git branch -av`
        * Should show all refs you bundled, _e.g._ `my_branch` and `master`
    4. `git checkout my_branch`
        * Now all your files should be there
3. Make changes / do work
    * `git commit` to your heart's content

### Done with Changes
1. Save all your changes as a _new_ bundle
    * `git bundle create my_branch_diff.bundle origin/my_branch..HEAD`
        * The resulting file will be much smaller - only the diffs you've made!
        * Again, the last argument might include other things. If space is not an issue, you can just put the branch name again and get them all.
2. Verify you've got what you think
    * Compare the hash from `git log -1` to `git bundle list-heads my_branch_diff.bundle`
3. Upload `my_branch_diff.bundle` to dropbox, USB key, etc.

**Warning**: If you used `git stash` and didn't save the final results into a **named** branch and then `bundle`, those changes **will be lost**!

### Importing Your Changes
1. Download `my_branch_diff.bundle` to your machine
2. Change directory to your "daily" working copy
3. Make sure your workspace is clean
4. `git bundle unbundle my_branch_diff.bundle`
    * Note the reference it gave you here, _e.g._ `5bab64db350fcf45033481191a976164e8551538 HEAD`
5. `git merge --no-commit 5bab64db350fcf45033481191a976164e8551538`
    * If there were no changes since you left, it will say "Fast-forward" and you're done; `git push` to the server
    * If there were changes, you are in a "normal" merge situation to be handled appropriately

# What's Not Here
There are some other things I've already documented on an internal wiki for my team that may interest public users; treat this as a breadcrumb that you might want to search the internet for more information:
* ~~Using `git bisect` to automate finding where something is broken~~
  * ~~This is important because unlike svn, git revisions are unpredictable, so it is non-trivial to say "I want a revision halfway between then and now"~~
* ~~Using `git bundle` when traveling and needing a minimal set of files with you~~

Also, I just didn't know where to fit it - a `remote` can be _any git repository_, which includes a clone in another directory on the local filesystem!

# Other Resources
## Learning Git
I started learning git back in 2015, and I noted that the following sites were great help, and I highly recommend them still:
 * A [one-hour preview talk](https://www.youtube.com/watch?v=8dhZ9BXQgc4) from 2007 by Randal Schwartz (of perl fame)
   * Great intro, including around 3:20 when he simply asks "What is git?" and notes it tracks **"Changes to a tree of files over time"**
  * Ignore what he says about `git rebase` - in my experience, it's rarely used
* [The Thing About Git](https://tomayko.com/blog/2008/the-thing-about-git) by Ryan Tomayko was a good intro to the usage side
* [Think Like (a) Git](http://think-like-a-git.net/) by Sam Livingston-Gray was an **excellent** site that I used that really helped me understand the (graph) theory, the way it all comes together
* [Git Immersion](http://gitimmersion.com/index.html) by Neo Innovation is a **great** hands-on lab-like approach to learning

## Tools and Setup
In my previous office, we had "free reign" so I was able to use any tools I wanted. In a perfect world, I'd still have access to them all:
 * `git dag` - from [git-cola](https://git-cola.github.io/) (also has a nice diff viewer)
 * `git lg` - an alias I use daily - possibly [from here](https://coderwall.com/p/euwpig/a-better-git-log) and old notes of mine are below
 * [Powerline](https://github.com/powerline/powerline) looks great (but I've had problems with it if your git repo is on an NFS mount, _e.g._ under your `/home/` in an enterprise environment)
   * `mkdir ~/.config/powerline`
   * `cp /etc/xdg/powerline/config.json ~/.config/powerline/`
   * `vim ~/.config/powerline/config.json`
     * Change `shell:theme` from `default` to `default_leftonly`
 * (Manual) Bash prompt support
   * Found in various locations but part of git's "contributed" - see [this git page](https://git-scm.com/book/id/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Bash) for more
   * Source is [here](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh)
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
* You might want to set your "grep" settings as well:
  * `git config --global grep.lineNumber true` - makes it easy to copy-paste file names and jump to the line in editors
  * `git config --global grep.extendedRegexp true` - "better" regex support
  * `git config --global grep.patternType perl` - "best" regex support
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
