#!/bin/bash

VERSION="v0.1.0"

function show_help {
    echo "Usage: sysopctl [command] [options]"
    echo "Commands:"
    echo "  service list                 List running services"
    echo "  system load                  View system load averages"
    echo "  service start <service-name> Start a service"
    echo "  service stop <service-name>  Stop a service"
    echo "  disk usage                   Check disk usage"
    echo "  process monitor              Monitor system processes"
    echo "  logs analyze                 Analyze system logs"
    echo "  backup <path>               Backup system files"
    echo "  --help                       Show this help message"
    echo "  --version                    Show version information"
}

if [[ $1 == "--help" ]]; then
    show_help
    exit 0
fi

if [[ $1 == "--version" ]]; then
    echo "sysopctl version $VERSION"
    exit 0
fi

function list_services {
    if ! command -v systemctl &> /dev/null; then
        echo "Error: systemctl command not found. Make sure you're on a system with systemd."
        exit 1
    fi

    systemctl list-units --type=service
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to list services."
        exit 1
    fi
}

if [[ $1 == "service" && $2 == "list" ]]; then
    list_services
    exit 0
fi

function view_load {
    if ! command -v uptime &> /dev/null; then
        echo "Error: uptime command not found."
        exit 1
    fi

    uptime
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve system load."
        exit 1
    fi
}

if [[ $1 == "system" && $2 == "load" ]]; then
    view_load
    exit 0
fi

function manage_service {
    local action=$1
    local service_name=$2

    if [[ $action == "start" ]]; then
        if ! command -v systemctl &> /dev/null; then
            echo "Error: systemctl command not found. Make sure you're on a system with systemd."
            exit 1
        fi

        sudo systemctl start "$service_name"
        if [[ $? -eq 0 ]]; then
            echo "Started $service_name"
        else
            echo "Error: Failed to start $service_name"
        fi
    elif [[ $action == "stop" ]]; then
        if ! command -v systemctl &> /dev/null; then
            echo "Error: systemctl command not found. Make sure you're on a system with systemd."
            exit 1
        fi

        sudo systemctl stop "$service_name"
        if [[ $? -eq 0 ]]; then
            echo "Stopped $service_name"
        else
            echo "Error: Failed to stop $service_name"
        fi
    else
        echo "Error: Invalid action. Use 'start' or 'stop'."
    fi
}

if [[ $1 == "service" && ($2 == "start" || $2 == "stop") ]]; then
    manage_service $2 $3
    exit 0
fi

function check_disk_usage {
    df -h
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to check disk usage."
        exit 1
    fi
}

if [[ $1 == "disk" && $2 == "usage" ]]; then
    check_disk_usage
    exit 0
fi

function monitor_processes {
    if ! command -v top &> /dev/null; then
        echo "Error: top command not found."
        exit 1
    fi

    top
}

if [[ $1 == "process" && $2 == "monitor" ]]; then
    monitor_processes
    exit 0
fi

function analyze_logs {
    if ! command -v journalctl &> /dev/null; then
        echo "Error: journalctl command not found."
        exit 1
    fi

    journalctl -p crit -n 20
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to analyze logs."
        exit 1
    fi
}

if [[ $1 == "logs" && $2 == "analyze" ]]; then
    analyze_logs
    exit 0
fi

function backup_files {
    local path=$1
    if ! command -v rsync &> /dev/null; then
        echo "Error: rsync command not found."
        exit 1
    fi

    rsync -av --progress "$path" ~/backup/
    if [[ $? -eq 0 ]]; then
        echo "Backup of $path initiated."
    else
        echo "Error: Backup failed."
    fi
}

if [[ $1 == "backup" ]]; then
    backup_files $2
    exit 0
fi

# If no valid command was provided, show help
show_help
exit 1
