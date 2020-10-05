FROM archlinux:latest

# Set the terminal to have color
ENV TERM=xterm-256color

# Update the packages
RUN pacman -Syu --noconfirm

# Install packages needed for dotfiles
RUN pacman -S --noconfirm curl git bash zsh vim python3 tmux bc

# Install the current version of dotfiles into /git/dotfiles
COPY . /git/dotfiles

# Run the installer for linux-server
RUN /git/dotfiles/install-profile linux-server

# Run ZSH
CMD zsh
