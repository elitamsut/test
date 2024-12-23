# Function to convert .cer to .pem and append to a PEM bundle in vertical format
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

        # Break Base64 string into chunks of 64 characters per line to make it vertical
        $base64CertVertical = $base64Cert -replace "(.{64})", '$1`n'
# Format the PEM certificate
        $pem = "-----BEGIN CERTIFICATE-----`n$($base64CertVertical.Replace('`', ''))`n-----END CERTIFICATE-----"





        # Append the PEM formatted certificate to the Git CA bundle
        Add-Content -Path $gitCABundlePath -Value "`n$pem"
        Write-Host "Appended certificate from $cerPath to Git CA bundle at $gitCABundlePath"
    } catch {
        Write-Host "Failed to convert and append $cerPath to Git CA bundle: $_"
    }
}


# Define the Git CA bundle path
$gitCABundlePath = "C:\Program Files\Git\mingw64\etc\ssl\certs\ca-bundle.crt" # Adjust the path to your actual Git CA bundle file location

# Define client configurations
$clients = @(
    @{
        Name = "Git"
        CerPath = $gitCABundlePath
        StoreNames = @("Cert:\\CurrentUser\\My", "Cert:\\LocalMachine\\Root")
        CertFilter = "*ameroot*"
    },
    @{
        Name = "AzureCLI"
        CerPath = "C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\Lib\\site-packages\\certifi\\cacert.pem"
        StoreNames = @("Cert:\\CurrentUser\\My", "Cert:\\LocalMachine\\Root")
        CertFilter = "*ameroot*"
    },
    @{
        Name = "AWSCLI"
        CerPath = "C:\\Program Files\\Amazon\\AWSCLI\\runtime\\Lib\\site-packages\\pip\\_vendor\\certifi\\cacert.pem"
        StoreNames = @("Cert:\\CurrentUser\\My", "Cert:\\LocalMachine\\Root")
        CertFilter = "*ameroot*"
    }
)

# Verify Git installation and the existence of the CA bundle file
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed or not in the PATH. Please install Git and add it to the PATH."
    exit
}
if (-not (Test-Path $gitCABundlePath)) {
    Write-Host "Git CA bundle file not found at $gitCABundlePath. Ensure Git is properly installed."
    exit
}

# Track all generated .cer file paths for cleanup
$generatedCerFiles = @()

# Process each client and their certificates
foreach ($client in $clients) {
    Write-Host "Processing certificates for $($client.Name)"

    foreach ($store in $client.StoreNames) {
        Write-Host "Searching certificates in $store"

        # Get all certificates in the store
        $certs = Get-ChildItem -Path $store

        # Filter certificates based on the CertFilter pattern
        $filteredCerts = $certs | Where-Object { $_.Subject -like $client.CertFilter -or $_.FriendlyName -like $client.CertFilter }

        # Process each filtered certificate
        foreach ($cert in $filteredCerts) {
            # Export the certificate to a .cer file (without the private key)
            $cerExportPath = "$($env:TEMP)\$($cert.Subject.Replace(' ', '_')).cer"
            try {
                Export-Certificate -Cert $cert -FilePath $cerExportPath -Type CERT
                Write-Host "Exported certificate for $($cert.Subject) to $cerExportPath"

                # Add the .cer file to the list for later cleanup
                $generatedCerFiles += $cerExportPath

                # Convert and append the exported .cer file to the Git CA bundle in PEM format
                Convert-CerToPemAndAppendToGitCABundle -cerPath $cerExportPath -gitCABundlePath $client.CerPath
            } catch {
                Write-Host "Failed to export certificate for $($cert.Subject): $_"
                continue
            }
        }

        # If no certificates are found matching the filter
        if (-not $filteredCerts) {
            Write-Host "No certificates found matching filter '$($client.CertFilter)' in $store"
        }
    }
}

# Cleanup: Print and delete all .cer files generated during the script execution
Write-Host "Cleaning up generated .cer files:"
if ($generatedCerFiles.Count -gt 0) {
    foreach ($cerFile in $generatedCerFiles) {
        Write-Host "Generated .cer file: $cerFile"
        try {
            Remove-Item -Path $cerFile -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted .cer file: $cerFile"
        } catch {
            Write-Host "Failed to delete $cerFile, but continuing..."
        }
    }
} else {
    Write-Host "No .cer files were generated."
}

Write-Host "Process complete."
