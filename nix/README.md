# Experiments using Nix

## Purpose

This codebase evaluates different strategies for using Nix to generate CWL (Common Workflow Language) files for running workflows. It explores how Nix's declarative package management and derivation system can be leveraged to create portable, reproducible workflow definitions.

## Usage

Each approach is implemented in a separate directory:

- `VarDef/` - Uses CWL command line arguments to pass inputs
- `EnvDef/` - Uses CWL environmental variables to pass inputs  
- `WorkDir/` - Uses CWL InitialWorkDirRequirement to embed scripts

To build and run an example:

```bash
cd VarDef  # or EnvDef, WorkDir
make
```

## Approaches


### VarDef

Define inputs as command line arguments using CWL.

### Advantages
- Bash script can be used independently
- No optional features required for CWL runner 

### Disadvantage
- Requires the script to manually assign `$1`, `$2`, etc. to variables
- Use with other languages (e.g. Python) would require more work


### EnvDef

Define inputs as environmental variables CWL.

#### Advantages
- Bash script can be used independently
- Requires little change to Bash script

#### Disadvantages
- CWL runner must support EnvVarRequirement feature
- Use with other languages (e.g. Python) would be more awkward


### WorkDir

#### Advantages
- Bash script is embedded in Nix
- Minimal change to native code
- Easily generalizable to other languages

#### Disadvantages
- CWL runner must support InitialWorkDirRequirement feature

