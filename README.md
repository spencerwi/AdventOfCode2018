# Advent of Code solutions for 2018

## Requirements

[Crystal-lang](https://crystal-lang.org), at least 0.27.0

## Running tests

Most (but not all) solutions have tests, in a `spec/` subdirectory in the day's
directory. To run the test, cd into the day's dir and run `crystal spec`.

## What's the deal with that weird `unless PROGRAM_NAME` thing?

Normally, you write your "library" logic in one Crystal file and your executable
"wrapper" in another file, and your specs import the library file and test it.

However, that's a lot of overhead for these problems, but I like the idea of 
being able to TDD my way to solutions given the sample input/outputs, so each of
my solutions checks to see if the file is being imported as part of running 
specs (by looking at the current executable name and matching against a special
name Crystal uses for the `crystal spec` command) and if so, doesn't execute the
"main"/"executable" logic.
