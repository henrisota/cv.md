<div align="center">
  <h1 align="center">
    cv.md
  </h1>
  <p>Streamline generation of your CV with reproducible configurations</p>
</div>

## Motive

Many prorietary tools for creating CVs out there feel both restrictive and bloated. Typesetting your own CV through LaTeX offers greater flexibility at the cost of time and complexity. Quickly you become frustrated and wish there was a simpler solution.

## Solution

`cv.md` uses [gotenberg](https://gotenberg.dev/) underneath to generate your CV in PDF format, ensuring cross-platform compatibility through [Docker](https://www.docker.com/), and can be managed using [Just](https://github.com/casey/just) or [devenv](https://devenv.sh/).

## Installation

Ensure you have `docker` installed, along with either `just` or `devenv`, depending on your preference.

Use commands directly with `devenv`, or prepend `just` to use them.

## Styling

Modify the output format by editing the settings for `gotenberg` in [devenv.nix](./devenv.nix) or [Justfile](./Justfile), based on [`gotenberg` properties](https://gotenberg.dev/docs/routes#page-properties-chromium).

Customize the CV's style by editing [src/styles.css](./src/styles.css).

## Usage

### Setup

To set up, run

```shell
setup
```

### Building

To generate the CV, run

```shell
build-cv
```

### Writing

To continuously build the CV while writing it, run

```shell
write-cv
```

## Structure

Source files for your CV are located in [src](./src/).
