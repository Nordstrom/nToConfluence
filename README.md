# Stash To Confluence - needs new name!

## Overview
Creates content in Confluence from various sources.

## Prereqs:
1. Ruby 1.9.3
2. Install the gems via Gemfile

## Info
The header.md is prefixed to all the documents to let users understand that edits will be removed the next time this tool is run.  Feel free to modify it to fit your needs.

## Commands
Do a --help to get information

### Stash
Stash kinda stinks when it comes to hosting documentation for your project. Well, ok, it is almost completely lacking in that area.

The Solution: Upload your source-controlled markdown documentation into confluence. This can be done as part of your CD valuestream, or on a seperate git post-commit hook.

- The README.md file will become a root page in your space.
- All markdown files in your docs folder will become children of your README.
- The title of the README page will be the name of the project.

### Knife
Generates a nice "report" from a knife query and uploads it to confluence.  The report includes server name, ip address, environment, and runlist.

### Disk
Takes the markdown files in a folder and uploads them into Confluence.

## TODO
1. error handling
2. Remove pages from confluence that have been removed from stash
