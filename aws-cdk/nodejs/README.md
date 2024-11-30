## Commands to Get Started

### 1. Install CDK and Initialize the Project
```bash
mkdir cdk-s3-glue-project
cd cdk-s3-glue-project
cdk init app --language=typescript
```

### 2. Install Required Dependencies
```bash
npm install aws-cdk-lib constructs
```

### 3. Run CDK Synth
Generate the CloudFormation templates for your stack:
```bash
cdk synth
```
