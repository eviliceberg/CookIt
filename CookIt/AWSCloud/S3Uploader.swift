//
//  S3Uploader.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-19.
//

import SwiftUI
import AWSS3
import AWSClientRuntime
import AWSSDKIdentity
import Smithy
import SmithyIdentity

final class S3Uploader {
    let s3Client: S3Client
    let configuration: S3Client.S3ClientConfiguration
    
    
    public init() async throws {
            do {
                configuration = try await S3Client.S3ClientConfiguration()
                configuration.region = AWSConfig.region
                configuration.awsCredentialIdentityResolver = try StaticAWSCredentialIdentityResolver(AWSCredentialIdentity(accessKey: AWSConfig.accessKey, secret: AWSConfig.secretAccessKey))
                s3Client = S3Client(config: configuration)
            }
            catch {
                print("ERROR: ", dump(error, name: "Initializing S3 client"))
                throw error
            }
        }
    
    func uploadImage(imageData: Data, fileName: String) async throws {
        let input = PutObjectInput(
            body: ByteStream.data(imageData),
            bucket: AWSConfig.bucketName,
            contentType: "image/jpeg",
            key: fileName
        )
        
        _ = try await s3Client.putObject(input: input)
        let imageUrl = "https://\(AWSConfig.bucketName).s3.\(AWSConfig.region).amazonaws.com/\(fileName)"
        print(imageUrl)
    }
    
    func deleteImage(fileName: String) async throws {
        let image = DeleteObjectInput(bucket: AWSConfig.bucketName, key: fileName)
        
        _ = try await s3Client.deleteObject(input: image)
        print("successfully deleted")
    }
    
}
