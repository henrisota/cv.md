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

Replace the sample in [src/main.md](./src/main.md) with your own CV. Set `pagetitle` and `author-meta` in its front matter, which become the PDF's title and author; `author-meta` also names the file, as `Jane-Doe-CV.pdf`.

Keep the sample's shape, which is what applicant tracking systems parse and recruiters skim most reliably:

- a `##` heading for each section, using common names such as Work Experience and Education
- your contact details on one line directly under the `#` name
- a `###` line for each role, as the title followed by the dates in backticks, which are set flush right, then the employer on the next paragraph
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

## Keeping up with upstream

Clone this repository rather than generating from it, so your copy shares its history, and add it as a remote you only fetch from:

```shell
git clone https://github.com/henrisota/cv.md cv
cd cv
git remote rename origin cv.md
git remote set-url --push cv.md DISABLE
git config merge.ours.driver true
```

Point `origin` at your own repository. To take improvements to the build, checks and styling, run

```shell
git fetch cv.md
git merge cv.md/main
```

[.gitattributes](./.gitattributes) keeps your `src/main.md` through every merge, given the `merge.ours.driver` setting above. Changes to `src/styles.css` merge normally, conflicting only where you restyled the same lines.

## Structure

Source files for your CV are located in [src](./src/).
