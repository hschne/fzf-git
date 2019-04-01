<h1 align="center">fzf-git</h1> <p
align="center">Git completions, powered by fzf</p>

<p align="center">
<a href="https://forthebadge.com"><img src="https://forthebadge.com/images/badges/no-ragrets.svg"></a>
<a href="https://forthebadge.com"><img src="https://forthebadge.com/images/badges/built-with-grammas-recipe.svg"></a>
</p>

<br>

![Demo Gif](/demo.gif)

fzf-git is a simple zsh plugin that enables fzf-style completions for git commands. Requires [fzf](https://github.com/junegunn/fzf) (if that wasn't obvious). 

## Installation

Use the plugin manager of your choice to install fzf-git

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

to get a fuzzy-searchable list of branches. Currently only `git checkout` and its aliases (`git co`, `gco`) are supported.

## License

[MIT](LICENSE) (c) [@hschne](https://github.com/hschne)
