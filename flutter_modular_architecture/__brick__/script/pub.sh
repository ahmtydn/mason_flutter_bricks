#!/opt/homebrew/bin/bash

# More flexible error handling - don't exit on first error
set -u  # Treat unset variables as an error

# Application Configuration
readonly APP_NAME="Dependency Manager"
readonly APP_VERSION="3.0.0"
readonly SUPPORTED_PLATFORMS=("ios" "android" "macos" "web" "windows" "linux")
readonly MODULE_REGISTRY=("common" "core" "gen" "widgets")

# ANSI Color Constants
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_WHITE='\033[1;37m'
readonly COLOR_RESET='\033[0m'

# Status Icons
readonly ICON_INFO="ℹ️"
readonly ICON_SUCCESS="✅"
readonly ICON_WARNING="⚠️"
readonly ICON_ERROR="❌"
readonly ICON_CLEAN="🧹"
readonly ICON_DOWNLOAD="📦"
readonly ICON_BUILD="🔧"
readonly ICON_APPLE="🍎"
readonly ICON_ANDROID="🤖"
readonly ICON_ROCKET="🚀"

# Global State Tracking
declare -A OPERATION_RESULTS
declare -A TIMING_METRICS
declare -g TOTAL_OPERATIONS=0
declare -g SUCCESSFUL_OPERATIONS=0
declare -g FAILED_OPERATIONS=0

# Advanced logging system with timestamps and categorization
log_with_timestamp() {
    local level="$1"
    local message="$2"
    local icon="$3"
    local color="$4"
    
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    
    echo -e "${color}[${timestamp}] ${icon} ${level}:${COLOR_RESET} ${message}"
}

log_info() {
    log_with_timestamp "INFO" "$1" "$ICON_INFO" "$COLOR_BLUE"
}

log_success() {
    log_with_timestamp "SUCCESS" "$1" "$ICON_SUCCESS" "$COLOR_GREEN"
    ((SUCCESSFUL_OPERATIONS++))
}

log_warning() {
    log_with_timestamp "WARNING" "$1" "$ICON_WARNING" "$COLOR_YELLOW"
}

log_error() {
    log_with_timestamp "ERROR" "$1" "$ICON_ERROR" "$COLOR_RED" >&2
    ((FAILED_OPERATIONS++))
}

log_clean() {
    log_with_timestamp "CLEAN" "$1" "$ICON_CLEAN" "$COLOR_CYAN"
}

log_build() {
    log_with_timestamp "BUILD" "$1" "$ICON_BUILD" "$COLOR_MAGENTA"
}

# Enhanced application header with system information
display_application_header() {
    clear
    echo -e "${COLOR_MAGENTA}"
    echo "████████████████████████████████████████████████████████████"
    echo "           ${APP_NAME}"
    echo "                    v${APP_VERSION}"
    echo "████████████████████████████████████████████████████████████"
    echo -e "${COLOR_RESET}"
    
    # System information
    echo -e "${COLOR_CYAN}System Info:${COLOR_RESET} $(uname -s) | $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${COLOR_CYAN}Working Dir:${COLOR_RESET} $(pwd)"
    echo ""
}

# Comprehensive project structure validation
validate_project_environment() {
    log_info "Validating Flutter project environment..."
    
    local validation_errors=0
    
    # Check for required Flutter project files
    local required_files=("pubspec.yaml" "lib/main.dart" "analysis_options.yaml")
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Critical file missing: $file"
            ((validation_errors++))
        fi
    done
    
    # Validate Flutter SDK availability
    if ! command -v flutter >/dev/null 2>&1; then
        log_error "Flutter SDK not found in PATH"
        ((validation_errors++))
    else
        local flutter_version
        flutter_version=$(flutter --version | head -n1 | awk '{print $2}' 2>/dev/null || echo "Unknown")
        log_info "Flutter SDK version: $flutter_version"
    fi
    
    # Check for CocoaPods on macOS systems
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v pod >/dev/null 2>&1; then
            log_warning "CocoaPods not found - iOS/macOS builds may fail"
        else
            local pod_version
            pod_version=$(pod --version 2>/dev/null || echo "Unknown")
            log_info "CocoaPods version: $pod_version"
        fi
    fi
    
    # Validate project structure
    local expected_dirs=("lib" "test")
    for dir in "${expected_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_warning "Recommended directory missing: $dir"
        fi
    done
    
    if [[ $validation_errors -gt 0 ]]; then
        log_error "Environment validation failed with $validation_errors critical error(s)"
        return 1
    fi
    
    log_success "Project environment validation completed"
    return 0
}

