package storage

import (
	"context"
	"fmt"
	"io"
	"log"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

type minioStorage struct {
	client *minio.Client
}

func NewMinioStorage(endpoint, accessKey, secretKey string) (Storage, error) {
	// Initialize minio client object.
	// SSL is set to false for local development
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: false,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to initialize minio client: %w", err)
	}

	return &minioStorage{client: minioClient}, nil
}

func (s *minioStorage) UploadFile(ctx context.Context, bucketName, objectName string, reader io.Reader, objectSize int64, contentType string) (string, error) {
	_, err := s.client.PutObject(ctx, bucketName, objectName, reader, objectSize, minio.PutObjectOptions{
		ContentType: contentType,
	})
	if err != nil {
		return "", fmt.Errorf("failed to upload file: %w", err)
	}

	return objectName, nil
}

func (s *minioStorage) GetFileURL(ctx context.Context, bucketName, objectName string) (string, error) {
	// For local dev, we just return a direct URL if we have an endpoint
	// In production, this might be a signed URL or a CDN URL
	return fmt.Sprintf("/api/v1/storage/%s/%s", bucketName, objectName), nil
}

func (s *minioStorage) EnsureBucketExists(ctx context.Context, bucketName string) error {
	exists, err := s.client.BucketExists(ctx, bucketName)
	if err != nil {
		return fmt.Errorf("failed to check if bucket exists: %w", err)
	}

	if !exists {
		err = s.client.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{})
		if err != nil {
			return fmt.Errorf("failed to create bucket: %w", err)
		}
		log.Printf("Successfully created bucket %s", bucketName)
	}
	return nil
}
