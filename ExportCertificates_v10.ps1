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

# Function to export .pfx certificates and append to a bundle
function Export-PfxAndAppendToBundle {
    param (
        [string]$certPath,
        [string]$pfxBundlePath,
        [string]$pfxPassword
    )

    # Export the certificate as .pfx
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    try {
        $cert.Import($certPath)

        # Export to PFX format (includes private key)
        $pfxBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $pfxPassword)

        # Write the .pfx content to a file
        $pfxFileName = [System.IO.Path]::GetFileNameWithoutExtension($certPath) + ".pfx"
        $pfxFilePath = Join-Path -Path $pfxBundlePath -ChildPath $pfxFileName

        [System.IO.File]::WriteAllBytes($pfxFilePath, $pfxBytes)
        Write-Host "Exported certificate from $certPath to $pfxFilePath"
    }
    catch {
        Write-Host "Failed to export and append $certPath to PFX bundle: $_"
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
$pemBundlePath = "$desktopPath\ca-bundle.pem"  # The path for the PEM bundle
$pfxBundlePath = "$desktopPath\pfx-bundle"  # Folder for storing PFX certificates
$pfxPassword = "YourPasswordHere"  # Set a password for the .pfx certificates

# Initialize or clear the PEM bundle file before appending
if (Test-Path $pemBundlePath) {
    Remove-Item -Path $pemBundlePath  # Remove the existing bundle if it exists
}
New-Item -Path $pemBundlePath -ItemType File -Force | Out-Null  # Create a new file

# Initialize or clear the PFX bundle folder before appending
if (-not (Test-Path $pfxBundlePath)) {
    New-Item -Path $pfxBundlePath -ItemType Directory
}

# List to track all generated .cer and .pfx file paths for printing and deletion later
$generatedCerFiles = @()
$generatedPfxFiles = @()

# Loop through each store and search for certificates with 'DigiCert'
foreach ($store in $stores) {
    Write-Host "Searching certificates in $store"
    
    # Get all certificates in the store
    $certs = Get-ChildItem -Path $store

    # Filter certificates where the Subject or FriendlyName contains "DigiCert"
    $digiCerts = $certs | Where-Object { $_.Subject -like "*GlobalSign*" -or $_.FriendlyName -like "*GlobalSign*" }

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

        # Export the certificate as .pfx and append to the PFX bundle
        Export-PfxAndAppendToBundle -certPath $cerExportPath -pfxBundlePath $pfxBundlePath -pfxPassword $pfxPassword
    }
    
    # If no 'DigiCert' certificates are found in the store
    if (-not $digiCerts) {
        Write-Host "No 'DigiCert' certificates found in $store"
    }
}

Write-Host "All certificates have been appended to the PEM bundle: $pemBundlePath"
Write-Host "All PFX certificates have been saved to: $pfxBundlePath"

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

# Path to your company's certificate bundle
$companyCertPath = "C:\Users\elit\Desktop\ca-bundle.pem"
$companyCertContent = Get-Content -Path $companyCertPath -Raw

# Sets path for Git CLI .pem
$cacertpathGit = "C:\Program Files\Git\mingw64\etc\ssl\certs\ca-bundle.crt"

# Append your company certificate to Git's cacert.pem
$companyCertContent | Add-Content -Path $cacertpathGit

Write-Host "Company certificate added to Git's $cacertpathGit successfully"

# Configure Git to use the updated CA bundle
git config --global http.sslCAInfo "C:\Program Files\Git\mingw64\etc\ssl\certs\ca-bundle.crt" --replace-all

# Export the environment variable for SSL certificates
$env:GIT_SSL_CAINFO = "C:\Program Files\Git\mingw64\etc\ssl\certs\ca-bundle.crt"

Write-Host "Git environment variable GIT_SSL_CAINFO set successfully"

# Sets path for Azure CLI .pem
$cacertpathAzure = "C:\Program Files\Microsoft SDKs\Azure\CLI2\Lib\site-packages\certifi\cacert.pem"

# Append your company certificate to Azure CLI's cacert.pem
$companyCertContent | Add-Content -Path $cacertpathAzure

Write-Host "Company certificate added to Azure CLI's $cacertpathAzure successfully"

# Sets path for AWS CLI .pem
$cacertpathAWS = "C:\Program Files\Amazon\AWSCLI\runtime\Lib\site-packages\pip\_vendor\certifi\cacert.pem"

# Append your company certificate to AWS CLI's cacert.pem
$companyCertContent | Add-Content -Path $cacertpathAWS

Write-Host "Company certificate added to AWS CLI's $cacertpathAWS successfully"
