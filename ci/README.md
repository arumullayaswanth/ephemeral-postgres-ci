# CI GitHub Variables

The CI workflow (`.github/workflows/ci.yml`) needs these repository variables.

Go to: **Repo -> Settings -> Secrets and variables -> Actions -> Variables tab
-> New repository variable**

| Variable name    | Value                                                             |
| ---------------- | ----------------------------------------------------------------- |
| `AWS_ROLE_ARN`   | Your OIDC IAM role ARN, e.g. `arn:aws:iam::123456789012:role/ci`  |
| `AWS_REGION`     | e.g. `us-east-1`                                                  |
| `DB_SECRET_NAME` | Terraform output `db_secret_name`, e.g. `ci/ephemeral-postgres-ci/db-admin` |

> Note: `DB_SECRET_NAME` is a **Variable**, not a Secret. It only holds the
> *name* of the Secrets Manager secret (a plain string), not the password.

No GitHub Secrets are needed:

- AWS login uses OIDC (via `AWS_ROLE_ARN`), not stored AWS keys.
- The DB password is fetched at runtime from Secrets Manager, not stored in GitHub.
