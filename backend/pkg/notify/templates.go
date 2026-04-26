package notify

// This file defines all 27 typed notification helper functions.
// Each function corresponds to a single pre-approved Meta WhatsApp Business template.
//
// Template naming convention: snake_case, matching the Meta template name exactly.
// Parameters are passed in the same order as the template body placeholders ({{1}}, {{2}}, ...).
//
// All functions use SendAsync — they are fire-and-forget and never block the caller.

// ─── Auth ───────────────────────────────────────────────────────────────────

// SendOTP sends a one-time password to the user's WhatsApp number.
// Template: otp_verification
// Body: "Your Shiftley OTP is {{1}}. Valid for 10 minutes. Do not share this with anyone."
func (s *NotifyService) SendOTP(phone, otp string) {
	s.SendAsync(phone, "otp_verification", []string{otp})
}

// ─── Employer Verification ───────────────────────────────────────────────────

// SendEmployerVerificationPending notifies the employer their registration is under review.
// Template: employer_verification_pending
// Body: "Hi {{1}}, your Shiftley business registration for {{2}} has been received. Our team will verify your location within 48 hours."
func (s *NotifyService) SendEmployerVerificationPending(phone, ownerName, businessName string) {
	s.SendAsync(phone, "employer_verification_pending", []string{ownerName, businessName})
}

// SendEmployerVerificationApproved notifies the employer their registration was approved.
// Template: employer_verification_approved
// Body: "Hi {{1}}, great news! Your business {{2}} has been verified on Shiftley. You can now post gigs and hire workers."
func (s *NotifyService) SendEmployerVerificationApproved(phone, ownerName, businessName string) {
	s.SendAsync(phone, "employer_verification_approved", []string{ownerName, businessName})
}

// SendEmployerVerificationRejected notifies the employer their registration was rejected.
// Template: employer_verification_rejected
// Body: "Hi {{1}}, unfortunately your business {{2}} could not be verified. Reason: {{3}}. Please contact Shiftley support for assistance."
func (s *NotifyService) SendEmployerVerificationRejected(phone, ownerName, businessName, reason string) {
	s.SendAsync(phone, "employer_verification_rejected", []string{ownerName, businessName, reason})
}

// ─── Gig Applications ────────────────────────────────────────────────────────

// SendNewApplicationReceived notifies an employer that a worker applied to their gig.
// Template: new_application_received
// Body: "Hi {{1}}, {{2}} has applied for your gig '{{3}}'. Open the Shiftley app to view their profile."
func (s *NotifyService) SendNewApplicationReceived(employerPhone, employerName, workerName, gigTitle string) {
	s.SendAsync(employerPhone, "new_application_received", []string{employerName, workerName, gigTitle})
}

// SendApplicationAccepted notifies a worker their application was approved.
// Template: application_accepted
// Body: "Congratulations {{1}}! You've been selected for '{{2}}' at {{3}}. Please confirm your attendance 1 hour before the shift."
func (s *NotifyService) SendApplicationAccepted(workerPhone, workerName, gigTitle, employerName string) {
	s.SendAsync(workerPhone, "application_accepted", []string{workerName, gigTitle, employerName})
}

// SendApplicationRejected notifies a worker their application was not selected.
// Template: application_rejected
// Body: "Hi {{1}}, your application for '{{2}}' was not selected this time. Keep applying — new gigs are posted daily on Shiftley."
func (s *NotifyService) SendApplicationRejected(workerPhone, workerName, gigTitle string) {
	s.SendAsync(workerPhone, "application_rejected", []string{workerName, gigTitle})
}

// SendNewGigNearby notifies a worker about a relevant new gig in their area.
// Template: new_gig_nearby
// Body: "Hi {{1}}, a new gig '{{2}}' is available {{3}} km from you, paying ₹{{4}}. Apply now on Shiftley before slots fill up!"
func (s *NotifyService) SendNewGigNearby(workerPhone, workerName, gigTitle, distanceKm, wage string) {
	s.SendAsync(workerPhone, "new_gig_nearby", []string{workerName, gigTitle, distanceKm, wage})
}

// ─── Attendance & Shift Reminders ────────────────────────────────────────────

// SendAttendanceConfirm1Hr reminds a worker to confirm their attendance (T-1 hour).
// Template: attendance_confirm_1hr
// Body: "Hi {{1}}, your shift '{{2}}' at {{3}} starts in 1 hour. Please confirm your attendance in the Shiftley app now."
func (s *NotifyService) SendAttendanceConfirm1Hr(workerPhone, workerName, gigTitle, employerName string) {
	s.SendAsync(workerPhone, "attendance_confirm_1hr", []string{workerName, gigTitle, employerName})
}