# Advanced cache cleaning with size reporting
perform_deep_cache_clean() {
    local target_dir="$1"
    local target_name="$2"
    local cleaned_size=0
    
    log_clean "Deep cleaning cache for $target_name"
    
    # Calculate sizes before deletion for reporting
    local cache_items=("pubspec.lock" ".dart_tool" "build" ".flutter-plugins" ".flutter-plugins-dependencies")
    
    for item in "${cache_items[@]}"; do
        local item_path="$target_dir/$item"
        
        if [[ -e "$item_path" ]]; then
            # Calculate size before deletion (works for both files and directories)
            local size
            if [[ -d "$item_path" ]]; then
                size=$(du -sk "$item_path" 2>/dev/null | cut -f1 || echo "0")
            else
                size=$(ls -la "$item_path" 2>/dev/null | awk '{print $5}' || echo "0")
                size=$((size / 1024))  # Convert bytes to KB
            fi
            
            cleaned_size=$((cleaned_size + size))
            
            # Remove the item
            rm -rf "$item_path"
            log_clean "Removed $item (${size}KB) from $target_name"
        fi
    done
    
    # Store cleaning results for reporting
    OPERATION_RESULTS["${target_name}_cleaned_size"]="${cleaned_size}KB"
    
    return 0
}

# Enhanced dependency resolution with retry mechanism
execute_dependency_resolution() {
    local target_dir="$1"
    local target_name="$2"
    local max_retries=3
    local retry_count=0
    
    log_build "Resolving dependencies for $target_name"
    
    # Change to target directory
    pushd "$target_dir" >/dev/null
    
    # Retry mechanism for pub get with detailed error reporting
    while [[ $retry_count -lt $max_retries ]]; do
        local start_time
        start_time=$(date +%s)
        
        # Capture both stdout and stderr
        local pub_output
        local pub_exit_code
        pub_output=$(timeout 300 flutter pub get --no-example 2>&1) || pub_exit_code=$?
        
        if [[ ${pub_exit_code:-0} -eq 0 ]]; then
            local end_time
            end_time=$(date +%s)
            local duration=$((end_time - start_time))
            
            TIMING_METRICS["${target_name}_pub_get"]="${duration}s"
            log_success "Dependencies resolved for $target_name in ${duration}s"
            popd >/dev/null
            return 0
        else
            ((retry_count++))
            log_warning "Dependency resolution failed for $target_name (attempt $retry_count/$max_retries)"
            
            # Show detailed error information
            if [[ -n "$pub_output" ]]; then
                log_error "Error details for $target_name:"
                echo -e "${COLOR_RED}$pub_output${COLOR_RESET}" >&2
            fi
            
            if [[ $retry_count -lt $max_retries ]]; then
                log_info "Retrying in 5 seconds..."
                sleep 5
            fi
        fi
    done
    
    log_error "Dependency resolution failed for $target_name after $max_retries attempts"
    OPERATION_RESULTS["${target_name}_status"]="FAILED"
    popd >/dev/null
    return 1
}

