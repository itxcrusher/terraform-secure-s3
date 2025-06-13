// app.ts
const { initAws } = require("./bootstrapSecrets");

(async () => {
  const aws = await initAws("test-dev-secrets-manager");

  // 1. upload
  const { fileNameAssignedS3 } = await aws.uploadImageS3({
    imgBuffer: Buffer.from("hello world"),
    mimeType: "text/plain",
    FileExtension: "txt"
  });

  // 2. presign
  const { PresignedURL } = await aws.getSingleSignedCloudFrontImg({
    FileNameAssignedS3: fileNameAssignedS3,
    DayExpire: 1
  });

  console.log("Signed URL:", PresignedURL);
})();
