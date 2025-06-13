// bootstrapSecrets.ts
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";

import {
  STSClient,
  AssumeRoleCommand,
  GetCallerIdentityCommand,
} from "@aws-sdk/client-sts";

import { InsizonAwsS3 } from "./Aws/index";

const REGION = "us-east-2";
const SERVICE_ROLE_NAME = "serviceAccount";   // ← Terraform creates this role

export async function initAws(secretName: string) {
  /* 1. Pull secret from Secrets Manager */
  const sm = new SecretsManagerClient({ region: REGION });
  const { SecretString } = await sm.send(
    new GetSecretValueCommand({ SecretId: secretName })
  );
  if (!SecretString) throw new Error(`Secret "${secretName}" empty`);
  const creds = JSON.parse(SecretString);

  /* 2. Use user creds to call STS */
  const sts = new STSClient({
    region: REGION,
    credentials: {
      accessKeyId: creds.AWS_IAM_ServiceUser_AccessKeyId,
      secretAccessKey: creds.AWS_IAM_ServiceUser_SecretAccessKey,
    },
  });

  /* 3. Discover account ID */
  const idResp = await sts.send(new GetCallerIdentityCommand({}));
  const accountId = idResp.Account;
  if (!accountId) throw new Error("Unable to determine AWS account ID");

  /* 4. Assume the serviceAccount role */
  const assumeResp = await sts.send(
    new AssumeRoleCommand({
      RoleArn: `arn:aws:iam::${accountId}:role/${SERVICE_ROLE_NAME}`,
      RoleSessionName: "insizon-app-session",
      DurationSeconds: 3600,
    })
  );
  const roleCreds = assumeResp.Credentials;
  if (!roleCreds) throw new Error("AssumeRole returned no credentials");

  /* 5. Return helper wired with temporary role creds */
  return new InsizonAwsS3({
    isProd: process.env.NODE_ENV === "production" ? "true" : "false",
    Bucket_name:                          creds.Bucket_name,
    AWS_IAM_ServiceUser_AccessKeyId:      roleCreds.AccessKeyId,
    AWS_IAM_ServiceUser_SecretAccessKey:  roleCreds.SecretAccessKey,
    AWS_IAM_ServiceUser_SessionToken:     roleCreds.SessionToken,
    AWS_Cloudfront_Private_Key:           creds.AWS_Cloudfront_Private_Key,
    AWS_CloudFront_KeyPairId:             creds.AWS_CloudFront_KeyPairId,
    AWS_Cloudfront_DistributionSubdomain: creds.AWS_Cloudfront_DistributionSubdomain,
  });
}
