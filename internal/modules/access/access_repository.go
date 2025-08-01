package access

import (
	"apiserver/internal/types"
	"time"

	"gorm.io/gorm"
)

type Repository interface {
	FindByAPIKey(apiKey string) (*User, error)
	UpdateExpiredDate(id string, expiredDate *time.Time) error
	UpdateRateLimit(id string, rateLimit int) error
	GetUserByID(id string) (*User, error)
	CreateUser(user *User) error
	FindByEmail(email string) (*User, error)
}

// AuthRepositoryImpl implements types.AuthRepository
type AuthRepositoryImpl struct {
	repo Repository
}

func NewAuthRepository(repo Repository) types.AuthRepository {
	return &AuthRepositoryImpl{repo: repo}
}

func (a *AuthRepositoryImpl) FindByAPIKey(apiKey string) (types.User, error) {
	user, err := a.repo.FindByAPIKey(apiKey)
	if err != nil {
		return nil, err
	}
	return user, nil
}

type repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) Repository {
	return &repository{db: db}
}

func (r *repository) FindByAPIKey(apiKey string) (*User, error) {
	var user User

	// Query with status check and expired date check
	// Either expired_date is NULL (never expires) or expired_date is in the future
	err := r.db.Preload("Group.Permissions", "status_id = ?", 0).
		Preload("Group", "status_id = ?", 0).
		Where("api_key = ? AND status_id = ? AND (expired_date IS NULL OR expired_date > ?)", 
			apiKey, 0, time.Now()).
		First(&user).Error

	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *repository) UpdateExpiredDate(id string, expiredDate *time.Time) error {
	return r.db.Model(&User{}).Where("id = ?", id).Update("expired_date", expiredDate).Error
}

func (r *repository) GetUserByID(id string) (*User, error) {
	var user User
	err := r.db.Preload("Group").Where("id = ? AND status_id = ?", id, 0).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *repository) UpdateRateLimit(id string, rateLimit int) error {
	return r.db.Model(&User{}).Where("id = ?", id).Update("rate_limit", rateLimit).Error
}

func (r *repository) CreateUser(user *User) error {
	return r.db.Create(user).Error
}

func (r *repository) FindByEmail(email string) (*User, error) {
	var user User
	err := r.db.Where("email = ? AND status_id = ?", email, 0).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}
