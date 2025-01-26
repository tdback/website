+++
title = 'Switching To Hugo: Part One'
description = 'The reasons why I made the switch to Hugo.'
date = '2024-12-18T07:22:35-05:00'
draft = false
+++

*This post is part one in a two-part series on switching my website to
[Hugo](https://gohugo.io). It covers my reasoning behind making the switch. For
the technical details on hosting my website, read
[part two](/posts/switching-to-hugo-two/).*

# A Re-Introduction
Hello friends, and welcome [back] to my blog! It has been quite some time since
my last post, and I thought I'd take a moment to catch everyone up to speed on
the changes I've made since then.

## A "New" Website.
For those reading via RSS, you will notice little to no change. However, if you
point your browser to https://tdback.net, things will look noticeably
different.

Some may recall that my old website employed the use of the
[TiddlyWiki](https://tiddlywiki.com), a wonderful piece of software that allows
you to create a non-linear notebook for organizing and sharing complex
information. The downside to using a TiddlyWiki as my primary blogging platform
was the need to do almost everything in the browser. As someone who spends a
majority of their time editing text inside [neovim](https://neovim.io), I found
myself sorely missing my beloved [vim motions](https://vim.rtorr.com/) and the
ability to quickly move around my system using tools such as `tmux` or `fzf`.
In short: I missed my terminal.

When researching static site generators, I stumbled across the ever so popular
[Hugo](https://gohugo.io). I immediately found it quite compelling: writing an
entry to my blog would be nothing more than editing a markdown file, and I
could write scripts to easily generate and deploy my site to a web server. Hugo
also comes with a built-in RSS feed generator, meaning that I didn't have to
[write one myself](https://old.tdback.net/#Hacking%20on%20RSS) (although I
quite enjoyed doing so).

While I've traditionally thrown my site's index.html file onto GitHub Pages
and/or Codeberg Pages, as a hobbyist self-hoster I'd be doing an injustice by
not hosting the server on my own hardware. While I would encourage others to
take advantage of free static site hosting services such as
[GitHub Pages](https://pages.github.com/), I've found that I quite enjoy the
responsibilities, challenges, and learning opportunities associated with
self-hosting.

## Closing Thoughts
So far my experience with Hugo has been great! After just a few hours I had a
working site, RSS feed, and an established workflow for writing. If you're
interested in the technical details of how I host my website, read onwards to
[part two](/posts/switching-to-hugo-two/).
