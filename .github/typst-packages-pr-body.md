<!--
Synced from https://github.com/typst/packages/blob/main/.github/pull_request_template.md on 2026-07-19.
Keep the structure aligned with upstream; scripts/check_ci_contract.py guards the required sections.
-->

<!--
Thanks for submitting a package! Please read and follow the submission guidelines detailed in the repository's README and check the boxes below. Please name your PR as `name:version` of the submitted package.

If you want to make a PR for something other than a package submission, just delete all this and make a plain PR.
-->

I am submitting
- [ ] a new package
- [x] an update for a package

<!--
Please add a brief description of your package below and explain why you think it is useful to others. If this is an update, please briefly say what changed.
-->

Description: This update brings brilliant-cv to version {{VERSION}}.

The submitted directory is the exact payload validated from the immutable `v{{VERSION}}` tag on Typst 0.14.0 and 0.15.1.

<!--
These things need to be checked for a new submission to be merged. If you're just submitting an update, you can delete the following section.
-->

I have read and followed the submission guidelines and, in particular, I
- [x] selected [a name](https://github.com/typst/packages/blob/main/docs/manifest.md#naming-rules) that isn't the most obvious or canonical name for what the package does
  - Explanation: `brilliant-cv` is the existing accepted package name; the non-descriptive `brilliant` prefix distinguishes it from a canonical `cv` package name.
- [x] added a [`typst.toml`](https://github.com/typst/packages/blob/main/docs/manifest.md#package-metadata) file with all required keys
- [x] added a [`README.md`](https://github.com/typst/packages/blob/main/docs/documentation.md) with documentation for my package
- [x] have chosen [a license](https://github.com/typst/packages/blob/main/docs/licensing.md) and added a `LICENSE` file or linked one in my `README.md`
- [x] tested my package locally on my system and it worked
- [x] [`exclude`d](https://github.com/typst/packages/blob/main/docs/tips.md#what-to-commit-what-to-exclude) PDFs or README images, if any, but not the LICENSE

<!--
The following box only needs to be checked for **template** submissions. If you're submitting a package that isn't a template, you can delete the following section. See the guidelines section about licenses in the README for more details.
-->
- [x] ensured that my package is licensed such that users can use and distribute the contents of its template directory without restriction, after modifying them through normal use.
