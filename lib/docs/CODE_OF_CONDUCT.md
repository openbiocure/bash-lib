# Contributor Code of Conduct

## Our Pledge

In the interest of fostering an open and welcoming environment, we as contributors and maintainers pledge to make participation in our project and our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

## Our Standards

Examples of behavior that contributes to creating a positive environment include:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

Examples of unacceptable behavior by participants include:

- The use of sexualized language or imagery and unwelcome sexual attention or advances
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information, such as a physical or electronic address, without explicit permission
- Other conduct which could reasonably be considered inappropriate in a professional setting

## Enforcement of Shell Scripting Best Practices

This project enforces strict shell scripting best practices, including:

- **Mandatory use of `set -u` (nounset):** All scripts and modules must be robust against unbound variable errors. Contributors must ensure that all variable and array expansions are properly guarded (e.g., using `${var:-}` or `${array[index]:-}`) to prevent runtime errors.
- **CI Enforcement:** Our continuous integration (CI) system will run tests with `set -u` enabled. Contributions that do not comply with this policy will not be accepted.

## Our Responsibilities

Project maintainers are responsible for clarifying the standards of acceptable behavior and are expected to take appropriate and fair corrective action in response to any instances of unacceptable behavior.

## Scope

This Code of Conduct applies both within project spaces and in public spaces when an individual is representing the project or its community.

## Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project team. All complaints will be reviewed and investigated and will result in a response that is deemed necessary and appropriate to the circumstances.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage], version 1.4, available at https://contributor-covenant.org/version/1/4

[homepage]: https://contributor-covenant.org
