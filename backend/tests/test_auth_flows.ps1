$baseUrl = "http://localhost:8080/api/v1"
$fixedOtp = "123456"

function Test-Flow {
    param($Name, $ScriptBlock)
    Write-Host "`n--- Testing Flow: $Name ---" -ForegroundColor Cyan
    try {
        & $ScriptBlock
        Write-Host "SUCCESS: $Name" -ForegroundColor Green
    } catch {
        Write-Host "FAILED: $Name" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

$tokens = @{}

Test-Flow "Super Admin Setup" {
    $rootPhone = "+910000000000"
    
    # 1. Send OTP
    Invoke-RestMethod -Uri "$baseUrl/auth/otp/send" -Method Post -Body @{
        identifier = $rootPhone
        type = "PHONE"
        role = "SUPER_ADMIN"
    }

    # 2. Verify OTP
    $resp = Invoke-RestMethod -Uri "$baseUrl/auth/otp/verify" -Method Post -Body @{
        identifier = $rootPhone
        type = "PHONE"
        code = $fixedOtp
    }
    
    $token = ""
    if ($resp.data.session_token) {
        $token = $resp.data.session_token
        Write-Host "Got Session Token"
    } elseif ($resp.data.registration_token) {
        $token = $resp.data.registration_token
        Write-Host "Got Registration Token (Account not yet claimed)"
    } else {
        throw "No token found in response"
    }

    # 3. Setup / Claim account (if session token is missing setup complete)
    # We always try setup to ensure we have the target phone number
    $setupBody = @{
        full_name = "Root Master"
        email = "master@shiftley.in"
        phone_number = "+919999999999"
    } | ConvertTo-Json
    
    try {
        $resp = Invoke-RestMethod -Uri "$baseUrl/admin/super/setup" -Method Patch -Body $setupBody -Headers @{ Authorization = "Bearer $token" } -ContentType "application/json"
        Write-Host "Setup Complete: $($resp.data.message)"
    } catch {
        # If it fails with 403, maybe it's already setup.
        Write-Host "Setup might be already complete or failed: $($_.Exception.Message)"
    }
    
    # 4. Re-login to get a proper session token with the new number
    Invoke-RestMethod -Uri "$baseUrl/auth/otp/send" -Method Post -Body @{
        identifier = "+919999999999"
        type = "PHONE"
        role = "SUPER_ADMIN"
    }
    $resp = Invoke-RestMethod -Uri "$baseUrl/auth/otp/verify" -Method Post -Body @{
        identifier = "+919999999999"
        type = "PHONE"
        code = $fixedOtp
    }
    $tokens["SUPER_ADMIN"] = $resp.data.session_token
    Write-Host "Super Admin session established."
}

Test-Flow "Invite Internal Roles" {
    $adminToken = $tokens["SUPER_ADMIN"]
    if (-not $adminToken) { throw "Admin token missing" }
    
    $roles = @("VERIFIER", "ANALYST", "CS_AGENT")
    
    foreach ($role in $roles) {
        $phone = "+9111111$($role.Length)$($role.Substring(0,1).ToCharArray()[0])"
        $inviteBody = @{
            full_name = "Staff $role"
            email = "$($role.ToLower())@shiftley.in"
            phone_number = $phone
            aadhaar_number = "123456789012"
            role = $role
        } | ConvertTo-Json
        
        $resp = Invoke-RestMethod -Uri "$baseUrl/admin/users/invite" -Method Post -Body $inviteBody -Headers @{ Authorization = "Bearer $adminToken" } -ContentType "application/json"
        Write-Host "Invited $role"
        
        # Test Login for this role
        Invoke-RestMethod -Uri "$baseUrl/auth/otp/send" -Method Post -Body @{
            identifier = $phone
            type = "PHONE"
            role = $role
        }
        $resp = Invoke-RestMethod -Uri "$baseUrl/auth/otp/verify" -Method Post -Body @{
            identifier = $phone
            type = "PHONE"
            code = $fixedOtp
        }
        $tokens[$role] = $resp.data.session_token
        Write-Host "$role logged in successfully."
    }
}

Test-Flow "Public Registration Check" {
    foreach ($role in @("EMPLOYER", "WORKER")) {
        $phone = if ($role -eq "EMPLOYER") { "+918888888888" } else { "+917777777777" }
        Invoke-RestMethod -Uri "$baseUrl/auth/otp/send" -Method Post -Body @{
            identifier = $phone
            type = "PHONE"
            role = $role
        }
        $resp = Invoke-RestMethod -Uri "$baseUrl/auth/otp/verify" -Method Post -Body @{
            identifier = $phone
            type = "PHONE"
            code = $fixedOtp
        }
        if ($resp.data.is_new_user) {
            Write-Host "$role registration flow confirmed (new user)."
        } else {
            Write-Host "$role session flow confirmed (existing user)."
        }
    }
}
