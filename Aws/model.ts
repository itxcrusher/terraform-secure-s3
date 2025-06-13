//Model
import { S3Client, PutObjectCommandInput } from "@aws-sdk/client-s3";





/**
 * @param Bucket_name - process.env.AWS_S3_Bucket
 * @param AWS_IAM_ServiceUser_AccessKeyId - process.env.AWS_S3_Access_Key
 * @param AWS_IAM_ServiceUser_SecretAccessKey - process.env.AWS_S3_Access_Secret_Access_Key
 * @param AWS_Cloudfront_Private_Key - The cloudfront presignedURL privatekey string
 * @param AWS_CloudFront_KeyPairId - The cloudfront presignedURL keyPairId string
 * @param AWS_Cloudfront_DistributionSubdomain - The cloudfront distribution you created for the bucket needed for presignedURls
 * @example distributionSubdomHere.cloudfront.net
 */
export interface IAWS_S3_StorageCredential {
  isProd: string;
  Bucket_name?: string;
  AWS_IAM_ServiceUser_AccessKeyId?: string;
  AWS_IAM_ServiceUser_SecretAccessKey?: string;
  AWS_IAM_ServiceUser_SessionToken?: string;
  AWS_Cloudfront_Private_Key?: string;
  AWS_CloudFront_KeyPairId?: string;
  AWS_Cloudfront_DistributionSubdomain?: string;
 }


export interface IAWS_S3_SetupCredentials {
  region: string | undefined;
  apiVersion: "2006-03-01",
  credentials: {
    accessKeyId: string | undefined;
    secretAccessKey: string | undefined;
  }
}


export interface IAws_S3_Setup_Output {
  Client: S3Client;
  CloudfrontObj: {
    cloudfront_privateKey: string;
    cloudfront_keyPairId: string;
    cloudfront_distributionSubdomain: string;
  }
}

 
 export interface IAws_S3_UploadImageS3_Input {
  imgBuffer: PutObjectCommandInput["Body"];
  mimeType: string;
  fileNameOverride?: string;
  FileExtension?: string;
 }


 export interface IAws_S3_DeleteImage_Input {
  ImageName: string;
 }
 

 export interface IAws_S3_GetSingleSignedCloudFrontImg {
  FileNameAssignedS3: string;
  DayExpire?: number;
 }

 export interface  IAws_S3_GetMultiSignedCloudFrontImg {
  FileNamesAssignedS3: Array<string>
  DayExpire?: number;
 }

 export interface IAws_S3_GetPresignedImageS3 {
  FileNamesAssignedS3: Array<string>
  DayExpire?: number;
 }


export interface IAWS_S3_PutObject_Params extends IS3_Putoject_Extra_Params {
  Bucket: string | undefined;
  Key: string | undefined;
  Body: ArrayBuffer | any;
  ContentType: string | undefined;
}


interface IS3_Putoject_Extra_Params {
  ACL?: "private" | "public-read" | "public-read-write" | "authenticated-read" | "aws-exec-read" | "bucket-owner-read" | "bucket-owner-full-control";
  CacheControl?: string;
  ContentDisposition?: string;
  ContentEncoding?: string;
  ContentLanguage?: string;
  ContentLength?: number;
  ContentMD5?: string;
  ChecksumAlgorithm?: "CRC32" | "CRC32C" | "SHA1" | "SHA256";
  ChecksumCRC32?: string;
  ChecksumCRC32C?: string;
  ChecksumSHA1?: string;
  ChecksumSHA256?: string;
  Expires?: Date | undefined;
  GrantFullControl?: string;
  GrantRead?: string;
  GrantReadACP?: string;
  GrantWriteACP?: string;
  Metadata?: Record<string, string>
  ServerSideEncryption?: "AES256" | "aws:kms" | "aws:kms:dsse";
  StorageClass?: "STANDARD" | "REDUCED_REDUNDANCY" | "STANDARD_IA" | "ONEZONE_IA" | "INTELLIGENT_TIERING" | "GLACIER" | "DEEP_ARCHIVE" | "OUTPOSTS" | "GLACIER_IR" | "SNOW" | "EXPRESS_ONEZONE";
  WebsiteRedirectLocation?: string;
  SSECustomerAlgorithm?: string;
  SSECustomerKey?: string;
  SSECustomerKeyMD5?: string;
  SSEKMSKeyId?: string;
  SSEKMSEncryptionContext?: string;
  BucketKeyEnabled?: boolean;
  RequestPayer?: "requester";
  Tagging?: string;
  ObjectLockMode?: "GOVERNANCE" | "COMPLIANCE";
  ObjectLockRetainUntilDate?: Date | undefined;
  ObjectLockLegalHoldStatus?: "ON" | "OFF";
  ExpectedBucketOwner?: string;
}


export interface IAWS_S3_PutObject_Response extends IAWS_S3_Metadata {
  BucketKeyEnabled: boolean;
  ChecksumCRC32: string;
  ChecksumCRC32C: string;
  ChecksumSHA1: string;
  ChecksumSHA256: string;
  ETag: string;
  Expiration: string;
  RequestCharged: {
    readonly requester: "requester"
  }
  SSECustomerAlgorithm: string;
  SSECustomerKeyMD5: string;
  SSEKMSEncryptionContext: string;
  SSEKMSKeyId: string;
  ServerSideEncryption: {
    readonly AES256: "AES256"
    readonly aws_kms: "aws:kms";
    readonly aws_kms_dsse: "aws:kms:dsse";
  }
  VersionId: string;
}


interface IAWS_S3_Metadata {
  $metadata: {
    httpStatusCode?: number | any;
    requestId?: string | any;
    extendedRequestId?: undefined | any;
    cfId?: undefined | any;
    attempts?: number | any;
    totalRetryDelay?: number | any;
  },
  MessageId: string | any;
}