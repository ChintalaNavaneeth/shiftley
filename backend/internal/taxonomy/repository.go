package taxonomy

import (
	"context"

	"gorm.io/gorm"
)

type Repository interface {
	GetTaxonomy(ctx context.Context) ([]Category, error)
	SeedInitialData(ctx context.Context) error
}

type repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) Repository {
	return &repository{db: db}
}

func (r *repository) GetTaxonomy(ctx context.Context) ([]Category, error) {
	var categories []Category
	err := r.db.WithContext(ctx).
		Preload("Skills", "is_active = ?", true).
		Where("is_active = ?", true).
		Find(&categories).Error
	return categories, err
}

func (r *repository) SeedInitialData(ctx context.Context) error {
	var count int64
	r.db.Model(&Category{}).Count(&count)
	if count > 0 {
		return nil
	}

	taxonomy := []Category{
		{
			Name: "Restaurant / F&B",
			Skills: []Skill{
				{Name: "Waiter / Server"},
				{Name: "Kitchen Helper"},
			},
		},
		{
			Name: "Retail / Store",
			Skills: []Skill{
				{Name: "Cashier"},
				{Name: "Sales Associate"},
			},
		},
	}

	return r.db.WithContext(ctx).Create(&taxonomy).Error
}
