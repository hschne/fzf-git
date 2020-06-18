
## This plugin is no longer maintained!

I found that [fzf-tab](https://github.com/Aloxaf/fzf-tab) serves the purpose of Git completions much better. You can read up more on how to use fzf-tab and other completions [in this article](https://hschne.at/2020/04/25/creating-a-fuzzy-shell-with-fzf-and-friends.html)

---

<h1 align="center">fzf-git</h1> <p
align="center">Git completions, powered by fzf</p>

<p align="center">
<a href="https://forthebadge.com"><img src="https://forthebadge.com/images/badges/no-ragrets.svg"></a>
<a href="https://forthebadge.com"><img src="https://forthebadge.com/images/badges/built-with-grammas-recipe.svg"></a>
</p>

<br>

![Demo Gif](/demo.gif)

## Installation

Make sure you have [fzf](https://github.com/junegunn/fzf) installed. Then use the plugin manager of your choice to install fzf-git.

### Zplug

```
zplug "hschne/fzf-git"
```

### Antigen 

```
antigen bundle hschne/fzf-git
```

### Oh my Zsh

```
 git clone https://github.com/hschne/fzf-git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-git
```

## Usage

This plugin simply enables auto-completion of git commands using the `**` trigger. For example, type

```
git checkout **<TAB>
```

to get a fuzzy-searchable list of branches. Currently only `git checkout` and its aliases (`git co`, `gco`, `g checkout`, `g co`) are supported.

## License

[MIT](LICENSE) (c) [@hschne](https://github.com/hschne)
