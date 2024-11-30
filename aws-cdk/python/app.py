# app.py
import aws_cdk as cdk
from cdk_s3_glue_project.cdk_s3_glue_project_stack import CdkS3GlueStack

app = cdk.App()
CdkS3GlueStack(app, "CdkS3GlueStack")
app.synth()
