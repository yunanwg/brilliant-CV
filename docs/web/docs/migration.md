# Migration from v1 to v2

With an existing CV project using the v1 version of the template, a migration is needed, including replacing some files and some content in certain files.

## Steps

### 1. Remove old submodule

Delete the `brilliant-CV` folder and `.gitmodules`. Future package management is handled directly by Typst.

### 2. Migrate metadata

Migrate all the config from `metadata.typ` by creating a new `metadata.toml`. Follow the example TOML file in the repo — it is rather straightforward to migrate.

### 3. Update entry points

For `cv.typ` and `letter.typ`, copy the new files from the repo, and adapt the modules you have in your project.

### 4. Update module files

In the module files under `modules_*/`:

**a.** Delete the old import `#import "../brilliant-CV/template.typ": *`, and replace it with the import statements from the new template files.

**b.** Due to the Typst path handling mechanism, one cannot directly pass the path string to some functions anymore. This concerns, for example, the logo argument in `cv-entry`, but also `cv-publication` as well. Some parameter names were changed, but most importantly, you should pass a function instead of a string (i.e. `image("logo.png")` instead of `"logo.png"`). Refer to the new template files for reference.

**c.** You might need to install `Roboto` and `Source Sans Pro` on your local system now, as new Typst package guidelines discourage including these large files.

**d.** Run `typst compile cv.typ` without passing the `font-path` flag. All should be good now — congrats!

!!! tip
    Feel free to [raise an issue](https://github.com/yunanwg/brilliant-CV/issues) for more assistance should you encounter a problem that you cannot solve on your own.