# Sophisticated CocoaPods management
manage_cocoapods_dependencies() {
    local platform_dir="$1"
    local platform_name="$2"
    
    # Skip if not on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_info "Skipping CocoaPods operations (not on macOS)"
        return 0
    fi
    
    # Skip if CocoaPods not available
    if ! command -v pod >/dev/null 2>&1; then
        log_warning "CocoaPods not available, skipping $platform_name pod operations"
        return 0
    fi
    
    if [[ ! -d "$platform_dir" ]]; then
        log_warning "$platform_name platform directory not found, skipping"
        return 0
    fi
    
    log_clean "Cleaning CocoaPods cache for $platform_name"
    
    # Clean CocoaPods artifacts
    local pod_artifacts=("Pods" "Podfile.lock" ".symlinks" "Podfile.lock.tmp")
    local cleaned_pod_size=0
    
    for artifact in "${pod_artifacts[@]}"; do
        local artifact_path="$platform_dir/$artifact"
        if [[ -e "$artifact_path" ]]; then
            local size
            if [[ -d "$artifact_path" ]]; then
                size=$(du -sk "$artifact_path" 2>/dev/null | cut -f1 || echo "0")
            else
                size=$(ls -la "$artifact_path" 2>/dev/null | awk '{print $5}' || echo "0")
                size=$((size / 1024))
            fi
            
            cleaned_pod_size=$((cleaned_pod_size + size))
            rm -rf "$artifact_path"
            log_clean "Removed $artifact (${size}KB) from $platform_name"
        fi
    done
    
    # Install pods if Podfile exists
    if [[ -f "$platform_dir/Podfile" ]]; then
        log_build "Installing CocoaPods dependencies for $platform_name"
        
        pushd "$platform_dir" >/dev/null
        
        local start_time
        start_time=$(date +%s)
        
        # Capture pod install output for detailed error reporting
        local pod_output
        local pod_exit_code
        pod_output=$(timeout 600 pod install --repo-update 2>&1) || pod_exit_code=$?
        
        if [[ ${pod_exit_code:-0} -eq 0 ]]; then
            local end_time
            end_time=$(date +%s)
            local duration=$((end_time - start_time))
            
            TIMING_METRICS["${platform_name}_pod_install"]="${duration}s"
            log_success "CocoaPods installation completed for $platform_name in ${duration}s"
        else
            log_error "CocoaPods installation failed for $platform_name"
            if [[ -n "$pod_output" ]]; then
                log_error "Pod install error details:"
                echo -e "${COLOR_RED}$pod_output${COLOR_RESET}" >&2
            fi
            OPERATION_RESULTS["${platform_name}_pod_status"]="FAILED"
            popd >/dev/null
            # Don't return 1, continue with other operations
            return 0
        fi
        
        popd >/dev/null
    else
        log_warning "No Podfile found in $platform_name, skipping pod install"
    fi
    
    OPERATION_RESULTS["${platform_name}_pod_cleaned"]="${cleaned_pod_size}KB"
    return 0
}

# Module processing with parallel capability assessment
process_flutter_modules() {
    log_info "Processing Flutter modules..."
    
    local project_root
    project_root=$(pwd)
    local module_base_dir="$project_root/module"
    
    if [[ ! -d "$module_base_dir" ]]; then
        log_warning "Module directory not found at $module_base_dir"
        return 0
    fi
    
    local processed_modules=0
    local failed_modules=0
    
    for module in "${MODULE_REGISTRY[@]}"; do
        local module_path="$module_base_dir/$module"
        
        if [[ -d "$module_path" && -f "$module_path/pubspec.yaml" ]]; then
            log_info "Processing module: $module"
            ((TOTAL_OPERATIONS++))
            
            # Clean module cache
            perform_deep_cache_clean "$module_path" "module/$module"
            
            # Resolve dependencies (continue even if failed)
            if execute_dependency_resolution "$module_path" "module/$module"; then
                ((processed_modules++))
                OPERATION_RESULTS["module_${module}"]="SUCCESS"
            else
                ((failed_modules++))
                OPERATION_RESULTS["module_${module}"]="FAILED"
                log_error "Module $module dependency resolution failed - continuing with other modules"
            fi
        else
            log_warning "Module $module not found or missing pubspec.yaml"
        fi
    done
    
    log_info "Module processing completed: $processed_modules successful, $failed_modules failed"
}

# Platform-specific dependency management
process_platform_dependencies() {
    log_info "Processing platform-specific dependencies..."
    
    local project_root
    project_root=$(pwd)
    
    # Process iOS platform
    if [[ -d "$project_root/ios" ]]; then
        log_info "Processing iOS platform dependencies"
        ((TOTAL_OPERATIONS++))
        manage_cocoapods_dependencies "$project_root/ios" "iOS"
    fi
    
    # Process macOS platform
    if [[ -d "$project_root/macos" ]]; then
        log_info "Processing macOS platform dependencies"
        ((TOTAL_OPERATIONS++))
        manage_cocoapods_dependencies "$project_root/macos" "macOS"
    fi
    
    # Additional platform checks
    for platform in "android" "web" "windows" "linux"; do
        if [[ -d "$project_root/$platform" ]]; then
            log_info "$platform platform detected (no additional processing required)"
        fi
    done
}

