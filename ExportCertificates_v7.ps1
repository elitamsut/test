# Function to convert .cer to .pem and append to a PEM bundle
function Convert-CerToPemAndAppendToBundle {
    param (
        [string]$cerPath,
        [string]$pemBundlePath
    )

    # Load the .cer certificate file
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    try {
        $cert.Import($cerPath)

        # Export the certificate to PEM format (Base64 encoded)
        $base64Cert = [Convert]::ToBase64String($cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
        $pem = "-----BEGIN CERTIFICATE-----" + "`r`n" + $base64Cert + "`r`n" + "-----END CERTIFICATE-----" + "`r`n"

        # Append the PEM formatted certificate to the PEM bundle
        Add-Content -Path $pemBundlePath -Value $pem
        Write-Host "Appended certificate from $cerPath to $pemBundlePath"
    }
    catch {
        Write-Host "Failed to convert and append $cerPath to PEM bundle: $_"
    }
}

# List all certificate stores (both CurrentUser and LocalMachine)
$stores = @(
    "Cert:\CurrentUser\My",           # Personal certificates (CurrentUser)
    "Cert:\CurrentUser\Root",         # Trusted Root Certificates (CurrentUser)
    "Cert:\CurrentUser\CA",           # Intermediate CAs (CurrentUser)
    "Cert:\LocalMachine\My",          # Personal certificates (LocalMachine)
    "Cert:\LocalMachine\Root",        # Trusted Root Certificates (LocalMachine)
    "Cert:\LocalMachine\CA"           # Intermediate CAs (LocalMachine)
)

# Folder paths for export
$desktopPath = [Environment]::GetFolderPath('Desktop')  # Dynamically get the Desktop path
$pemBundlePath = "$desktopPath\CertificateBundle.pem"  # The path for the PEM bundle

# Initialize or clear the PEM bundle file before appending
if (Test-Path $pemBundlePath) {
    Remove-Item -Path $pemBundlePath  # Remove the existing bundle if it exists
}
New-Item -Path $pemBundlePath -ItemType File -Force | Out-Null  # Create a new file

# List to track all generated .cer file paths for printing and deletion later
$generatedCerFiles = @()

# Loop through each store and search for certificates with 'DigiCert'
foreach ($store in $stores) {
    Write-Host "Searching certificates in $store"
    
    # Get all certificates in the store
    $certs = Get-ChildItem -Path $store

    # Filter certificates where the Subject or FriendlyName contains "DigiCert"
    $digiCerts = $certs | Where-Object { $_.Subject -like "*DigiCert*" -or $_.FriendlyName -like "*DigiCert*" }

    # Convert and append each 'DigiCert' certificate to the PEM bundle
    foreach ($cert in $digiCerts) {
        # Export the certificate to a .cer file (without the private key)
        $cerExportPath = "$desktopPath\$($cert.Subject.Replace(' ', '_')).cer"
        try {
            Export-Certificate -Cert $cert -FilePath $cerExportPath
            Write-Host "Exported certificate for $($cert.Subject) to $cerExportPath"
            
            # Add the .cer file to the list for later printing and deletion
            $generatedCerFiles += $cerExportPath
        }
        catch {
            Write-Host "Failed to export certificate for $($cert.Subject): $_"
        }

        # Convert and append the exported .cer file to PEM bundle in the correct format
        Convert-CerToPemAndAppendToBundle -cerPath $cerExportPath -pemBundlePath $pemBundlePath
    }
    
    # If no 'DigiCert' certificates are found in the store
    if (-not $digiCerts) {
        Write-Host "No 'DigiCert' certificates found in $store"
    }
}

Write-Host "All certificates have been appended to the PEM bundle: $pemBundlePath"

# External Block: Print and Delete all .cer file paths generated during the script execution
Write-Host "Printing the names of all .cer files generated and deleting them afterwards:"

# Check if the list is not empty
if ($generatedCerFiles.Count -gt 0) {
    foreach ($cerFile in $generatedCerFiles) {
        Write-Host "Generated .cer file: $cerFile"
        try {
            # Delete the .cer file after printing, suppressing any errors
            Remove-Item -Path $cerFile -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted .cer file: $cerFile"
        }
        catch {
            # Error is suppressed, nothing will be printed here
            Write-Host "Failed to delete $cerFile, but continuing..."
        }
    }
} else {
    Write-Host "No .cer files were generated."
}

Write-Host "Process complete."
