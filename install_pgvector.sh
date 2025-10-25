#!/bin/bash
# Install pgvector extension for PostgreSQL on Linux/Mac

set -e

echo "========================================="
echo "  PostgreSQL pgvector Installation"
echo "========================================="
echo ""
echo "This script will help you install the pgvector extension."
echo ""

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "ERROR: PostgreSQL is not installed or not in PATH"
    echo "Please install PostgreSQL first"
    exit 1
fi

echo "Detected PostgreSQL installation:"
psql --version
echo ""

# Function to try creating the extension
try_create_extension() {
    echo "Attempting to create pgvector extension..."
    if psql -U postgres -p 5432 -d AEROSPACE -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>/dev/null; then
        echo ""
        echo "========================================"
        echo "  SUCCESS!"
        echo "========================================"
        echo ""
        echo "pgvector extension has been created successfully!"
        echo ""
        return 0
    else
        echo ""
        echo "Extension creation failed. Files need to be installed first."
        echo ""
        return 1
    fi
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

# Try to create extension first
if try_create_extension; then
    exit 0
fi

echo "========================================="
echo "  Installation Methods"
echo "========================================="
echo ""
echo "  [1] Automatic Installation (Recommended)"
echo "  [2] Show manual installation instructions"
echo "  [3] Cancel"
echo ""
read -p "Choose installation method (1-3): " choice

case $choice in
    1)
        echo ""
        echo "========================================="
        echo "  Automatic Installation"
        echo "========================================="
        echo ""

        if [ "$OS" == "linux" ]; then
            # Detect Linux distribution
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO=$ID
            fi

            echo "Detected Linux distribution: $DISTRO"
            echo ""

            case $DISTRO in
                ubuntu|debian)
                    echo "Installing pgvector for Ubuntu/Debian..."
                    echo ""
                    sudo apt-get update
                    sudo apt-get install -y postgresql-server-dev-all build-essential git

                    # Clone and build
                    cd /tmp
                    git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git
                    cd pgvector
                    make
                    sudo make install

                    echo ""
                    echo "Installation complete! Creating extension..."
                    try_create_extension
                    ;;

                fedora|rhel|centos)
                    echo "Installing pgvector for Fedora/RHEL/CentOS..."
                    echo ""
                    sudo dnf install -y postgresql-devel gcc git

                    # Clone and build
                    cd /tmp
                    git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git
                    cd pgvector
                    make
                    sudo make install

                    echo ""
                    echo "Installation complete! Creating extension..."
                    try_create_extension
                    ;;

                arch)
                    echo "Installing pgvector for Arch Linux..."
                    echo ""
                    sudo pacman -S --noconfirm postgresql-libs base-devel git

                    # Clone and build
                    cd /tmp
                    git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git
                    cd pgvector
                    make
                    sudo make install

                    echo ""
                    echo "Installation complete! Creating extension..."
                    try_create_extension
                    ;;

                *)
                    echo "Unsupported distribution: $DISTRO"
                    echo "Please install manually (option 2)"
                    ;;
            esac

        elif [ "$OS" == "mac" ]; then
            echo "Installing pgvector for macOS..."
            echo ""

            # Check if Homebrew is installed
            if command -v brew &> /dev/null; then
                echo "Using Homebrew to install pgvector..."
                brew install pgvector

                echo ""
                echo "Installation complete! Creating extension..."
                try_create_extension
            else
                echo "Homebrew not found. Installing manually..."
                echo ""

                # Clone and build
                cd /tmp
                git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git
                cd pgvector
                make
                sudo make install

                echo ""
                echo "Installation complete! Creating extension..."
                try_create_extension
            fi
        else
            echo "Unsupported operating system"
            echo "Please install manually"
        fi
        ;;

    2)
        echo ""
        echo "========================================="
        echo "  Manual Installation Instructions"
        echo "========================================="
        echo ""

        if [ "$OS" == "linux" ]; then
            echo "For Linux:"
            echo ""
            echo "Ubuntu/Debian:"
            echo "  sudo apt-get install postgresql-server-dev-all build-essential git"
            echo "  git clone https://github.com/pgvector/pgvector.git"
            echo "  cd pgvector"
            echo "  make"
            echo "  sudo make install"
            echo ""
            echo "Fedora/RHEL/CentOS:"
            echo "  sudo dnf install postgresql-devel gcc git"
            echo "  git clone https://github.com/pgvector/pgvector.git"
            echo "  cd pgvector"
            echo "  make"
            echo "  sudo make install"
            echo ""
            echo "Arch Linux:"
            echo "  sudo pacman -S postgresql-libs base-devel git"
            echo "  git clone https://github.com/pgvector/pgvector.git"
            echo "  cd pgvector"
            echo "  make"
            echo "  sudo make install"
            echo ""

        elif [ "$OS" == "mac" ]; then
            echo "For macOS:"
            echo ""
            echo "Using Homebrew (recommended):"
            echo "  brew install pgvector"
            echo ""
            echo "Or build from source:"
            echo "  git clone https://github.com/pgvector/pgvector.git"
            echo "  cd pgvector"
            echo "  make"
            echo "  sudo make install"
            echo ""
        fi

        echo "After installation, create the extension:"
        echo "  psql -U postgres -p 5432 -d AEROSPACE -c \"CREATE EXTENSION vector;\""
        echo ""
        ;;

    3)
        echo ""
        echo "Installation cancelled."
        echo ""
        exit 0
        ;;

    *)
        echo ""
        echo "Invalid choice."
        exit 1
        ;;
esac
