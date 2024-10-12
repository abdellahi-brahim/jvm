#!/bin/zsh

# JVM Manager - A simple tool to manage multiple Java versions using Homebrew.
# Author: Abdellahi Brahim
# License: MIT
# Version: 1.0.0

# === CONFIGURATION ===
# Supported Java versions
typeset -A SUPPORTED_VERSIONS
SUPPORTED_VERSIONS=(8 openjdk@8 11 openjdk@11 17 openjdk@17 19 openjdk@19)

# Script version
JVM_VERSION="1.0.0"

# === FUNCTIONS ===

# Display usage information
function show_usage() {
    echo "JVM Manager v$JVM_VERSION"
    echo ""
    echo "Usage: jvm [command] [version]"
    echo ""
    echo "Commands:"
    echo "  install <version>   Install the specified Java version"
    echo "  use <version>       Use the specified Java version"
    echo "  list                List installed Java versions"
    echo "  version             Show the JVM Manager version"
    echo "  uninstall           Remove JVM Manager from your system"
    echo ""
    echo "Supported Versions: ${(@k)SUPPORTED_VERSIONS}"
}

# Display version information
function show_version() {
    echo "JVM Manager v$JVM_VERSION"
}

# Check if Homebrew is installed
function check_homebrew_installed() {
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
}

# Install the specified Java version using Homebrew
function jvm_install() {
    local version=$1

    if [[ -z "$version" || -z "$SUPPORTED_VERSIONS[$version]" ]]; then
        echo "Error: Unsupported or missing Java version. Use 'jvm list' to see supported versions."
        exit 1
    fi

    if ! brew list --cask "$SUPPORTED_VERSIONS[$version]" &> /dev/null; then
        echo "Installing Java $version..."
        brew install "$SUPPORTED_VERSIONS[$version]"
    else
        echo "Java $version is already installed."
    fi
}

# Switch to the specified Java version
function jvm_use() {
    local version=$1

    if [[ -z "$version" || -z "$SUPPORTED_VERSIONS[$version]" ]]; then
        echo "Error: Unsupported or missing Java version. Use 'jvm list' to see supported versions."
        exit 1
    fi

    if /usr/libexec/java_home -v$version &> /dev/null; then
        export JAVA_HOME=$(/usr/libexec/java_home -v$version)
        export PATH=$JAVA_HOME/bin:$PATH
        echo "Switched to Java $version (JAVA_HOME=$JAVA_HOME)"

        # Update ~/.zshrc permanently
        sed -i '' '/export JAVA_HOME/d' ~/.zshrc
        sed -i '' '/export PATH.*JAVA_HOME/d' ~/.zshrc
        echo "export JAVA_HOME=$JAVA_HOME" >> ~/.zshrc
        echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.zshrc
        source ~/.zshrc
        echo "JAVA_HOME and PATH updated in ~/.zshrc"
    else
        echo "Error: Java $version is not installed. Use 'jvm install $version' to install it."
    fi
}

# List installed Java versions
function jvm_list() {
    echo "Installed Java versions:"
    /usr/libexec/java_home -V 2>&1 | grep -E '1\.8|11|17|19' || echo "No supported Java versions installed."
}

# Uninstall JVM Manager (remove its settings from .zshrc)
function jvm_uninstall() {
    echo "Uninstalling JVM Manager..."
    sed -i '' '/# JVM Manager/d' ~/.zshrc
    sed -i '' '/function jvm()/,/^}/d' ~/.zshrc
    echo "JVM Manager uninstalled. Please restart your terminal."
}

# Handle cleanup on script exit
function cleanup() {
    echo "Cleaning up..."
    exit 0
}
trap cleanup EXIT

# === MAIN ===

# Ensure Homebrew is installed
check_homebrew_installed

# Parse command-line arguments
command=$1
version=$2

case $command in
    install)
        jvm_install $version
        ;;
    use)
        jvm_use $version
        ;;
    list)
        jvm_list
        ;;
    version)
        show_version
        ;;
    uninstall)
        jvm_uninstall
        ;;
    *)
        show_usage
        ;;
esac
