# Athena and S3 Setup for Querying CloudFront Logs

This CloudFormation template configures an AWS S3 bucket and Athena Glue database and table to enable querying of CloudFront access logs. It is designed to work in both **staging** and **production** environments and provides lifecycle rules, public access restrictions, and a schema optimized for Parquet files.

---

## Features

- **S3 Bucket Configuration**:
  - Environment-specific bucket naming (e.g., `staging--logs`, `production--logs`).
  - Lifecycle rule to delete logs after 6 months (180 days).
  - Bucket versioning enabled for data durability.
  - Public access blocked for enhanced security.

- **Athena Glue Database**:
  - Creates a Glue Database specific to the environment for organized data querying.

- **Athena Glue Table**:
  - Schema for CloudFront logs with pre-defined columns matching the CloudFront log structure.
  - External table using Parquet format for efficient querying.
  - Partition projection for optimized querying by `year`, `month`, `day`, and `hour`.

---

## Deployment Instructions

1. **Pre-requisites**:
   - An AWS account with permissions to create S3 buckets, Glue databases, and tables.
   - CloudFront access logs enabled and directed to an S3 bucket.

2. **Deploy the Stack**:
   - Save the template as `cloudfront-logs-athena.yaml`.
   - Use AWS CLI or the AWS Management Console to deploy:
     ```bash
     aws cloudformation deploy \
       --template-file cloudfront-logs-athena.yaml \
       --stack-name CloudFrontLogsStack \
       --parameter-overrides Environment=staging
     ```

3. **Verify Resources**:
   - Check the created S3 bucket in your AWS Management Console under S3.
   - View the Glue Database and Table under AWS Glue in your AWS Console.

4. **Query CloudFront Logs**:
   - Open the Athena console.
   - Select the Glue database (e.g., `staging--logs`).
   - Run SQL queries on the `access_logs` table using the provided schema.

---

## Parameters

- **Environment**:
  - Specifies the deployment environment.
  - Default: `staging`
  - Allowed Values: `staging`, `production`

---

## Outputs

- **LogBucket**:
  - The name of the S3 bucket created for storing CloudFront logs.
  - Accessible through the CloudFormation stack output.

---

## Example Athena Query

```sql
SELECT 
  timestamp, 
  c_ip AS client_ip, 
  cs_method AS request_method, 
  cs_uri_stem AS request_uri, 
  sc_status AS status_code 
FROM 
  access_logs
WHERE 
  year = '2024' AND month = '11' AND day = '25'
LIMIT 100;
```

---

## Notes

- **Schema Details**:
  - Columns in the Glue table schema match the CloudFront log fields. See the table definition in the template for details.

- **Data Partitioning**:
  - The table uses `year`, `month`, `day`, and `hour` as partition keys for faster queries.

- **Lifecycle Management**:
  - Logs are automatically deleted after 180 days, helping manage costs.

---

## Contributing

Contributions are welcome! If you find any issues or want to add new features, feel free to open a pull request or create an issue.

---

## License

This project is licensed under the [MIT License](LICENSE).