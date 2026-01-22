# PowerShell script to get SHA-1 and SHA-256 fingerprints for Firebase

Write-Host "Getting SHA fingerprints for Google Sign-In setup..." -ForegroundColor Cyan
Write-Host ""

# Default debug keystore path
$keystorePath = "$env:USERPROFILE\.android\debug.keystore"

if (Test-Path $keystorePath) {
    Write-Host "Found debug keystore at: $keystorePath" -ForegroundColor Green
    Write-Host ""
    
    # Get SHA-1 and SHA-256
    Write-Host "SHA Fingerprints:" -ForegroundColor Yellow
    Write-Host "=================" -ForegroundColor Yellow
    Write-Host ""
    
    $result = keytool -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android 2>&1
    
    # Extract SHA-1
    $sha1 = ($result | Select-String "SHA1:").ToString() -replace ".*SHA1:\s*", "" -replace "\s.*", ""
    # Extract SHA-256
    $sha256 = ($result | Select-String "SHA256:").ToString() -replace ".*SHA256:\s*", "" -replace "\s.*", ""
    
    if ($sha1) {
        Write-Host "SHA-1:" -ForegroundColor Green
        Write-Host $sha1 -ForegroundColor White
        Write-Host ""
        Write-Host "Copy this SHA-1 to Firebase Console!" -ForegroundColor Yellow
        Write-Host ""
    }
    
    if ($sha256) {
        Write-Host "SHA-256:" -ForegroundColor Green
        Write-Host $sha256 -ForegroundColor White
        Write-Host ""
        Write-Host "Copy this SHA-256 to Firebase Console!" -ForegroundColor Yellow
        Write-Host ""
    }
    
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Go to: https://console.firebase.google.com/project/clgjone/settings/general" -ForegroundColor White
    Write-Host "2. Scroll to 'Your apps' section" -ForegroundColor White
    Write-Host "3. Click on your Android app (com.example.myapp)" -ForegroundColor White
    Write-Host "4. Click 'Add fingerprint' and paste SHA-1" -ForegroundColor White
    Write-Host "5. Click 'Add fingerprint' again and paste SHA-256" -ForegroundColor White
    Write-Host "6. Download the new google-services.json" -ForegroundColor White
    Write-Host "7. Replace android/app/google-services.json" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host "Debug keystore not found at: $keystorePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying alternative method using Gradle..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run this command in your project root:" -ForegroundColor Cyan
    Write-Host "cd android && .\gradlew signingReport" -ForegroundColor White
}
