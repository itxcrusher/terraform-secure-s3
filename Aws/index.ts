//Imports
import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand, HeadObjectCommand} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import * as cdn from "@aws-sdk/cloudfront-signer";
import { IAWS_S3_PutObject_Response, IAWS_S3_StorageCredential, 
  IAws_S3_UploadImageS3_Input, IAWS_S3_SetupCredentials,IAws_S3_DeleteImage_Input,IAws_S3_Setup_Output, IAws_S3_GetSingleSignedCloudFrontImg, 
  IAws_S3_GetMultiSignedCloudFrontImg, IAws_S3_GetPresignedImageS3, IAWS_S3_PutObject_Params } from "./model.js";




/** 
 * Access -
* Myself via website
* Nodejs server
* @remarks
* Generate urls from the server that will allow users to see the images for temp time.
* Urls can expire and generate different urls for different users.
* Also, can only generate urls if urser has access
*/
export class InsizonAwsS3 {

  //Property
  private cred: IAWS_S3_StorageCredential;

  //constructors
  constructor(cred: IAWS_S3_StorageCredential) {
    this.cred = cred;
  }


  private async setup(): Promise<IAws_S3_Setup_Output> {
    try {

      const AWS_IAM_ServiceUser_AccessKeyId = this.cred.AWS_IAM_ServiceUser_AccessKeyId;
      const AWS_IAM_ServiceUser_SecretAccessKey = this.cred.AWS_IAM_ServiceUser_SecretAccessKey;
      const AWS_Cloudfront_Private_Key = this.cred.AWS_Cloudfront_Private_Key;
      const AWS_CloudFront_KeyPairId = this.cred.AWS_CloudFront_KeyPairId;
      const AWS_Cloudfront_DistributionSubdomain = this.cred.AWS_Cloudfront_DistributionSubdomain;

      if (!AWS_IAM_ServiceUser_AccessKeyId) {
        throw new Error("AWS_IAM_ServiceUser_AccessKeyId is undefined");
      } else if (!AWS_IAM_ServiceUser_SecretAccessKey) {
        throw new Error("AWS_IAM_ServiceUser_SecretAccessKey is undefined");
      } else if (AWS_IAM_ServiceUser_AccessKeyId === AWS_IAM_ServiceUser_SecretAccessKey) {
        throw new Error("AWS_IAM_ServiceUser_AccessKeyId === AWS_IAM_ServiceUser_SecretAccessKey seems incorrect");
      } else if (!AWS_Cloudfront_Private_Key) {
        throw new Error("AWS_Cloudfront_Private_Key is undefined");
      } else if (!AWS_CloudFront_KeyPairId) {
        throw new Error("AWS_CloudFront_KeyPairId is undefined");
      } else if (!AWS_Cloudfront_DistributionSubdomain) {
        throw new Error("AWS_Cloudfront_DistributionSubdomain is undefined");
      } else if (!this.cred.Bucket_name) {
        throw new Error("this.cred.Bucket_name is undefined");
      }

      const S3_CONFIG: IAWS_S3_SetupCredentials = { 
        region: "us-east-2", 
        apiVersion: "2006-03-01", 
        credentials: { 
          accessKeyId: AWS_IAM_ServiceUser_AccessKeyId, 
          secretAccessKey: AWS_IAM_ServiceUser_SecretAccessKey,
          sessionToken: this.cred.AWS_IAM_ServiceUser_SessionToken
      } as any
    };

      const client = new S3Client(S3_CONFIG as any);

      return {
        Client: client,
        CloudfrontObj: {
          cloudfront_keyPairId: AWS_CloudFront_KeyPairId,
          cloudfront_privateKey: AWS_Cloudfront_Private_Key.replace(/\\\\n/gm, "\\n"),
          cloudfront_distributionSubdomain: AWS_Cloudfront_DistributionSubdomain
        }
      }
    } catch(err) {
      console.log("What is setup error");
      throw err;
    }
  }


