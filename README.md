# Dotfiles

This project holds configuration files for my local environment.

The following video was where I got the idea for this approach (specifically
using stow).

https://www.youtube.com/watch?v=y6XCebnB9gs&t=5s

## Prerequisites

* `brew install stow`

## Installation Instructions

Clone this repo into HOME directory. Then run `stow .` from instead the root
folder of this project.

This will create symbolic links in the project's parent directory which match
the structure of the files contained within this project.

## Usage Notes

If certain "includes" need to be sourced before other make sure they are named
alphabetically based on when they need to be sourced.
