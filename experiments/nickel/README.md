# Nickel CWL Builder

Build CWL (Common Workflow Language) workflows from Nickel definitions.

## Quick Start

```bash
# Build all CWL workflows
make all

# Run a workflow
make output
```

## Scripts

- `build.sh <def>` - Build a single task/workflow (e.g., `./build.sh cipher`)
- `make all` - Build all CWL files
- `make output` - Run workflows with sample inputs
- `make clean` - Clean generated files

## Available Definitions

- Tasks: `caesar`, `tr`, `csv2ncl`
- Workflows: `cipher`, `letter-cases`

## Project Structure

```
nixflow/dfn/    # Task/workflow definitions
nixflow/lib/     # Library functions
cwl/             # Generated CWL files
in/              # Sample inputs
```