  /**
   * Func used to upload image to s3 bucket
   * @remarks
   * This func is not restricted to only uploading image files
   * @param imgBuffer - The image binary data or ArrayBuffer
   * @param mimeType - The file type aka ContentType. Ex. (ex. image/png, application/json).
   * @link - https://mimetype.io/all-types
   * @param ext - The file extension you want append to file (ex. jpg, png, gif)
   * @param fileNameOverride - If string is supplied and is not name rand. The name will be overwritten in database. Insizon If null rand name will be used
   * @returns {Object} {fileNameAssignedS3, responseFull}
   * @property fileNameAssignedS3: A random image name that will assigned to the image with file ext. Should be stored in database.
   * @property responseFull: responseFull
   *
   */
  async uploadImageS3(props: IAws_S3_UploadImageS3_Input) {
    try {

        if (props.fileNameOverride !== undefined && props.fileNameOverride === ""){
          throw new Error("props.fileNameOverride is undefined");
        }

        if (props.FileExtension === undefined) {
          props.FileExtension = "jpg";
        }

        const setupAuth = await this.setup();
        
        //replaced with fake method literal string;
        const randomImageNameFake = "randomImageName";
        const imageName = props.fileNameOverride === undefined ? `${randomImageNameFake}.${props.FileExtension}` : props.fileNameOverride;
        const infoAboutFile: IAWS_S3_PutObject_Params = {
          Bucket: this.cred.Bucket_name,
          Key: imageName,
          Body: props.imgBuffer,
          ContentType: props.mimeType
        }

        //Will upload file to s3 bucket with option object
        const command = new PutObjectCommand(infoAboutFile);
        const response: any = await setupAuth.Client.send(command);
        const responseFull = response as IAWS_S3_PutObject_Response;
    
        return {
          fileNameAssignedS3: imageName,
          responseFull: responseFull
        };
    } catch(err) {
        console.log("What is uploadImageS3 error - ", err);
        throw err;
    }
  }


  /**
   * Get image from Aws S3 bucket with url that are signed 
   * @remarks
   * Cons - Will not be as fast with CDN such Cloudfare. Recommend calling getSignedCloudFrontImg method
   * @see
   * Used PowerAwsS3 method - getSignedCloudFrontImg instead
  */ 
  private async getPresignedImageS3(props: IAws_S3_GetPresignedImageS3) {
  
    try {
        const setupAuth = await this.setup();

        let presignedImageS3Array: Array<{PresignedURL: string, ExpireDate: string, ExpireDateDays: number}> = [];
        for (let i: number = 0; i < props.FileNamesAssignedS3.length; i++) {
          const infoAboutFile = {
            Bucket: this.cred.Bucket_name,
            Key: props.FileNamesAssignedS3[i]
          }

          //Will upload file to s3 bucket with option object
          const command = new GetObjectCommand(infoAboutFile);

          const expireDateDays = props.DayExpire ? Math.abs(props.DayExpire) <= 365 ? Math.abs(props.DayExpire) : 7 : 7;
          const expireDate = Math.floor(expireDateDays.valueOf() / 1000);
          const presignUrl = await getSignedUrl(setupAuth.Client, command, { expiresIn: expireDate });

          //Generate signed image url
          presignedImageS3Array.push({
            ExpireDateDays: expireDateDays,
            ExpireDate: expireDate.toString(),
            PresignedURL: presignUrl
          });
        }

        return presignedImageS3Array;
    } catch(err) {
        console.log("What is getPresignedImageS3 error - ", err);
        throw err;
    }
  }


  /**
   * Get image from CloudeFront cdn with image urls that expire 
   * @remarks
   * Recommeded method to call when retriving files or images from aws s3 bucket
   * @param imgObjs - Array of images that will be signed
   * @param time - How long should img stay valid
   * @exmple - `https://d5srgdsd3as6ay.cloudfront.net/${obj.imageName}`
  */

