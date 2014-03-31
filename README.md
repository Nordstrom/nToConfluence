# Stash To Confluence

## Overview
Stash kinda stinks when it comes to hosting documentation for your project. Well, ok, it is almost completely lacking in that area.

The Solution: Upload your source-controlled documentation into confluence. This can be done as part of your CD valuestream, or on a seperate git post-commit hook.

## Prereqs:
1. Ruby 1.9.3
2. Install the gems via Gemfile

## Info
The header.md is prefixed to all the documents to let users understand that edits will be removed the next time this tool is run.  Feel free to modify it to fit your needs.

- The README.md file will become a root page in your space.
- All markdown files in your docs folder will become children of your README.
- The title of the README page will be the name of the project.

## TODO
1. Add logic to switch between stash and filesystem
2. error handling
3. Remove pages from confluence that have been removed from stash
