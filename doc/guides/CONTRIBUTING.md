# Contribution Guidelines

To maintain a professional workflow and high traceability, please follow these standards.

## 1. Commit Message Convention

We use **Conventional Commits**. This makes the history readable and allows for automated changelog generation.

**Format**: `<type>(<scope>): <description>`

- **feat**: A new feature (e.g., `feat(editor): add markdown support`)
- **fix**: A bug fix (e.g., `fix(ai): handle timeout error`)
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Maintenance tasks, dependency updates, dead code removal

## 2. Branch Naming

Use `feature/short-description` or `fix/short-description`.

## 3. Code Standards

- Follow the **Feature-first architecture** patterns defined in [ARCHITECTURE.md](../architecture/ARCHITECTURE.md).
- Use **Riverpod** for state management.
- Maintain strict separation between layers (View -> State -> Data).
- Run `dart format .` before committing.
- Run `dart analyze` to check for issues.
