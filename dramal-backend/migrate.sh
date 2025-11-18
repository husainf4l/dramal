#!/bin/bash

# Migration Management Script for Dramal
# This script provides convenient commands for managing EF Core migrations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Help function
show_help() {
    echo "Migration Management Script for Dramal"
    echo ""
    echo "Usage: ./migrate.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  add <name>       Create a new migration with the specified name"
    echo "  update           Apply all pending migrations to the database"
    echo "  status           Check the status of migrations"
    echo "  remove           Remove the last migration (if not applied)"
    echo "  list             List all migrations"
    echo "  reset            Reset database and reapply all migrations"
    echo "  script           Generate SQL script for migrations"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./migrate.sh add AddUserProfile"
    echo "  ./migrate.sh update"
    echo "  ./migrate.sh status"
    echo "  ./migrate.sh script > migrations.sql"
}

# Check if dotnet ef is installed
check_ef_tools() {
    if ! command -v dotnet-ef &> /dev/null; then
        print_error "dotnet-ef tools are not installed globally"
        print_info "Install with: dotnet tool install --global dotnet-ef"
        exit 1
    fi
}

# Add new migration
add_migration() {
    if [ -z "$1" ]; then
        print_error "Migration name is required"
        echo "Usage: ./migrate.sh add <migration_name>"
        exit 1
    fi
    
    print_info "Creating new migration: $1"
    dotnet ef migrations add "$1" --output-dir Migrations
    
    if [ $? -eq 0 ]; then
        print_success "Migration '$1' created successfully"
    else
        print_error "Failed to create migration '$1'"
        exit 1
    fi
}

# Update database
update_database() {
    print_info "Applying pending migrations to database..."
    dotnet ef database update
    
    if [ $? -eq 0 ]; then
        print_success "Database updated successfully"
    else
        print_error "Failed to update database"
        exit 1
    fi
}

# Check migration status
check_status() {
    print_info "Checking migration status..."
    dotnet ef migrations list --json | jq -r '.[] | "- " + .name + (if .applied then " (applied)" else " (pending)" end)'
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Migration status retrieved successfully"
    else
        print_warning "Could not retrieve migration status (jq might not be installed)"
        print_info "Showing raw output:"
        dotnet ef migrations list
    fi
}

# Remove last migration
remove_migration() {
    print_warning "This will remove the last migration. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Removing last migration..."
        dotnet ef migrations remove
        
        if [ $? -eq 0 ]; then
            print_success "Last migration removed successfully"
        else
            print_error "Failed to remove migration"
            exit 1
        fi
    else
        print_info "Operation cancelled"
    fi
}

# List migrations
list_migrations() {
    print_info "Listing all migrations..."
    dotnet ef migrations list
}

# Reset database
reset_database() {
    print_error "This will DROP the entire database and recreate it. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Dropping and recreating database..."
        dotnet ef database drop --force
        dotnet ef database update
        
        if [ $? -eq 0 ]; then
            print_success "Database reset successfully"
        else
            print_error "Failed to reset database"
            exit 1
        fi
    else
        print_info "Operation cancelled"
    fi
}

# Generate SQL script
generate_script() {
    print_info "Generating SQL script for migrations..."
    dotnet ef migrations script
}

# Main script logic
case "$1" in
    "add")
        check_ef_tools
        add_migration "$2"
        ;;
    "update")
        check_ef_tools
        update_database
        ;;
    "status")
        check_ef_tools
        check_status
        ;;
    "remove")
        check_ef_tools
        remove_migration
        ;;
    "list")
        check_ef_tools
        list_migrations
        ;;
    "reset")
        check_ef_tools
        reset_database
        ;;
    "script")
        check_ef_tools
        generate_script
        ;;
    "help"|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac