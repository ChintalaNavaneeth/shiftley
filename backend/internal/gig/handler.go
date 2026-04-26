package gig

import (
	"fmt"
	"math"
	"net/http"
	"strconv"
	"time"

	"shiftley/internal/auth"
	"shiftley/pkg/notify"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Handler struct {
	db     *gorm.DB
	notify *notify.NotifyService
}

func NewHandler(db *gorm.DB, notifySvc *notify.NotifyService) *Handler {
	return &Handler{db: db, notify: notifySvc}
}

type PostGigRequest struct {
	Title         string    `json:"title" binding:"required"`
	Description   string    `json:"description" binding:"required"`
	CategoryID    string    `json:"category_id" binding:"required"`
	SkillID       string    `json:"skill_id" binding:"required"`
	StartTime     time.Time `json:"start_time" binding:"required"`
	EndTime       time.Time `json:"end_time" binding:"required"`
	PayType       string    `json:"pay_type" binding:"required"` // PER_DAY, PER_HOUR
	WagePerWorker int64     `json:"wage_per_worker" binding:"required"`
	WorkersNeeded int       `json:"workers_needed" binding:"required"`
}

// PostGig handles POST /api/v1/gigs
// @Summary Post a New Gig
// @Description Creates a gig and generates a mock Razorpay Escrow order.
// @Tags Gig
// @Accept json
// @Produce json
// @Param request body PostGigRequest true "Gig Details"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs [post]
func (h *Handler) PostGig(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var req PostGigRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	// 1. Calculate Escrow Amount (Simple Logic)
	totalWage := req.WagePerWorker * int64(req.WorkersNeeded)
	
	// 2. Create Gig in DRAFT
	gig := Gig{
		EmployerID:    userID,
		Title:         req.Title,
		Description:   req.Description,
		CategoryID:    req.CategoryID,
		SkillID:       req.SkillID,
		StartTime:     req.StartTime,
		EndTime:       req.EndTime,
		PayType:       req.PayType,
		WagePerWorker: req.WagePerWorker,
		WorkersNeeded: req.WorkersNeeded,
		Status:        StatusDraft,
		EscrowOrderID: fmt.Sprintf("order_escrow_%s", uuid.New().String()[:8]),
	}

	if err := h.db.Create(&gig).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to create gig", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"gig_id":            gig.ID,
		"razorpay_order_id": gig.EscrowOrderID,
		"amount_to_escrow":  totalWage,
		"message":           "Gig created in DRAFT. Fund the escrow to make it public.",
	}, nil)
}

// GetBenchmark handles GET /api/v1/gigs/wage-benchmark
// @Summary Wage Benchmark Check
// @Description Returns the average market wage for a skill.
// @Tags Gig
// @Produce json
// @Param skill_id query string true "Skill ID"
// @Param pay_type query string true "PER_DAY or PER_HOUR"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/wage-benchmark [get]
func (h *Handler) GetBenchmark(c *gin.Context) {
	skillID := c.Query("skill_id")
	payType := c.Query("pay_type")

	// Mock data
	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"skill":              skillID,
		"pay_type":           payType,
		"average_wage_paise": 75000,
		"minimum_wage_paise": 50000,
	}, nil)
}

// GetApplications handles GET /api/v1/gigs/:gigId/applications
// @Summary View Gig Applications
// @Description Fetches the list of employees who have applied for a specific gig.
// @Tags Gig
// @Produce json
// @Param gigId path string true "Gig ID"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/applications [get]
func (h *Handler) GetApplications(c *gin.Context) {
	gigID := c.Param("gigId")
	
	var apps []GigApplication
	if err := h.db.Where("gig_id = ?", gigID).Find(&apps).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch applications", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, apps, nil)
}

// ApproveApplication handles PATCH /api/v1/applications/:applicationId/status
// @Summary Approve Application
// @Description Hires a specific applicant for the gig slot.
// @Tags Gig
// @Accept json
// @Produce json
// @Param applicationId path string true "Application ID"
// @Param request body object true "Status: APPROVED"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /applications/{applicationId}/status [patch]
func (h *Handler) ApproveApplication(c *gin.Context) {
	appID := c.Param("applicationId")
	var req struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid status", nil)
		return
	}

	if err := h.db.Model(&GigApplication{}).Where("id = ?", appID).Update("status", req.Status).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update application", nil)
		return
	}

	// Fetch data for notification
	var app GigApplication
	h.db.First(&app, "id = ?", appID)
	var worker auth.User
	h.db.First(&worker, "id = ?", app.EmployeeID)
	var g Gig
	h.db.First(&g, "id = ?", app.GigID)

	if req.Status == "APPROVED" {
		h.notify.SendApplicationAccepted(worker.PhoneNumber, worker.FullName, g.Title, "Employer")
	} else if req.Status == "REJECTED" {
		h.notify.SendApplicationRejected(worker.PhoneNumber, worker.FullName, g.Title)
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{"application_id": appID, "status": req.Status}, nil)
}

// CancelGig handles POST /api/v1/gigs/{gigId}/cancel
// @Summary Cancel Gig
// @Description Allows the employer to cancel a gig with automated penalty calculation.
// @Tags Gig
// @Accept json
// @Produce json
// @Param gigId path string true "Gig ID"
// @Param request body object true "Reason"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/cancel [post]
func (h *Handler) CancelGig(c *gin.Context) {
	gigID := c.Param("gigId")
	var req struct {
		Reason string `json:"reason" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Reason is required", nil)
		return
	}

	var g Gig
	if err := h.db.First(&g, "id = ?", gigID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Gig not found", nil)
		return
	}

	// Calculate Penalty (Mock Logic based on time until StartTime)
	timeUntilStart := time.Until(g.StartTime)
	penalty := int64(0)
	if timeUntilStart < 2*time.Hour {
		penalty = (g.WagePerWorker * int64(g.WorkersNeeded)) / 4 // 25% fine
	} else if timeUntilStart < 12*time.Hour {
		penalty = (g.WagePerWorker * int64(g.WorkersNeeded)) / 10 // 10% fine
	}

	g.Status = StatusCancelled
	g.CancelReason = req.Reason
	h.db.Save(&g)

	// Notify workers (Mock: sending to all applicants)
	var apps []GigApplication
	h.db.Where("gig_id = ? AND status = ?", g.ID, AppApproved).Find(&apps)
	for _, app := range apps {
		var worker auth.User
		if err := h.db.First(&worker, "id = ?", app.EmployeeID).Error; err == nil {
			h.notify.SendGigCancelledToWorker(worker.PhoneNumber, worker.FullName, g.Title, fmt.Sprintf("%d", penalty))
		}
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"status":        StatusCancelled,
		"fine_paise":    penalty,
		"refund_paise": (g.WagePerWorker * int64(g.WorkersNeeded)) - penalty,
		"message":       fmt.Sprintf("Gig cancelled. Penalty of %d paise applied.", penalty),
	}, nil)
}

// CloseUnfilled handles POST /api/v1/gigs/{gigId}/close-unfilled
// @Summary Close Gig with Full Refund
// @Description Closes a gig that had no worker approvals before start.
// @Tags Gig
// @Produce json
// @Param gigId path string true "Gig ID"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/close-unfilled [post]
func (h *Handler) CloseUnfilled(c *gin.Context) {
	gigID := c.Param("gigId")
	var approvedCount int64
	h.db.Model(&GigApplication{}).Where("gig_id = ? AND status = ?", AppApproved).Count(&approvedCount)

	if approvedCount > 0 {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Cannot close as unfilled; workers were already approved. Use Cancel Gig instead.", nil)
		return
	}

	if err := h.db.Model(&Gig{}).Where("id = ?", gigID).Update("status", StatusCancelled).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to close gig", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{"status": StatusCancelled, "message": "Gig closed with 100% escrow refund."}, nil)
}

// GenerateQR handles GET /api/v1/gigs/{gigId}/attendance-qr
// @Summary Generate Shift QR Codes
// @Description Generates a time-sensitive, rotating QR code string.
// @Tags Gig
// @Produce json
// @Param gigId path string true "Gig ID"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/attendance-qr [get]
func (h *Handler) GenerateQR(c *gin.Context) {
	gigID := c.Param("gigId")
	qrString := fmt.Sprintf("shiftley://scan?gig=%s&action=CLOCK_IN&token=%s", gigID, uuid.New().String()[:8])

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"qr_string":  qrString,
		"expires_in": 60,
	}, nil)
}

// MarkArrived handles POST /api/v1/gigs/{gigId}/employees/{empId}/mark-arrived
// @Summary Manual Check-In (QR Fallback)
// @Description Manually mark the worker as arrived via the app.
// @Tags Gig
// @Produce json
// @Param gigId path string true "Gig ID"
// @Param empId path string true "Employee ID"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/employees/{empId}/mark-arrived [post]
func (h *Handler) MarkArrived(c *gin.Context) {
	gigID, _ := uuid.Parse(c.Param("gigId"))
	empID, _ := uuid.Parse(c.Param("empId"))

	now := time.Now()
	attendance := GigAttendance{
		GigID:      gigID,
		EmployeeID: empID,
		ClockIn:    &now,
		Status:     AttPresent,
	}

	if err := h.db.Create(&attendance).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to mark check-in", nil)
		return
	}

	// Notify Employer
	var worker auth.User
	h.db.First(&worker, "id = ?", empID)
	var g Gig
	h.db.First(&g, "id = ?", gigID)
	var employer auth.User
	h.db.First(&employer, "id = ?", g.EmployerID)

	h.notify.SendCheckinConfirmed(employer.PhoneNumber, worker.FullName, g.Title, now.Format("15:04"))

	utils.RespondSuccess(c, http.StatusOK, gin.H{"status": "CHECKED_IN", "check_in_time": now}, nil)
}

// CompleteShift handles POST /api/v1/gigs/{gigId}/employees/{empId}/complete
// @Summary Manual Shift Complete (Trigger Payout)
// @Description Triggers the Razorpay payout for a worker.
// @Tags Gig
// @Accept json
// @Produce json
// @Param gigId path string true "Gig ID"
// @Param empId path string true "Employee ID"
// @Param request body object false "Override Details"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/employees/{empId}/complete [post]
func (h *Handler) CompleteShift(c *gin.Context) {
	gigID := c.Param("gigId")
	empID := c.Param("empId")

	// Mock payout logic
	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"status":                "COMPLETED",
		"payout_status":         "PROCESSING_RAZORPAY",
		"amount_released_paise": 60000,
	}, nil)
	fmt.Printf("[MOCK PAYOUT] Triggered Razorpay Route for Employee %s (Gig %s)\n", empID, gigID)

	// Notify Worker
	var worker auth.User
	h.db.First(&worker, "id = ?", empID)
	var g Gig
	h.db.First(&g, "id = ?", gigID)
	h.notify.SendPaymentReleased(worker.PhoneNumber, worker.FullName, "600.00", g.Title)
}

// EmergencyHire handles POST /api/v1/gigs/{gigId}/emergency-hire
// @Summary Emergency No-Show Replacement
// @Description Penalizes the no-show employee and approves a replacement.
// @Tags Gig
// @Accept json
// @Produce json
// @Param gigId path string true "Gig ID"
// @Param request body object true "Replacement Details"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/emergency-hire [post]
func (h *Handler) EmergencyHire(c *gin.Context) {
	gigID, _ := uuid.Parse(c.Param("gigId"))
	var req struct {
		NoShowEmployeeID         string `json:"no_show_employee_id" binding:"required"`
		ReplacementApplicationID string `json:"replacement_application_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request", nil)
		return
	}

	noShowEmpID, _ := uuid.Parse(req.NoShowEmployeeID)
	replacementAppID, _ := uuid.Parse(req.ReplacementApplicationID)

	err := h.db.Transaction(func(tx *gorm.DB) error {
		// 1. Mark offender as NO_SHOW
		if err := tx.Model(&GigApplication{}).Where("gig_id = ? AND employee_id = ?", gigID, noShowEmpID).Update("status", AppNoShow).Error; err != nil {
			return err
		}

		// 2. Count No-Shows in last 30 days
		var noShowCount int64
		thirtyDaysAgo := time.Now().AddDate(0, 0, -30)
		tx.Model(&GigApplication{}).Where("employee_id = ? AND status = ? AND updated_at > ?", noShowEmpID, AppNoShow, thirtyDaysAgo).Count(&noShowCount)

		// 3. Apply Fine if 2nd strike or more
		if noShowCount >= 2 {
			const fineAmount = 50000 // ₹500 in Paise
			if err := tx.Model(&auth.User{}).Where("id = ?", noShowEmpID).UpdateColumn("unpaid_fine_paise", gorm.Expr("unpaid_fine_paise + ?", fineAmount)).Error; err != nil {
				return err
			}
		}

		// 4. Approve Replacement
		if err := tx.Model(&GigApplication{}).Where("id = ?", replacementAppID).Update("status", AppApproved).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to process emergency hire", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{"message": "No-show penalized. Replacement worker approved."}, nil)
}

// SubmitReview handles POST /api/v1/gigs/{gigId}/employees/{empId}/review
// @Summary Rate Employee Post-Shift
// @Description Allows the employer to leave a rating and comment for the employee.
// @Tags Gig
// @Accept json
// @Produce json
// @Param gigId path string true "Gig ID"
// @Param empId path string true "Employee ID"
// @Param request body object true "Review Details"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/employees/{empId}/review [post]
func (h *Handler) SubmitReview(c *gin.Context) {
	gigID, _ := uuid.Parse(c.Param("gigId"))
	empID, _ := uuid.Parse(c.Param("empId"))
	fromIDStr, _ := c.Get("userID")
	fromID, _ := uuid.Parse(fromIDStr.(string))

	var req struct {
		Rating  int    `json:"rating" binding:"required,min=1,max=5"`
		Comment string `json:"comment"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Rating (1-5) is required", nil)
		return
	}

	review := GigReview{
		GigID:      gigID,
		FromUserID: fromID,
		ToUserID:   empID,
		Rating:     req.Rating,
		Comment:    req.Comment,
	}

	if err := h.db.Create(&review).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to submit review", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, review, nil)
}

// SearchGigs handles GET /api/v1/gigs/search
// @Summary Geospatial Gig Search
// @Description Find gigs within a specific radius.
// @Tags Gig
// @Produce json
// @Param lat query float64 true "Latitude"
// @Param lng query float64 true "Longitude"
// @Param radius_km query float64 false "Radius in KM"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/search [get]
func (h *Handler) SearchGigs(c *gin.Context) {
	lat, _ := strconv.ParseFloat(c.Query("lat"), 64)
	lng, _ := strconv.ParseFloat(c.Query("lng"), 64)
	radius, _ := strconv.ParseFloat(c.DefaultQuery("radius_km", "10"), 64)

	var gigs []Gig
	// Mock geospatial search using a simple bounding box or direct distance
	// In production, use PostGIS: ST_DWithin(location, ST_MakePoint(lng, lat), radius * 1000)
	h.db.Where("status = ?", StatusOpen).Find(&gigs)

	type SearchResult struct {
		Gig
		DistanceKM float64 `json:"distance_km"`
	}

	results := []SearchResult{}
	for _, g := range gigs {
		dist := calculateDistance(lat, lng, g.Lat, g.Lng)
		if dist <= radius {
			results = append(results, SearchResult{Gig: g, DistanceKM: dist})
		}
	}

	utils.RespondSuccess(c, http.StatusOK, results, nil)
}

// calculateDistance returns distance between two points in KM using Haversine formula
func calculateDistance(lat1, lon1, lat2, lon2 float64) float64 {
	const R = 6371 // Earth radius in km
	dLat := (lat2 - lat1) * (math.Pi / 180)
	dLon := (lon2 - lon1) * (math.Pi / 180)
	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1*(math.Pi/180))*math.Cos(lat2*(math.Pi/180))*
			math.Sin(dLon/2)*math.Sin(dLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	return R * c
}

// ApplyForGig handles POST /api/v1/gigs/{gigId}/apply
// @Summary Apply for a Gig
// @Description Submit application for an open gig.
// @Tags Gig
// @Produce json
// @Param gigId path string true "Gig ID"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/apply [post]
func (h *Handler) ApplyForGig(c *gin.Context) {
	gigID, _ := uuid.Parse(c.Param("gigId"))
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	// 1. Check if gig is open
	var g Gig
	if err := h.db.First(&g, gigID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Gig not found", nil)
		return
	}
	if g.Status != StatusOpen {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Gig is no longer open for applications", nil)
		return
	}

	// 2. Check for overlapping accepted gigs
	var overlapCount int64
	h.db.Table("shiftley.gig_applications").
		Joins("JOIN shiftley.gigs ON shiftley.gigs.id = shiftley.gig_applications.gig_id").
		Where("shiftley.gig_applications.employee_id = ? AND shiftley.gig_applications.status = ?", userID, AppApproved).
		Where("NOT (shiftley.gigs.end_time <= ? OR shiftley.gigs.start_time >= ?)", g.StartTime, g.EndTime).
		Count(&overlapCount)

	if overlapCount > 0 {
		utils.RespondError(c, http.StatusConflict, utils.ErrConflict, "You already have a confirmed shift during this time", nil)
		return
	}

	// 3. Create Application
	app := GigApplication{
		GigID:      gigID,
		EmployeeID: userID,
		Status:     AppApplied,
	}

	if err := h.db.Create(&app).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to apply", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, "Application submitted", nil)
}

// ConfirmAttendance handles POST /api/v1/gigs/{gigId}/confirm-attendance
// @Summary Confirm Shift Attendance
// @Description Must be called between T-60 and T-45 mins of start time.
// @Tags Gig
// @Produce json
// @Param gigId path string true "Gig ID"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/confirm-attendance [post]
func (h *Handler) ConfirmAttendance(c *gin.Context) {
	gigID := c.Param("gigId")
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var g Gig
	h.db.First(&g, "id = ?", gigID)

	timeToStart := time.Until(g.StartTime)
	if timeToStart > 60*time.Minute {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Too early to confirm. Please confirm within 1 hour of start time.", nil)
		return
	}
	if timeToStart < 45*time.Minute {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Confirmation window closed. Emergency replacement may have been triggered.", nil)
		return
	}

	// Update application status to CONFIRMED
	result := h.db.Model(&GigApplication{}).Where("gig_id = ? AND employee_id = ?", gigID, userID).Update("status", "CONFIRMED")
	if result.Error != nil || result.RowsAffected == 0 {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrNotFound, "Approved application not found for this gig", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, "Attendance confirmed", nil)
}

// ScanQR handles POST /api/v1/gigs/{gigId}/scan-qr
// @Summary Clock-In/Out via QR Scan
// @Description Validates the QR token and logs attendance.
// @Tags Gig
// @Accept json
// @Produce json
// @Param gigId path string true "Gig ID"
// @Param request body object true "QR Token and Action"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/scan-qr [post]
func (h *Handler) ScanQR(c *gin.Context) {
	var req struct {
		QRToken string `json:"qr_token" binding:"required"`
		Action  string `json:"action" binding:"required,oneof=CLOCK_IN CLOCK_OUT"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request", nil)
		return
	}

	// In production, validate QRToken against Redis cache
	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"status":    fmt.Sprintf("SUCCESSFULLY_%s", req.Action),
		"timestamp": time.Now(),
	}, nil)
}

