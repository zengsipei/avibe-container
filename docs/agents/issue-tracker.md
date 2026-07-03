# Issue tracker: GitHub

Issues and PRDs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- Create/read/list/comment/label/close issues with `gh issue ...`.
- Infer the repo from `git remote -v`; `gh` does this automatically inside a clone.

## Pull requests as a triage surface

PRs as a request surface: no.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.

## Wayfinding operations

A map is a GitHub issue labelled `wayfinder:map`; child tickets are linked sub-issues where available, otherwise task-list entries with `Part of #<map>`.
