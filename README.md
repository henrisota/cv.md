<div align="center">
  <h1 align="center">
    cv.md
  </h1>
  <p>Streamline generation of your CV with reproducible configurations</p>
</div>

## Motive

Many prorietary tools for creating CVs out there feel both restrictive and bloated. Typesetting your own CV through LaTeX offers greater flexibility at the cost of time and complexity. Quickly you become frustrated and wish there was a simpler solution.

## Solution

`cv.md` converts your CV from Markdown to PDF with [pandoc](https://pandoc.org/) and [WeasyPrint](https://weasyprint.org/), built through a [Nix](https://nixos.org/) flake so the PDF comes out byte-identical on every machine, fonts included.

## Installation

Ensure you have [Nix](https://nixos.org/download/) installed with flakes enabled. Optionally use [direnv](https://direnv.net/) to enter the development shell, which provides [Just](https://github.com/casey/just) and installs the git hooks.

## Styling

Customize the CV's style, including page size and margins, by editing [src/styles.css](./src/styles.css). Fonts come from nixpkgs; add one to `fontDirectories` in [flake.nix](./flake.nix) before referring to it in the stylesheet.

## Usage

### Building

To generate the CV into `output/`, run

```shell
just build
```

or, without Just, `nix build`, which writes it to `result/`.

### Writing

Replace the sample in [src/main.md](./src/main.md) with your own CV. Set `pagetitle` and `author-meta` in its front matter, which become the PDF's title and author, and `fileName` in [flake.nix](./flake.nix), so the file carries your name.

Keep the sample's shape, which is what applicant tracking systems parse and recruiters skim most reliably:

- a `##` heading for each section, using common names such as Work Experience and Education
- a `###` line for each role, as `Title - Employer` followed by the dates in backticks, which are set flush right
- short bullets under each role, each stating a result and, where you can, a number

To continuously build the CV while writing it, run

```shell
just watch
```

### Checking

To build the CV, check that every word extracts intact and that it fits the page limit, and run the linters, run

```shell
just check
```

### Releasing

Push a tag starting with `v` to publish the CV as a GitHub release.

## Structure

Source files for your CV are located in [src](./src/).
