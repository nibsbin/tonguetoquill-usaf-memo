# Configuration Single Source of Truth

**Status:** Archived (Implemented)

## TL;DR

Configuration constants must be defined in exactly one place (`config.typ`). Other modules import and reference these values—never redefine them.

## When to Use

Apply this principle whenever adding new configuration:

- Spacing constants → `config.typ`
- Typography defaults → `config.typ`
- Document counters → `config.typ`
- Color definitions → `config.typ`

## How

1. Define constants in `config.typ` (no dependencies, pure constants)
2. Import what you need: `#import "config.typ": spacing, paragraph-config`
3. Reference imported values in utility functions

## Gotchas

- **Never** redefine config values in other modules—creates drift risk
- If `utils.typ` needs a config value, import it; don't copy it
- Config flows one direction: `config.typ` → consumers

## Benefits

- Single location for all configuration changes
- No synchronization between files
- Clear dependency direction
