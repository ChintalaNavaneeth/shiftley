package storage

import (
	"context"
	"io"
)

type Storage interface {
	UploadFile(ctx context.Context, bucketName, objectName string, reader io.Reader, objectSize int64, contentType string) (string, error)
	GetFileURL(ctx context.Context, bucketName, objectName string) (string, error)
	GetFile(ctx context.Context, bucketName, objectName string) (io.ReadCloser, int64, error)
	EnsureBucketExists(ctx context.Context, bucketName string) error
}
