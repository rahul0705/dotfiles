FROM alpine:latest

# Set the terminal to have color
ENV TERM=xterm-256color

# Install packages needed for dotfiles
RUN apk add --update-cache curl git bash zsh vim python3 tmux bc

# Install the current version of dotfiles into /git/dotfiles
COPY . /root/.dotfiles

# Run the installer for development
RUN /root/.dotfiles/install-profile linux-developer

# Run ZSH
CMD zsh
