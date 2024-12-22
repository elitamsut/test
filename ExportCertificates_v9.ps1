# Function to convert .cer to .pem and append to a PEM bundle
function Convert-CerToPemAndAppendToGitCABundle {
    param (
        [string]$cerPath,
        [string]$gitCABundlePath
    )

    # Load the .cer certificate file
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    try {
        $cert.Import($cerPath)

        # Export the certificate to PEM format (Base64 encoded)
        $base64Cert = [Convert]::ToBase64String($cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
        $pem = "-----BEGIN CERTIFICATE-----`r`n" + $base64Cert + "`r`n" + "-----END CERTIFICATE-----"

        # Ensure proper PEM format, trimming excess newlines
        $pem = $pem.Trim()

        # Append the PEM formatted certificate to the Git CA bundle with one line break between certificates
        Add-Content -Path $gitCABundlePath -Value "`r`n$pem"
        Write-Host "Appended certificate from $cerPath to Git CA bundle at $gitCABundlePath"
    }
    catch {
        Write-Host "Failed to convert and append $cerPath to Git CA bundle: $_"
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


# Client Certificate List
$clients = @(
    @{
        Name = "Git"
        CerPath = "C:\Program Files\Git\mingw64\etc\ssl\certs\ca-bundle.crt"
        StoreNames = @("Cert:\CurrentUser\My", "Cert:\LocalMachine\Root")
        CertFilter = "*GlobalSign*"
    },
    @{
        Name = "AzureCLI"
        CerPath = "C:\Program Files\Microsoft SDKs\Azure\CLI2\Lib\site-packages\certifi\cacert.pem"
        StoreNames = @("Cert:\CurrentUser\My", "Cert:\LocalMachine\Root")
        CertFilter = "*GlobalSign*"
    },
    @{
        Name = "AWSCLI"
        CerPath = "C:\Program Files\Amazon\AWSCLIV2\awscli\botocore\cacert.pem"
        StoreNames = @("Cert:\CurrentUser\My", "Cert:\LocalMachine\Root")
        CertFilter = "*GlobalSign*"
    }
)

# Check if Git is installed and the CA bundle file exists
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed or not in the PATH. Please install Git and add it to the PATH."
    exit
}
if (-not (Test-Path $gitCABundlePath)) {
    Write-Host "Git CA bundle file not found at $gitCABundlePath. Ensure Git is properly installed."
    exit
}

# List to track all generated .cer file paths for deletion later
$generatedCerFiles = @()

# Process each client and their certificates
foreach ($client in $clients) {
    Write-Host "Processing certificates for $($client.Name)"

    foreach ($store in $client.StoreNames) {
        Write-Host "Searching certificates in $store"

        # Get all certificates in the store
        $certs = Get-ChildItem -Path $store

        # Filter certificates based on the CertFilter pattern (e.g., GlobalSign)
        $filteredCerts = $certs | Where-Object { $_.Subject -like $client.CertFilter -or $_.FriendlyName -like $client.CertFilter }

        # Process each filtered certificate
        foreach ($cert in $filteredCerts) {
            # Export the certificate to a .cer file (without the private key)
            $cerExportPath = "$($env:TEMP)\$($cert.Subject.Replace(' ', '_')).cer"
            try {
                Export-Certificate -Cert $cert -FilePath $cerExportPath
                Write-Host "Exported certificate for $($cert.Subject) to $cerExportPath"

                # Add the .cer file to the list for later deletion
                $generatedCerFiles += $cerExportPath
            }
            catch {
                Write-Host "Failed to export certificate for $($cert.Subject): $_"
                continue
            }

            # Convert and append the exported .cer file to the Git CA bundle in PEM format
            Convert-CerToPemAndAppendToGitCABundle -cerPath $cerExportPath -gitCABundlePath $client.CerPath
        }

        # If no certificates are found matching the filter
        if (-not $filteredCerts) {
            Write-Host "No certificates found matching filter '$($client.CertFilter)' in $store"
        }
    }
}

# Clean up: Print and delete all .cer files generated during the script execution
Write-Host "Cleaning up generated .cer files:"
if ($generatedCerFiles.Count -gt 0) {
    foreach ($cerFile in $generatedCerFiles) {
        Write-Host "Generated .cer file: $cerFile"
        try {
            Remove-Item -Path $cerFile -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted .cer file: $cerFile"
        }
        catch {
            Write-Host "Failed to delete $cerFile, but continuing..."
        }
    }
} else {
    Write-Host "No .cer files were generated."
}

Write-Host "Process complete."
