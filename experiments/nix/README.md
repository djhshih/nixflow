# Experiments using Nix

## Purpose

Explore whether Nix can be used to generate CWL files for running workflows.

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

