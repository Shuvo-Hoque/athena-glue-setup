resource "random_id" "bucket_hash" {
  byte_length = 4
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.environment}-logs-${random_id.bucket_hash.hex}"

  # Bucket configuration with recommended settings
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "DeleteLogsAfter2Months"
    status = "Enabled"

    expiration {
      days = 60
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket_public_access" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_glue_catalog_database" "athena_glue_database" {
  name = "${var.environment}-logs"

  parameters = {
    classification = "parquet" # Optional parameter for metadata
  }

  tags = {
    Environment = var.environment
  }
}


resource "aws_glue_catalog_table" "athena_glue_table" {
  database_name = aws_glue_catalog_database.athena_glue_database.name
  name          = "access_logs"

  table_type = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.log_bucket.bucket}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    # Columns
    columns {
      name = "timestamp"
      type = "string"
    }

    columns {
      name = "DistributionId"
      type = "string"
    }

    columns {
      name = "date"
      type = "string"
    }

    columns {
      name = "time"
      type = "string"
    }

    columns {
      name = "x_edge_location"
      type = "string"
    }

    columns {
      name = "sc_bytes"
      type = "string"
    }

    columns {
      name = "c_ip"
      type = "string"
    }

    columns {
      name = "cs_method"
      type = "string"
    }

    columns {
      name = "cs_Host"
      type = "string"
    }

    columns {
      name = "cs_uri_stem"
      type = "string"
    }

    columns {
      name = "sc_status"
      type = "string"
    }

    columns {
      name = "cs_Referer"
      type = "string"
    }

    columns {
      name = "cs_User_Agent"
      type = "string"
    }

    columns {
      name = "cs_uri_query"
      type = "string"
    }

    columns {
      name = "cs_Cookie"
      type = "string"
    }

    columns {
      name = "x_edge_result_type"
      type = "string"
    }

    columns {
      name = "x_edge_request_id"
      type = "string"
    }

    columns {
      name = "x_host_header"
      type = "string"
    }

    columns {
      name = "cs_protocol"
      type = "string"
    }

    columns {
      name = "cs_bytes"
      type = "string"
    }

    columns {
      name = "time_taken"
      type = "string"
    }

    columns {
      name = "x_forwarded_for"
      type = "string"
    }

    columns {
      name = "ssl_protocol"
      type = "string"
    }

    columns {
      name = "ssl_cipher"
      type = "string"
    }

    columns {
      name = "x_edge_response_result_type"
      type = "string"
    }

    columns {
      name = "cs_protocol_version"
      type = "string"
    }

    columns {
      name = "fle_status"
      type = "string"
    }

    columns {
      name = "fle_encrypted_fields"
      type = "string"
    }

    columns {
      name = "c_port"
      type = "string"
    }

    columns {
      name = "time_to_first_byte"
      type = "string"
    }

    columns {
      name = "x_edge_detailed_result_type"
      type = "string"
    }

    columns {
      name = "sc_content_type"
      type = "string"
    }

    columns {
      name = "sc_content_len"
      type = "string"
    }

    columns {
      name = "sc_range_start"
      type = "string"
    }

    columns {
      name = "sc_range_end"
      type = "string"
    }

    columns {
      name = "timestamp_ms"
      type = "string"
    }
  }

  partition_keys {
    name = "year"
    type = "integer"
  }

  partition_keys {
    name = "month"
    type = "integer"
  }

  partition_keys {
    name = "day"
    type = "integer"
  }

  partition_keys {
    name = "hour"
    type = "integer"
  }

  parameters = {
    EXTERNAL                    = "TRUE"
    "projection.enabled"        = "true"
    "projection.year.type"      = "integer"
    "projection.year.range"     = "2020,2030"
    "projection.month.type"     = "integer"
    "projection.month.range"    = "1,12"
    "projection.day.type"       = "integer"
    "projection.day.range"      = "1,31"
    "projection.hour.type"      = "integer"
    "projection.hour.range"     = "0,23"
    "storage.location.template" = "s3://${aws_s3_bucket.log_bucket.bucket}/year=$${year}/month=$${month}/day=$${day}/hour=$${hour}/"
    "serialization.format"      = "1" # Serialization handled here
  }
}
