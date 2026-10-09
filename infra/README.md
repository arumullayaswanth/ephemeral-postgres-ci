# Steps

## 1. Create the S3 bucket (for Terraform state)

1. AWS Console -> S3 -> Create bucket.
2. Name it, e.g. `my-tf-state-bucket`.
3. Enable Bucket Versioning.
4. Enable Default encryption.
5. Create.

## 2. Create the OIDC provider

1. AWS Console -> IAM -> Identity providers -> Add provider.
2. Provider type: OpenID Connect.
3. Provider URL: `https://token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Add provider.

## 3. Create the IAM role for GitHub

1. IAM -> Roles -> Create role.
2. Trusted entity: Web identity.
3. Identity provider: the one from step 2. Audience: `sts.amazonaws.com`.
4. GitHub org/repo: your repo.
5. Attach permissions: EC2, RDS, Secrets Manager, and S3 access to your state bucket.
6. Name it, create, and copy the Role ARN.

Trust policy (replace `ACCOUNT_ID` and `OWNER/REPO`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:OWNER/REPO:*"
        }
      }
    }
  ]
}
```

## 4. Add GitHub variables

Repo -> Settings -> Secrets and variables -> Actions -> Variables -> New variable.

| Name              | Value                               |
| ----------------- | ----------------------------------- |
| `AWS_ROLE_ARN`    | the Role ARN from step 3            |
| `AWS_REGION`      | `us-east-1`                         |
| `TF_STATE_BUCKET` | the bucket name from step 1         |

## 5. Run the pipeline (create)

1. Repo -> Actions -> Terraform -> Run workflow.
2. Action: `apply`.
3. Run workflow.
4. Wait for it to finish. On success it prints the outputs (RDS endpoint, secret name, EC2 instance id).

## 6. Connect to the EC2 instance

Use SSM Session Manager:

1. AWS Console -> EC2 -> Instances -> select `ephemeral-postgres-ci-client`.
2. Connect -> Session Manager -> Connect.

## 7. Connect to the database from EC2

Inside the EC2 session:

```bash
SECRET=$(aws secretsmanager get-secret-value --secret-id ci/ephemeral-postgres-ci/db-admin --region us-east-1 --query SecretString --output text)
export PGHOST=$(echo $SECRET | jq -r .PGHOST)
export PGPORT=$(echo $SECRET | jq -r .PGPORT)
export PGUSER=$(echo $SECRET | jq -r .PGUSER)
export PGPASSWORD=$(echo $SECRET | jq -r .PGPASSWORD)
export PGDATABASE=$(echo $SECRET | jq -r .PGADMINDB)
psql
```

## 8. See the table and the data

```sql
-- list all databases
\l

-- list all tables in the current database
\dt

-- describe the widget table (columns, types, keys)
\d widget

-- see the seeded rows
SELECT * FROM widget;

-- count rows
SELECT count(*) FROM widget;

-- see the orders table too
\dt
SELECT * FROM orders;

-- which database / user am I connected as
SELECT current_database(), current_user;

-- quit psql
\q
```

You should see the `widget` table with three rows seeded on first deploy.

## 9. Add more schema or data later

Add a new numbered file in the `migrations/` folder, e.g.
`migrations/004_add_customers.sql`. The same files are used by both:

- the CI workflow (`ci/migrate.py` applies them to each ephemeral database)
- the EC2 first-boot seed (Terraform concatenates `migrations/*.sql`)

Then run the CI workflow (`.github/workflows/ci.yml`) to test.

## 10. Destroy everything

1. Repo -> Actions -> Terraform -> Run workflow.
2. Action: `destroy`.
3. Confirm: type `destroy`.
4. Run workflow.
