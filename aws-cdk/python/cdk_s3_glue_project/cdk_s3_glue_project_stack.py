from aws_cdk import core
from aws_cdk.aws_s3 import Bucket, BlockPublicAccess, LifecycleRule, BucketEncryption
from aws_cdk.aws_glue import CfnDatabase, CfnTable

class CdkS3GlueStack(core.Stack):
    def __init__(self, scope: core.Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)

        # Define environment variable
        environment = "development"  # Replace with your environment (e.g., staging, production)

        # S3 Bucket
        log_bucket = Bucket(
            self,
            "LogBucket",
            bucket_name=f"{environment}-logs-cdk-example",
            versioned=True,
            encryption=BucketEncryption.S3_MANAGED,
            lifecycle_rules=[
                LifecycleRule(
                    id="DeleteLogsAfter60Days",
                    expiration=core.Duration.days(60)
                )
            ],
            block_public_access=BlockPublicAccess.BLOCK_ALL
        )

        # Glue Database
        glue_database = CfnDatabase(
            self,
            "GlueDatabase",
            catalog_id=self.account,
            database_input={
                "name": f"{environment}-logs"
            }
        )

        # Glue Table
        glue_table = CfnTable(
            self,
            "GlueTable",
            catalog_id=self.account,
            database_name=glue_database.ref,
            table_input={
                "name": "access_logs",
                "tableType": "EXTERNAL_TABLE",
                "storageDescriptor": {
                    "columns": [
                        {"name": "timestamp", "type": "string"},
                        {"name": "DistributionId", "type": "string"},
                        {"name": "date", "type": "string"},
                        {"name": "time", "type": "string"},
                        {"name": "x_edge_location", "type": "string"},
                        {"name": "sc_bytes", "type": "string"},
                        {"name": "c_ip", "type": "string"},
                        {"name": "cs_method", "type": "string"},
                        {"name": "cs_Host", "type": "string"},
                        {"name": "cs_uri_stem", "type": "string"},
                        {"name": "sc_status", "type": "string"},
                        {"name": "cs_Referer", "type": "string"},
                        {"name": "cs_User_Agent", "type": "string"},
                        {"name": "cs_uri_query", "type": "string"},
                        {"name": "cs_Cookie", "type": "string"},
                        {"name": "x_edge_result_type", "type": "string"},
                        {"name": "x_edge_request_id", "type": "string"},
                        {"name": "x_host_header", "type": "string"},
                        {"name": "cs_protocol", "type": "string"},
                        {"name": "cs_bytes", "type": "string"},
                        {"name": "time_taken", "type": "string"},
                        {"name": "x_forwarded_for", "type": "string"},
                        {"name": "ssl_protocol", "type": "string"},
                        {"name": "ssl_cipher", "type": "string"},
                        {"name": "x_edge_response_result_type", "type": "string"},
                        {"name": "cs_protocol_version", "type": "string"},
                        {"name": "fle_status", "type": "string"},
                        {"name": "fle_encrypted_fields", "type": "string"},
                        {"name": "c_port", "type": "string"},
                        {"name": "time_to_first_byte", "type": "string"},
                        {"name": "x_edge_detailed_result_type", "type": "string"},
                        {"name": "sc_content_type", "type": "string"},
                        {"name": "sc_content_len", "type": "string"},
                        {"name": "sc_range_start", "type": "string"},
                        {"name": "sc_range_end", "type": "string"},
                        {"name": "timestamp_ms", "type": "string"}
                    ],
                    "location": f"s3://{log_bucket.bucket_name}/",
                    "inputFormat": "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat",
                    "outputFormat": "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat",
                    "serdeInfo": {
                        "serializationLibrary": "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe",
                        "parameters": {
                            "serialization.format": "1"
                        }
                    }
                },
                "partitionKeys": [
                    {"name": "year", "type": "integer"},
                    {"name": "month", "type": "integer"},
                    {"name": "day", "type": "integer"},
                    {"name": "hour", "type": "integer"}
                ]
                "parameters": {
                    "EXTERNAL": "TRUE",
                    "projection.enabled": "true",
                    "projection.year.type": "integer",
                    "projection.year.range": "2020,2030",
                    "projection.month.type": "integer",
                    "projection.month.range": "1,12",
                    "projection.day.type": "integer",
                    "projection.day.range": "1,31",
                    "projection.hour.type": "integer",
                    "projection.hour.range": "0,23",
                    "storage.location.template": f"s3://{log_bucket.bucket_name}/year=$${{year}}/month=$${{month}}/day=$${{day}}/hour=$${{hour}}/"
                },
            }
        )