// SendAttendanceConfirm20Min sends a final reminder when attendance has not been confirmed (T-20 min).
// Template: attendance_confirm_20min
// Body: "⚠️ {{1}}, this is your final reminder. You have 20 minutes to confirm attendance for '{{2}}'. Failure to confirm will mark you as a no-show."
func (s *NotifyService) SendAttendanceConfirm20Min(workerPhone, workerName, gigTitle string) {
	s.SendAsync(workerPhone, "attendance_confirm_20min", []string{workerName, gigTitle})
}

// ─── Emergency Replacement ───────────────────────────────────────────────────

// SendEmergencyReplacementWorker notifies nearby workers about an urgent gig slot.
// Template: emergency_replacement_worker
// Body: "🚨 Urgent Gig Alert! {{1}}, '{{2}}' needs a {{3}} urgently at {{4}}. Pay: ₹{{5}}. Confirm in the Shiftley app within 5 minutes!"
func (s *NotifyService) SendEmergencyReplacementWorker(workerPhone, workerName, gigTitle, skillName, location, wage string) {
	s.SendAsync(workerPhone, "emergency_replacement_worker", []string{workerName, gigTitle, skillName, location, wage})
}

// SendEmergencyReplacementEmployer notifies the employer that emergency replacement was triggered.
// Template: emergency_replacement_employer
// Body: "Hi {{1}}, a worker for your gig '{{2}}' did not confirm. We are automatically finding a replacement. You will be notified once confirmed."
func (s *NotifyService) SendEmergencyReplacementEmployer(employerPhone, employerName, gigTitle string) {
	s.SendAsync(employerPhone, "emergency_replacement_employer", []string{employerName, gigTitle})
}

// ─── Attendance Confirmation ─────────────────────────────────────────────────

// SendCheckinConfirmed notifies the employer that a worker has checked in.
// Template: checkin_confirmed
// Body: "✅ {{1}} has checked in for '{{2}}' at {{3}}."
func (s *NotifyService) SendCheckinConfirmed(employerPhone, workerName, gigTitle, checkInTime string) {
	s.SendAsync(employerPhone, "checkin_confirmed", []string{workerName, gigTitle, checkInTime})
}

// SendCheckoutConfirmed notifies the employer that a worker has checked out.
// Template: checkout_confirmed
// Body: "{{1}} has checked out from '{{2}}' at {{3}}. Payment release will be initiated shortly."
func (s *NotifyService) SendCheckoutConfirmed(employerPhone, workerName, gigTitle, checkOutTime string) {
	s.SendAsync(employerPhone, "checkout_confirmed", []string{workerName, gigTitle, checkOutTime})
}

// ─── Payments ────────────────────────────────────────────────────────────────

// SendPaymentEscrowed notifies the employer that escrow was successfully locked.
// Template: payment_escrowed
// Body: "Hi {{1}}, ₹{{2}} has been held in escrow for your gig '{{3}}'. Workers will be paid automatically after shift completion."
func (s *NotifyService) SendPaymentEscrowed(employerPhone, employerName, amount, gigTitle string) {
	s.SendAsync(employerPhone, "payment_escrowed", []string{employerName, amount, gigTitle})
}

// SendPaymentReleasingSoon notifies both parties that the auto-release timer is counting down.
// Template: payment_releasing_soon
// Body: "Hi {{1}}, payment of ₹{{2}} for gig '{{3}}' will be auto-released in 4 hours if no dispute is raised."
func (s *NotifyService) SendPaymentReleasingSoon(phone, recipientName, amount, gigTitle string) {
	s.SendAsync(phone, "payment_releasing_soon", []string{recipientName, amount, gigTitle})
}

// SendPaymentReleased notifies the worker that payment has been disbursed to their account.
// Template: payment_released
// Body: "🎉 Hi {{1}}, ₹{{2}} has been transferred to your account for completing '{{3}}'. Great work!"
func (s *NotifyService) SendPaymentReleased(workerPhone, workerName, amount, gigTitle string) {
	s.SendAsync(workerPhone, "payment_released", []string{workerName, amount, gigTitle})
}

// ─── Cancellation ────────────────────────────────────────────────────────────

// SendGigCancelledToWorker notifies a confirmed worker that their gig has been cancelled by the employer.
// Template: gig_cancelled_employer
// Body: "Hi {{1}}, unfortunately '{{2}}' has been cancelled by the employer. A cancellation fine of ₹{{3}} has been applied and will be credited to you."
func (s *NotifyService) SendGigCancelledToWorker(workerPhone, workerName, gigTitle, fineAmount string) {
	s.SendAsync(workerPhone, "gig_cancelled_employer", []string{workerName, gigTitle, fineAmount})
}

