import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as glue from 'aws-cdk-lib/aws-glue';

export class CdkS3GlueStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const environment = 'development'; // Replace with your desired environment (e.g., 'staging' or 'production')

    // S3 Bucket
    const logBucket = new s3.Bucket(this, 'LogBucket', {
      bucketName: `${environment}-logs-cdk-example`,
      versioned: true,
      encryption: s3.BucketEncryption.S3_MANAGED,
      lifecycleRules: [
        {
          id: 'DeleteLogsAfter60Days',
          expiration: cdk.Duration.days(60),
        },
      ],
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
    });

    // Glue Database
    const glueDatabase = new glue.CfnDatabase(this, 'GlueDatabase', {
      catalogId: this.account,
      databaseInput: {
        name: `${environment}-logs`,
      },
    });

    // Glue Table
    new glue.CfnTable(this, 'GlueTable', {
      catalogId: this.account,
      databaseName: glueDatabase.ref,
      tableInput: {
        name: 'access_logs',
        tableType: 'EXTERNAL_TABLE',
        storageDescriptor: {
          columns: [
            { name: 'timestamp', type: 'string' },
            { name: 'DistributionId', type: 'string' },
            { name: 'date', type: 'string' },
            { name: 'time', type: 'string' },
            { name: 'x_edge_location', type: 'string' },
            { name: 'sc_bytes', type: 'string' },
            { name: 'c_ip', type: 'string' },
            { name: 'cs_method', type: 'string' },
            { name: 'cs_Host', type: 'string' },
            { name: 'cs_uri_stem', type: 'string' },
            { name: 'sc_status', type: 'string' },
            { name: 'cs_Referer', type: 'string' },
            { name: 'cs_User_Agent', type: 'string' },
            { name: 'cs_uri_query', type: 'string' },
            { name: 'cs_Cookie', type: 'string' },
            { name: 'x_edge_result_type', type: 'string' },
            { name: 'x_edge_request_id', type: 'string' },
            { name: 'x_host_header', type: 'string' },
            { name: 'cs_protocol', type: 'string' },
            { name: 'cs_bytes', type: 'string' },
            { name: 'time_taken', type: 'string' },
            { name: 'x_forwarded_for', type: 'string' },
            { name: 'ssl_protocol', type: 'string' },
            { name: 'ssl_cipher', type: 'string' },
            { name: 'x_edge_response_result_type', type: 'string' },
            { name: 'cs_protocol_version', type: 'string' },
            { name: 'fle_status', type: 'string' },
            { name: 'fle_encrypted_fields', type: 'string' },
            { name: 'c_port', type: 'string' },
            { name: 'time_to_first_byte', type: 'string' },
            { name: 'x_edge_detailed_result_type', type: 'string' },
            { name: 'sc_content_type', type: 'string' },
            { name: 'sc_content_len', type: 'string' },
            { name: 'sc_range_start', type: 'string' },
            { name: 'sc_range_end', type: 'string' },
            { name: 'timestamp_ms', type: 'string' },
          ],
          location: `s3://${logBucket.bucketName}/`,
          inputFormat: 'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat',
          outputFormat: 'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat',
          serdeInfo: {
            serializationLibrary: 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe',
            parameters: {
              'serialization.format': '1',
            },
          },
        },
        parameters: {
          EXTERNAL: 'TRUE',
          'projection.enabled': 'true',
          'projection.year.type': 'integer',
          'projection.year.range': '2020,2030',
          'projection.month.type': 'integer',
          'projection.month.range': '1,12',
          'projection.day.type': 'integer',
          'projection.day.range': '1,31',
          'projection.hour.type': 'integer',
          'projection.hour.range': '0,23',
          'storage.location.template': `s3://${logBucket.bucketName}/year=$${'{year}'}/month=$${'{month}'}/day=$${'{day}'}/hour=$${'{hour}'}/`,
        },
        partitionKeys: [
          { name: 'year', type: 'integer' },
          { name: 'month', type: 'integer' },
          { name: 'day', type: 'integer' },
          { name: 'hour', type: 'integer' },
        ],
      },
    });
  }
}