// SubmitEmployerReview handles POST /api/v1/gigs/{gigId}/employer-review
// @Summary Rate Employer Post-Shift
// @Description Worker rates the employer.
// @Tags Gig
// @Accept json
// @Produce json
// @Param gigId path string true "Gig ID"
// @Param request body object true "Review Details"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/employer-review [post]
func (h *Handler) SubmitEmployerReview(c *gin.Context) {
	gigID, _ := uuid.Parse(c.Param("gigId"))
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var req struct {
		Rating  int    `json:"rating" binding:"required,min=1,max=5"`
		Comment string `json:"comment"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Rating (1-5) required", nil)
		return
	}

	var g Gig
	h.db.First(&g, gigID)

	review := GigReview{
		GigID:      gigID,
		FromUserID: userID,
		ToUserID:   g.EmployerID,
		Rating:     req.Rating,
		Comment:    req.Comment,
	}

	h.db.Create(&review)
	utils.RespondSuccess(c, http.StatusCreated, "Review submitted", nil)
}

// RevokeApplication handles POST /api/v1/gigs/{gigId}/revoke-application
// @Summary Withdraw Application
// @Description Allows worker to withdraw. Blocked if < 1 hour to start for approved gigs.
// @Tags Gig
// @Produce json
// @Param gigId path string true "Gig ID"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /gigs/{gigId}/revoke-application [post]
func (h *Handler) RevokeApplication(c *gin.Context) {
	gigID := c.Param("gigId")
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var app GigApplication
	if err := h.db.Preload("Gig").Where("gig_id = ? AND employee_id = ?", gigID, userID).First(&app).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Application not found", nil)
		return
	}

	if app.Status == AppApproved {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Cannot revoke an application that has already been accepted by the employer. Please contact support if you cannot attend.", nil)
		return
	}

	h.db.Delete(&app)
	utils.RespondSuccess(c, http.StatusOK, "Application revoked", nil)
}