  /**
   * Get image from CloudeFront cdn with image urls that expire 
   * @remarks
   * Recommeded method to call when retriving files or images from aws s3 bucket
   * @param imgObjs - Array of images that will be signed
   * @param time - How long many days until the image is url expires. Default 7 days
   * @return PresignedURL - The presignedUrl needed to access the cloudfront s3 bucket item
  */


/******************************************************************
 * MULTI-FILE  – getMultiSignedCloudFrontImg
 ******************************************************************/
async getMultiSignedCloudFrontImg(
  props: IAws_S3_GetMultiSignedCloudFrontImg
) {
  try {
    const setupAuth = await this.setup();

    const expireDays =
      props.DayExpire && props.DayExpire > 0
        ? Math.min(Math.abs(props.DayExpire), 365)
        : 7;

    const expiresAtDate = new Date(Date.now() + expireDays * 24 * 60 * 60 * 1000);
    const expiresAtEpoch = Math.floor(expiresAtDate.getTime() / 1000);

    const out: Array<{
      PresignedURL: string;
      ExpireDate: string;
      ExpireDateDays: number;
    }> = [];

    for (const fileName of props.FileNamesAssignedS3) {
      if (!fileName) throw new Error("fileName is undefined");

      const url = `https://${setupAuth.CloudfrontObj.cloudfront_distributionSubdomain}/${fileName}`;

      const signed = cdn.getSignedUrl({
        url,
        keyPairId:  setupAuth.CloudfrontObj.cloudfront_keyPairId,
        privateKey: setupAuth.CloudfrontObj.cloudfront_privateKey,
        dateLessThan: expiresAtDate,           // <- Date object, not TTL
      });

      out.push({
        PresignedURL: signed,
        ExpireDate: expiresAtEpoch.toString(),
        ExpireDateDays: expireDays,
      });
    }
    return out;
  } catch (err) {
    console.log("getMultiSignedCloudFrontImg error →", err);
    throw err;
  }
}

/******************************************************************
 * SINGLE-FILE  – getSingleSignedCloudFrontImg
 ******************************************************************/
async getSingleSignedCloudFrontImg(
  props: IAws_S3_GetSingleSignedCloudFrontImg
) {
  try {
    const setupAuth = await this.setup();

    if (!props.FileNameAssignedS3)
      throw new Error("props.FileNameAssignedS3 is undefined");

    const expireDays =
      props.DayExpire && props.DayExpire > 0
        ? Math.min(Math.abs(props.DayExpire), 365)
        : 7;

    const expiresAtDate  = new Date(Date.now() + expireDays * 24 * 60 * 60 * 1000);
    const expiresAtEpoch = Math.floor(expiresAtDate.getTime() / 1000);

    const url = `https://${setupAuth.CloudfrontObj.cloudfront_distributionSubdomain}/${props.FileNameAssignedS3}`;

    const signed = cdn.getSignedUrl({
      url,
      keyPairId:  setupAuth.CloudfrontObj.cloudfront_keyPairId,
      privateKey: setupAuth.CloudfrontObj.cloudfront_privateKey,
      dateLessThan: expiresAtDate,
    });

    return {
      PresignedURL: signed,
      ExpireDate: expiresAtEpoch,
      ExpireDateDays: expireDays,
    };
  } catch (err) {
    console.log("getSingleSignedCloudFrontImg error →", err);
    throw err;
  }
}




  async verifyFileExistance(fileName: string) {
    try {
      try {

        const setupAuth = await this.setup();

        // Check if the object exists
        await setupAuth.Client.send(new HeadObjectCommand({
            Bucket: this.cred.Bucket_name,
            Key: fileName,
        }));

        return {
          FileExist: true,
          Msg: "File exist in bucket"
        }
      } catch (err: any) {
          if (err?.name === 'NotFound') {
              return {
                FileExist: true,
                Msg: "File not found in AWS bucket"
              }
          } else {
              // Handle other errors
              throw err;
          }
      }
    } catch(err) {
      console.log("What is verifyFileExistenaceInAwsBucket err ");
      throw err;
    }
  }

  /**
   * Delete one image from s3 bucket 
   * @param imgName - The name of the image that you want to deleete
   * */
  async deleteImage(props: IAws_S3_DeleteImage_Input) {
      try {

        if (!props.ImageName){
          throw new Error("props.ImageName is undefined");
        }

        const setupAuth = await this.setup();

        const infoAboutFile = {
          Bucket: this.cred.Bucket_name,
          Key: props.ImageName
        }

        //Will upload file to s3 bucket with option object
        const command = new DeleteObjectCommand(infoAboutFile);

        const data = await setupAuth.Client.send(command);
          
        return {
          DeletedImageName: props.ImageName,
          DeleteObjectCommandOutput: data
        }
    } catch(err) {
        console.log("What is deleteImage error - ", err);
        throw err;
    }
  }
}