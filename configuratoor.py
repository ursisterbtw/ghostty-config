#!/usr/bin/env python3
"""
configuratoor: A tool to automatically prettify and organize configuration files with visual separators and comments.

supported Formats: TOML, YAML, INI

usage:
    configuratoor.py --file path/to/config/to/lint.toml --format toml/yaml/ini/etc
"""

import argparse
import os
import sys
import shutil
import toml
import yaml
from configparser import ConfigParser

# define separator styles
SEPARATOR_STYLES = {
    "equals": "========================================",
    "dashes": "----------------------------------------",
    "stars": "****************************************",
    "hashes": "########################################",
    "mixed": "========================================",
}

EMOJI_SEPARATORS = {
    "global": "🌍",
    "panes": "🪟",
    "appearance": "🎨",
    "other": "❓",
}

def parse_arguments():
    parser = argparse.ArgumentParser(description="Prettify and organize configuration files with visual separators and comments.")
    parser.add_argument('--file', '-f', required=True, help='Path to the configuration file.')
    parser.add_argument('--format', '-t', required=True, choices=['toml', 'yaml', 'ini'], help='Format of the configuration file.')
    parser.add_argument('--separator', '-s', choices=SEPARATOR_STYLES.keys(), default='equals', help='Style of separator lines.')
    parser.add_argument('--backup', '-b', action='store_true', help='Create a backup of the original config file.')
    parser.add_argument('--emoji', '-e', action='store_true', help='Use emojis in section headers.')
    parser.add_argument('--output', '-o', help='Path to save the prettified config. Defaults to overwriting the original file.')
    return parser.parse_args()

def backup_file(file_path):
    backup_path = f"{file_path}.backup"
    shutil.copyfile(file_path, backup_path)
    print(f"Backup created at {backup_path}")

def load_config(file_path, fmt):
    with open(file_path, 'r') as f:
        if fmt == 'toml':
            return toml.load(f)
        elif fmt == 'yaml':
            return yaml.safe_load(f)
        elif fmt == 'ini':
            parser = ConfigParser()
            parser.read_file(f)
            return parser
    return None

def save_config(data, file_path, fmt):
    with open(file_path, 'w') as f:
        if fmt == 'toml':
            toml.dump(data, f)
        elif fmt == 'yaml':
            yaml.dump(data, f, sort_keys=False)
        elif fmt == 'ini':
            if isinstance(data, ConfigParser):
                data.write(f)
            else:
                print("Invalid INI data.")
    print(f"Prettified config saved to {file_path}")

def generate_separator(style, title=None, emoji=False):
    sep = SEPARATOR_STYLES.get(style, SEPARATOR_STYLES['equals'])
    if emoji and title:
        emoji_icon = EMOJI_SEPARATORS.get(title.lower(), EMOJI_SEPARATORS['other'])
        return f"# {sep} {emoji_icon} {title} {emoji_icon} {sep}"
    elif title:
        return f"# {sep} {title} {sep}"
    else:
        return f"# {sep} #"

def prettify_toml(config, style, use_emoji):
    lines = []
    for table, content in config.items():
        if isinstance(content, list):  # array of tables
            for pane in content:
                lines.append(generate_separator(style, table.capitalize(), use_emoji))
                for key, value in pane.items():
                    lines.append(f'{key} = "{value}"' if isinstance(value, str) else f'{key} = {value}')
                lines.append("")  # add empty line for spacing
        elif isinstance(content, dict):
            lines.append(generate_separator(style, table.capitalize(), use_emoji))
            lines.append(f"[{table}]")
            for key, value in content.items():
                if isinstance(value, dict):
                    lines.append(f"  [{table}.{key}]")
                    for subkey, subvalue in value.items():
                        lines.append(f'  {subkey} = "{subvalue}"' if isinstance(subvalue, str) else f'  {subkey} = {subvalue}')
                elif isinstance(value, list):
                    lines.append(f"{key} = {value}")
                else:
                    lines.append(f'{key} = "{value}"' if isinstance(value, str) else f'{key} = {value}')
            lines.append("")  # add empty line for spacing
    return "\n".join(lines)

def prettify_yaml(config, style, use_emoji):
    lines = []
    for section, content in config.items():
        lines.append(generate_separator(style, section.capitalize(), use_emoji))
        lines.append(f"{section}:")
        if isinstance(content, list):
            for item in content:
                lines.append("  -")
                for key, value in item.items():
                    lines.append(f"    {key}: {value}")
        elif isinstance(content, dict):
            for key, value in content.items():
                if isinstance(value, dict):
                    lines.append(f"  {key}:")
                    for subkey, subvalue in value.items():
                        lines.append(f"    {subkey}: {subvalue}")
                elif isinstance(value, list):
                    lines.append(f"  {key}: {value}")
                else:
                    lines.append(f"  {key}: {value}")
        lines.append("")  # Add empty line for spacing
    return "\n".join(lines)

def prettify_ini(config, style, use_emoji):
    lines = []
    for section in config.sections():
        lines.append(generate_separator(style, section.capitalize(), use_emoji))
        lines.append(f"[{section}]")
        for key, value in config.items(section):
            lines.append(f"{key} = {value}")
        lines.append("")  # Add empty line for spacing
    return "\n".join(lines)

def prettify_config(data, fmt, style, use_emoji):
    if fmt == 'toml':
        return prettify_toml(data, style, use_emoji)
    elif fmt == 'yaml':
        return prettify_yaml(data, style, use_emoji)
    elif fmt == 'ini':
        return prettify_ini(data, style, use_emoji)
    else:
        raise ValueError("Unsupported format")

def main():
    args = parse_arguments()
    file_path = args.file
    fmt = args.format
    style = args.separator
    backup = args.backup
    use_emoji = args.emoji
    output = args.output if args.output else file_path

    if not os.path.isfile(file_path):
        print(f"Error: File '{file_path}' does not exist.")
        sys.exit(1)

    if backup:
        backup_file(file_path)

    try:
        config = load_config(file_path, fmt)
    except Exception as e:
        print(f"Error loading config file: {e}")
        sys.exit(1)

    try:
        prettified = prettify_config(config, fmt, style, use_emoji)
    except Exception as e:
        print(f"Error prettifying config: {e}")
        sys.exit(1)

    try:
        save_config(prettified, output, fmt)
    except Exception as e:
        print(f"Error saving prettified config: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
  