// SendCancellationFineApplied notifies the employer of the fine charged on their account.
// Template: cancellation_fine_applied
// Body: "Hi {{1}}, a cancellation fine of ₹{{2}} ({{3}}% of gig value) has been applied to your account for the late cancellation of '{{4}}'."
func (s *NotifyService) SendCancellationFineApplied(employerPhone, employerName, fineAmount, finePercent, gigTitle string) {
	s.SendAsync(employerPhone, "cancellation_fine_applied", []string{employerName, fineAmount, finePercent, gigTitle})
}

// SendFineCreditedToWorker notifies a confirmed worker that their share of the cancellation fine has been credited.
// Template: fine_credited_worker
// Body: "Hi {{1}}, ₹{{2}} has been credited to your account as compensation for the cancellation of '{{3}}'."
func (s *NotifyService) SendFineCreditedToWorker(workerPhone, workerName, fineShare, gigTitle string) {
	s.SendAsync(workerPhone, "fine_credited_worker", []string{workerName, fineShare, gigTitle})
}

// ─── No-Show & Penalty ───────────────────────────────────────────────────────

// SendNoShowFlagApplied notifies a worker that a no-show has been recorded against their account.
// Template: noshow_flag_applied
// Body: "Hi {{1}}, a no-show has been recorded for '{{2}}'. Your reliability score has been updated. Repeated no-shows will result in a ₹50 fine."
func (s *NotifyService) SendNoShowFlagApplied(workerPhone, workerName, gigTitle string) {
	s.SendAsync(workerPhone, "noshow_flag_applied", []string{workerName, gigTitle})
}

// SendFine50Notice notifies a worker they have reached 2 no-shows and a ₹50 fine has been applied.
// Template: fine_50_notice
// Body: "⚠️ Hi {{1}}, you have reached 2 no-shows this month. A ₹50 penalty has been applied to your account. Pay the fine in the Shiftley app to re-enable applications."
func (s *NotifyService) SendFine50Notice(workerPhone, workerName string) {
	s.SendAsync(workerPhone, "fine_50_notice", []string{workerName})
}

// SendFine50PaymentRequired notifies a worker they must pay the fine before applying.
// Template: fine_50_payment_required
// Body: "Hi {{1}}, you have an unpaid fine of ₹50. Please clear it in the Shiftley app to start applying for gigs again."
func (s *NotifyService) SendFine50PaymentRequired(workerPhone, workerName string) {
	s.SendAsync(workerPhone, "fine_50_payment_required", []string{workerName})
}

// ─── Rating Reminder ─────────────────────────────────────────────────────────

// SendRatingReminder reminds a user to rate the other party post-shift.
// Template: rating_reminder
// Body: "Hi {{1}}, how was your experience with '{{2}}'? Share your rating on Shiftley — it helps build a trustworthy community."
func (s *NotifyService) SendRatingReminder(phone, recipientName, otherPartyName string) {
	s.SendAsync(phone, "rating_reminder", []string{recipientName, otherPartyName})
}

// ─── Verifier Notifications ───────────────────────────────────────────────────

// SendVerifierNewAssignment notifies a verifier of a new employer to visit.
// Template: verifier_new_assignment
// Body: "Hi {{1}}, you have a new employer verification assignment: {{2}} at {{3}}. Please complete the visit within 48 hours."
func (s *NotifyService) SendVerifierNewAssignment(verifierPhone, verifierName, businessName, businessAddress string) {
	s.SendAsync(verifierPhone, "verifier_new_assignment", []string{verifierName, businessName, businessAddress})
}

// SendVerifierSLAWarning warns the verifier that 36 hours have elapsed without a visit.
// Template: verifier_sla_warning
// Body: "⚠️ {{1}}, the verification for {{2}} is approaching its 48-hour SLA deadline. Please complete the visit immediately."
func (s *NotifyService) SendVerifierSLAWarning(verifierPhone, verifierName, businessName string) {
	s.SendAsync(verifierPhone, "verifier_sla_warning", []string{verifierName, businessName})
}

// SendAdminSLABreach notifies the admin that the 48-hour SLA for an employer verification has been breached.
// Template: admin_sla_breach
// Body: "🚨 SLA Breach: Employer verification for {{1}} ({{2}}) has exceeded 48 hours. Immediate admin intervention required."
func (s *NotifyService) SendAdminSLABreach(adminPhone, businessName, verifierName string) {
	s.SendAsync(adminPhone, "admin_sla_breach", []string{businessName, verifierName})
}
