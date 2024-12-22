# Function to check if a command (client) is available
function Check-IfClientInstalled {
    param (
        [string]$clientName,
        [string]$command
    )
    if (Get-Command $command -ErrorAction SilentlyContinue) {
        Write-Host "$clientName is installed."
    } else {
        Write-Host "$clientName is not installed. Please install $clientName and add it to the PATH."
        exit 1
    }
}

# Function to convert .cer to .pem and append to a PEM bundle
function Convert-CerToPemAndAppendToGitCABundle {
    param (
        [string]$cerPath,
        [string]$gitCABundlePath
    )
    try {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($cerPath)

        # Convert certificate to PEM format
        $base64Cert = [Convert]::ToBase64String($cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
        $pem = "-----BEGIN CERTIFICATE-----`r`n$base64Cert`r`n-----END CERTIFICATE-----"

        # Ensure proper formatting and append to the Git CA bundle
        Add-Content -Path $gitCABundlePath -Value "`r`n$pem" -Encoding Ascii
        Write-Host "Appended certificate from $cerPath to $gitCABundlePath"
    } catch {
        Write-Host "Failed to process ${cerPath}: $_"

    }
}

# Check if required clients are installed
Check-IfClientInstalled -clientName "Git" -command "git"
Check-IfClientInstalled -clientName "Azure CLI" -command "az"
Check-IfClientInstalled -clientName "AWS CLI" -command "aws"

# Define certificate stores and filters for clients
$clients = @(
    @{
        Name = "Git"
        CerPath = "C:\Program Files\Git\mingw64\etc\ssl\certs\ca-bundle.crt"
        StoreNames = @("Cert:\CurrentUser\Root", "Cert:\LocalMachine\Root")
        CertFilter = "*ISRG Root X1*"
    },
    @{
        Name = "Azure CLI"
        CerPath = "C:\Program Files\Microsoft SDKs\Azure\CLI2\Lib\site-packages\certifi\cacert.pem"
        StoreNames = @("Cert:\CurrentUser\Root", "Cert:\LocalMachine\Root")
        CertFilter = "*ISRG Root X1*"
    },
    @{
        Name = "AWS CLI"
        CerPath = "C:\Program Files\Amazon\AWSCLI\runtime\Lib\site-packages\botocore\cacert.pem"
        StoreNames = @("Cert:\CurrentUser\Root", "Cert:\LocalMachine\Root")
        CertFilter = "*ISRG Root X1*"
    }
)

# Validate each client's CA bundle file
foreach ($client in $clients) {
    if (-not (Test-Path $client.CerPath)) {
        Write-Host "Certificate file for $($client.Name) not found at $($client.CerPath). Please verify the path."
        exit 1
    }
}

# Process certificates for each client
foreach ($client in $clients) {
    Write-Host "Processing certificates for $($client.Name)"
    foreach ($store in $client.StoreNames) {
        Write-Host "Searching certificates in $store"
        $certs = Get-ChildItem -Path $store | Where-Object { $_.Subject -like $client.CertFilter -or $_.FriendlyName -like $client.CertFilter }

        if ($certs.Count -eq 0) {
            Write-Host "No certificates found matching filter '$($client.CertFilter)' in $store"
            continue
        }

        foreach ($cert in $certs) {
            $cerExportPath = Join-Path -Path $env:TEMP -ChildPath "$($cert.Thumbprint).cer"
            try {
                Export-Certificate -Cert $cert -FilePath $cerExportPath
                Write-Host "Exported certificate to $cerExportPath"
                Convert-CerToPemAndAppendToGitCABundle -cerPath $cerExportPath -gitCABundlePath $client.CerPath
                Remove-Item -Path $cerExportPath -Force -ErrorAction SilentlyContinue
            } catch {
                Write-Host "Failed to process certificate: $_"
            }
        }
    }
}

# Update Git configuration
Write-Host "Certificates added to $gitCABundlePath successfully."
git config --global http.sslCAInfo "C:\Program Files\Git\mingw64\etc\ssl\certs\ca-bundle.crt" --replace-all

Write-Host "Process completed."
