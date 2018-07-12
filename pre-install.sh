#!/bin/bash

# Check if oh-my-zsh is installed
OHMYZSHDIR="$HOME/.oh-my-zsh"
if [ ! -d "$OHMYZSHDIR" ]; then
  echo 'Installing oh-my-zsh'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# Change default shell
if [ $(basename $SHELL) != "zsh" ]; then
  echo 'Changing default shell to zsh'
  chsh -s /bin/zsh
else
  echo 'Already using zsh'
fi
