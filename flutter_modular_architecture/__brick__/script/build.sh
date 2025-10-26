#!/bin/bash

# Get the script directory and navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "📍 Working from: $PROJECT_ROOT"

# Define all modules that need build runner
MODULES=("module/gen" "module/core" "module/common" "module/widgets")

# Function to clean build cache for all modules and main project
clean_all_cache() {
    echo "🧹 Cleaning build cache for all modules and main project..."
    
    # Clean main project cache
    rm -rf .dart_tool/build
    echo "  ✅ Main project cache cleaned"
    
    # Clean module caches
    for module in "${MODULES[@]}"; do
        if [ -d "$module" ]; then
            rm -rf "$module/.dart_tool/build"
            # Clean generated environment files
            rm -f "$module/lib/src/environment/dev_env.g.dart"
            rm -f "$module/lib/src/environment/prod_env.g.dart"
            echo "  ✅ $module cache cleaned"
        fi
    done
}

# Function to run build runner for all modules and main project
run_build_all() {
    local build_command="$1"
    
    echo "🔨 Running build runner for all modules and main project..."
    
    # Build modules first
    for module in "${MODULES[@]}"; do
        if [ -d "$module" ] && [ -f "$module/pubspec.yaml" ]; then
            # Check if module has build_runner dependency
            if grep -q "build_runner:" "$module/pubspec.yaml"; then
                echo "  🔨 Building $module..."
                cd "$PROJECT_ROOT/$module"
                dart run build_runner $build_command
                cd "$PROJECT_ROOT"
                echo "  ✅ $module completed"
            else
                echo "  ⏭️  $module (no build_runner dependency)"
            fi
        fi
    done
    
    # Build main project last
    echo "  🔨 Building main project..."
    cd "$PROJECT_ROOT"
    dart run build_runner $build_command
    echo "  ✅ Main project completed"
}

# Function to run watch mode (only for main project)
run_watch() {
    echo "👀 Starting build runner in watch mode for main project..."
    echo "💡 Note: Watch mode runs only for main project. Use separate terminals for module watching if needed."
    cd "$PROJECT_ROOT"
    dart run build_runner watch
}

# Parse command line arguments
case "$1" in
    "force")
        clean_all_cache
        run_build_all "build --delete-conflicting-outputs"
        ;;
    "watch")
        echo "🤔 Do you want to clean cache before watch? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            clean_all_cache
        fi
        run_watch
        ;;
    "clean")
        clean_all_cache
        ;;
    "build")
        run_build_all "build"
        ;;
    *)
        echo "📖 Usage: $0 {force|watch|clean|build}"
        echo ""
        echo "Commands:"
        echo "  force  - Clean cache and build all modules with --delete-conflicting-outputs"
        echo "  watch  - Start watch mode for main project (with optional cache clean)"
        echo "  clean  - Clean all build caches"
        echo "  build  - Build all modules and main project"
        echo ""
        echo "🔨 Running default build..."
        run_build_all "build"
        ;;
esac