# Comprehensive operation report generation
generate_comprehensive_report() {
    local total_time="$1"
    
    echo ""
    echo -e "${COLOR_MAGENTA}${ICON_ROCKET} COMPREHENSIVE OPERATION REPORT${COLOR_RESET}"
    echo -e "${COLOR_CYAN}══════════════════════════════════════════════════════════════${COLOR_RESET}"
    
    # Summary statistics
    echo -e "${COLOR_WHITE}Operation Summary:${COLOR_RESET}"
    echo -e "  Total Operations:    ${TOTAL_OPERATIONS}"
    echo -e "  Successful:          ${COLOR_GREEN}${SUCCESSFUL_OPERATIONS}${COLOR_RESET}"
    echo -e "  Failed:              ${COLOR_RED}${FAILED_OPERATIONS}${COLOR_RESET}"
    echo -e "  Total Duration:      ${total_time}s"
    echo ""
    
    # Detailed timing metrics
    if [[ ${#TIMING_METRICS[@]} -gt 0 ]]; then
        echo -e "${COLOR_WHITE}Performance Metrics:${COLOR_RESET}"
        for key in "${!TIMING_METRICS[@]}"; do
            echo -e "  ${key}: ${TIMING_METRICS[$key]}"
        done
        echo ""
    fi
    
    # Cache cleaning results
    echo -e "${COLOR_WHITE}Cache Cleaning Results:${COLOR_RESET}"
    local total_cleaned=0
    for key in "${!OPERATION_RESULTS[@]}"; do
        if [[ $key == *"_cleaned_size" ]]; then
            local size_value="${OPERATION_RESULTS[$key]}"
            local size_kb="${size_value%KB}"
            total_cleaned=$((total_cleaned + size_kb))
            echo -e "  ${key/_cleaned_size/}: ${size_value}"
        fi
    done
    echo -e "  ${COLOR_CYAN}Total Cleaned: ${total_cleaned}KB${COLOR_RESET}"
    echo ""
    
    # Operation status summary
    echo -e "${COLOR_WHITE}Operation Status:${COLOR_RESET}"
    for key in "${!OPERATION_RESULTS[@]}"; do
        if [[ $key == *"_status" || $key == module_* ]]; then
            local status="${OPERATION_RESULTS[$key]}"
            if [[ "$status" == "SUCCESS" ]]; then
                echo -e "  ${key}: ${COLOR_GREEN}${status}${COLOR_RESET}"
            else
                echo -e "  ${key}: ${COLOR_RED}${status}${COLOR_RESET}"
            fi
        fi
    done
    
    # Final recommendation
    echo ""
    if [[ $FAILED_OPERATIONS -eq 0 ]]; then
        echo -e "${COLOR_GREEN}${ICON_SUCCESS} All operations completed successfully!${COLOR_RESET}"
        echo -e "${COLOR_GREEN}Your Flutter project is ready for development and building.${COLOR_RESET}"
    else
        echo -e "${COLOR_YELLOW}${ICON_WARNING} Some operations failed. Please review the errors above.${COLOR_RESET}"
        echo -e "${COLOR_YELLOW}Consider running individual commands manually for failed components.${COLOR_RESET}"
    fi
}

# Main orchestration function with comprehensive error handling
main() {
    # Initialize global state
    TOTAL_OPERATIONS=0
    SUCCESSFUL_OPERATIONS=0
    FAILED_OPERATIONS=0
    
    # Record start time
    local start_time
    start_time=$(date +%s)
    
    # Set up signal handlers
    trap 'log_error "Operation interrupted by user"; exit 130' INT TERM
    
    # Display application header
    display_application_header
    
    # Validate environment (continue even if validation has warnings)
    if ! validate_project_environment; then
        log_warning "Environment validation completed with warnings - continuing operations"
    fi
    
    # Store original directory
    local original_dir
    original_dir=$(pwd)
    
    # Ensure we return to original directory on exit
    trap "cd '$original_dir'" EXIT
    
    echo ""
    log_info "Initiating comprehensive dependency management..."
    echo ""
    
    # Process main project
    log_info "=== MAIN PROJECT PROCESSING ==="
    ((TOTAL_OPERATIONS++))
    perform_deep_cache_clean "." "main project"
    execute_dependency_resolution "." "main project"
    echo ""
    
    # Process modules
    log_info "=== MODULE PROCESSING ==="
    process_flutter_modules
    echo ""
    
    # Process platforms
    log_info "=== PLATFORM PROCESSING ==="
    process_platform_dependencies
    echo ""
    
    # Calculate total execution time
    local end_time
    end_time=$(date +%s)
    local total_duration=$((end_time - start_time))
    
    # Generate comprehensive report
    generate_comprehensive_report "$total_duration"
    
    # Return appropriate exit code
    if [[ $FAILED_OPERATIONS -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Script entry point with proper error handling
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi