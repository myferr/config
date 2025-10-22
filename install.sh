#!/bin/bash
set -e

clear

# macOS check
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is only supported on macOS."
    exit 1
fi

# Constants
REPO="myferr/config.git"
GITHUB="https://github.com/"
INSTALL_LIST=(fastfetch ghostty zed starship zsh raycast)
CONFIG_DIR="$HOME/.config/myferr-config"

# Colors
RED="\033[0;31m"
REDBOLD="\033[1;31m"
GREEN="\033[0;32m"
GREENBOLD="\033[1;32m"
BLUE="\033[0;34m"
BLUEBOLD="\033[1;34m"
GRAY="\033[0;37m"
GRAYBOLD="\033[1;37m"
RESET="\033[0m"

# Helper functions
log_info()    { echo -e "${BLUEBOLD}[i]${RESET} $1"; }
log_success() { echo -e "${GREENBOLD}[*]${RESET} $1"; }
log_error()   { echo -e "${REDBOLD}[!]${RESET} $1"; }
log_skip()    { echo -e "${GRAYBOLD}[/]${RESET} $1"; }

# Check if a program is installed, and prompt to install if missing
check_program() {
    local program="$1"

    # Special handling for Raycast (not installed via brew)
    if [[ "$program" == "raycast" ]]; then
        if [[ -d "/Applications/Raycast.app" ]] || [[ -d "$HOME/Applications/Raycast.app" ]]; then
            log_success "Raycast found."
        else
            log_error "Raycast not found."
            printf "Do you want to open the Raycast download page? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
            read -r answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                log_info "Opening Raycast download page..."
                open "https://www.raycast.com/download"
            else
                log_error "Raycast installation skipped."
            fi
        fi
        return
    fi

    # Default program check for everything else
    if command -v "$program" &>/dev/null; then
        log_success "$program found."
    else
        log_error "$program not found."
        printf "Do you want to install ${BLUEBOLD}${program}${RESET}? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            log_info "Installing $program..."
            brew install "$program"
        else
            log_error "$program installation cancelled."
        fi
    fi
}

# Pre-checks

# Check for Homebrew
if command -v brew &>/dev/null; then
    log_success "Homebrew found at $(which brew)"
else
    log_error "Homebrew not found."
    exit 1
fi

# Check for Git
if ! command -v git &>/dev/null; then
    log_error "Git not found."
    printf "Do you want to install Git? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
    read -r INSTALL_GIT
    if [[ "$INSTALL_GIT" =~ ^[Yy]$ ]]; then
        log_info "Installing Git..."
        brew install git
    else
        log_error "Git installation cancelled."
        exit 1
    fi
else
    log_success "Git found."
fi

# Backup prompt
printf "Backup your configurations? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
read -r BACKUP
if [[ "$BACKUP" =~ ^[Yy]$ ]]; then
    log_success "Backup set to Enabled."
    BACKUP=true
else
    log_error "Backup set to Disabled."
    BACKUP=false
fi

# Clone repo
if [[ ! -d "$CONFIG_DIR" ]]; then
    log_info "Cloning configuration repository..."
    git clone "${GITHUB}${REPO}" "$CONFIG_DIR"
else
    log_info "Configuration repo already exists at $CONFIG_DIR"
    printf "Do you want to overwrite the existing repository? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
    read -r OVERWRITE
    if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
        log_info "Overwriting existing repository..."
        rm -rf "$CONFIG_DIR"
        git clone "${GITHUB}${REPO}" "$CONFIG_DIR"
    else
        log_error "Repository overwrite cancelled."
    fi
fi

# Install dependencies
log_info "Checking required programs: ${INSTALL_LIST[*]}"

for program in "${INSTALL_LIST[@]}"; do
    check_program "$program"
done

log_info "Program check finished, proceeding with installation..."

# Install fastfetch configuration
if [[ $(which fastfetch) ]]; then
    printf "Configure fastfetch? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
    read -r CONFIGURE_FASTFETCH

    if [[ "$CONFIGURE_FASTFETCH" =~ ^[Yy]$ ]]; then
        log_success "Configuring fastfetch..."
        if [[ $BACKUP == true && -d $HOME/.config/fastfetch ]]; then
            log_success "Backing up existing fastfetch configuration..."
            mv $HOME/.config/fastfetch $HOME/.config/fastfetch.bak
            log_success "Backed up existing fastfetch configuration to $HOME/.config/fastfetch.bak"
        fi
        log_success "Installing fastfetch configuration..."
        mkdir -p $HOME/.config/fastfetch
        mv "$CONFIG_DIR/fastfetch/" $HOME/.config/
    else
        log_skip "Skipping fastfetch configuration"
    fi
fi

# Install ghostty configuration
if [[ $(which ghostty) ]]; then
    printf "Configure ghostty? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
    read -r CONFIGURE_GHOSTTY

    if [[ "$CONFIGURE_GHOSTTY" =~ ^[Yy]$ ]]; then
        log_success "Configuring ghostty..."
        if [[ $BACKUP == true && -d $HOME/.config/ghostty ]]; then
            log_success "Backing up existing ghostty configuration..."
            mv $HOME/.config/ghostty $HOME/.config/ghostty.bak
            log_success "Backed up existing ghostty configuration to $HOME/.config/ghostty.bak"
        fi
        log_success "Installing ghostty configuration..."
        mkdir -p $HOME/.config/ghostty
        mv "$CONFIG_DIR/ghostty/" $HOME/.config/
    else
        log_skip "Skipping ghostty configuration"
    fi
fi

# Install zed configuration
if [[ $(which zed) ]]; then
    printf "Configure zed? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
    read -r CONFIGURE_ZED

    if [[ "$CONFIGURE_ZED" =~ ^[Yy]$ ]]; then
        log_success "Configuring zed..."
        if [[ $BACKUP == true && -d $HOME/.config/zed ]]; then
            log_success "Backing up existing zed configuration..."
            mv $HOME/.config/zed $HOME/.config/zed.bak
            log_success "Backed up existing zed configuration to $HOME/.config/zed.bak"
        fi
        log_success "Installing zed configuration..."
        mkdir -p $HOME/.config/zed
        mv "$CONFIG_DIR/zed/" $HOME/.config/
    else
        log_skip "Skipping zed configuration"
    fi
fi

# Install starship configuration
if [[ $(which starship) ]]; then
    printf "Configure starship? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
    read -r CONFIGURE_STARSHIP

    if [[ "$CONFIGURE_STARSHIP" =~ ^[Yy]$ ]]; then
        log_success "Configuring starship..."
        if [[ $BACKUP == true && -d $HOME/.config/starship ]]; then
            log_success "Backing up existing starship configuration..."
            mv $HOME/.config/starship $HOME/.config/starship.bak
            log_success "Backed up existing starship configuration to $HOME/.config/starship.bak"
        fi
        log_success "Installing starship configuration..."
        mkdir -p $HOME/.config/starship
        mv "$CONFIG_DIR/starship/starship.toml" $HOME/.config/
    else
        log_skip "Skipping starship configuration"
    fi
fi

# Install zsh configuration
if [[ $(which zsh) ]]; then
    printf "Configure zsh? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
    read -r CONFIGURE_ZSH

    if [[ "$CONFIGURE_ZSH" =~ ^[Yy]$ ]]; then
        log_success "Configuring zsh..."
        if [[ $BACKUP == true && -d $HOME/.config/zsh ]]; then
            log_success "Backing up existing zsh configuration..."
            mv $HOME/.config/zsh $HOME/.config/zsh.bak
            log_success "Backed up existing zsh configuration to $HOME/.config/zsh.bak"
        fi
        log_success "Installing zsh configuration..."
        mkdir -p $HOME/.config/zsh
        mv "$CONFIG_DIR/zsh/.zshrc" $HOME/.zshrc
    else
        log_skip "Skipping zsh configuration"
    fi
fi

# Install raycast configuration
if [[ -d "/Applications/Raycast.app" || -d "$HOME/Applications/Raycast.app" ]]; then
    printf "Configure raycast? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
    read -r CONFIGURE_RAYCAST

    if [[ "$CONFIGURE_RAYCAST" =~ ^[Yy]$ ]]; then
        log_info "To configure Raycast, open the Raycast app and follow the instructions."
        log_info "Open Raycast, run the ${GRAYBOLD}Import Settings & Data${RESET} command."
        log_info "Select and import $CONFIG_DIR/raycast/.rayconfig"
    else
        log_skip "Skipping Raycast configuration"
    fi
fi

log_info "Installation complete!"
printf "Care to give the repository a star? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
read -r STAR_REPOSITORY

if [[ "$STAR_REPOSITORY" =~ ^[Yy]$ ]]; then
    log_info "Thank you!"
    open "$GITHUB$REPO"
else
    log_skip "Skipping star"
fi

printf "Clean up? (${GREENBOLD}y${RESET}/${REDBOLD}n${RESET}): "
read -r CLEANUP

if [[ "$CLEANUP" =~ ^[Yy]$ ]]; then
    log_info "Cleaning up..."
    rm -rf "$CONFIG_DIR"
    log_success "Cleaned up!"
else
    log_skip "Skipping cleanup"
fi

exit 0
