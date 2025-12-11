# SSL Certificate Management Scripts

This repository contains utilities for generating SSL certificate signing requests (CSR) and converting PKCS7 certificates to PEM format.

## Prerequisites

- **OpenSSL** must be installed and available in your system PATH
- **PowerShell** (comes with Windows)

## Files Overview

- `cert-request.bat` - Generate CSR and private key
- `cert-convert.bat` - Convert PKCS7 (.p7b) certificates to PEM format
- `cert-config.cnf` - Configuration file for certificate details
- `_scripts/` - PowerShell scripts called by the batch files
- `request/` - Output folder for CSR and private key
- `converted/` - Output folder for converted certificates

---

## Usage

### 1. Generating a Certificate Signing Request (CSR)

#### Step 1: Configure Certificate Details

Edit `cert-config.cnf` to customize your certificate information:

```ini
[ req_distinguished_name ]
C  = PH                                         # Country
ST = La Union                                   # State/Province
L  = City of San Fernando                       # Locality/City
O  = City Government of San Fernando La Union   # Organization
OU = CICTO                                      # Organizational Unit
CN = *.sanfernandocity.gov.ph                   # Common Name (domain)
emailAddress = cicto@sanfernandocity.gov.ph     # Email Address
```

#### Step 2: Run the Request Script

Double-click `cert-request.bat` or run from command line:

```cmd
cert-request.bat
```

#### Output

The script will create the following files in the `request/` folder:
- `request.csr` - Certificate Signing Request (send this to your CA)
- `private.key` - Private key (keep this secure!)

**Note:** If files already exist, you'll be prompted to confirm overwrite.

---

### 2. Converting PKCS7 Certificates to PEM Format

#### Step 1: Place Certificate File

Place your `.p7b` certificate file (received from your Certificate Authority) in the root directory.

Example: `CEPO251210314007.p7b`

#### Step 2: Run the Convert Script

Double-click `cert-convert.bat` or run from command line:

```cmd
cert-convert.bat
```

#### Output

The script will create the following files in the `converted/` folder:
- `<domain>.fullchain.pem` - Full certificate chain (includes all certificates)
- `<domain>.chain.pem` - Certificate chain only (intermediate + root certificates)
- `<domain>.key` - Processed private key (if found in `request/` folder)

The `<domain>` portion is automatically extracted from the certificate's Common Name (CN).

---

## Workflow Example

### Complete Certificate Generation and Conversion Process

1. **Edit configuration**
   ```
   Edit cert-config.cnf with your organization details
   ```

2. **Generate CSR**
   ```
   Run: cert-request.bat
   Output: request/request.csr and request/private.key
   ```

3. **Submit CSR to Certificate Authority**
   ```
   Send request/request.csr to your CA (e.g., GlobalSign, DigiCert, etc.)
   ```

4. **Receive Certificate**
   ```
   CA will send you a .p7b certificate file
   Place it in the root directory
   ```

5. **Convert Certificate**
   ```
   Run: cert-convert.bat
   Output: converted/*.fullchain.pem, converted/*.chain.pem, converted/*.key
   ```

6. **Deploy Certificates**
   ```
   Use the files from converted/ folder to configure your web server
   ```

---

## File Descriptions

### Generated Files

| File | Description | Usage |
|------|-------------|-------|
| `request.csr` | Certificate Signing Request | Submit to Certificate Authority |
| `private.key` | Private key (unencrypted) | Keep secure, needed for SSL/TLS |
| `*.fullchain.pem` | Full certificate chain | Use in web servers (nginx, apache) |
| `*.chain.pem` | Intermediate + root certificates | Chain file for some servers |
| `*.key` | Processed private key | Use in web servers |

---

## Security Notes

⚠️ **Important Security Considerations:**

- **Never share your `private.key` file** - This is the secret key for your certificate
- Store private keys in a secure location with restricted access
- The private key is generated unencrypted for ease of use
- Consider encrypting the private key if storing long-term
- Delete sensitive files after deployment if no longer needed

---

## Troubleshooting

### "OpenSSL is not recognized"
- Install OpenSSL from https://slproweb.com/products/Win32OpenSSL.html
- Add OpenSSL to your system PATH

### "cert-config.cnf file not found"
- Ensure you're running the script from the correct directory
- The config file must be in the same folder as the batch files

### "PKCS7 (.p7b) file not found"
- Place the .p7b certificate file in the root directory
- Ensure the file has the `.p7b` extension

### Files Already Exist Warning
- The script prevents accidental overwrites
- Type `Y` to confirm overwrite or `N` to cancel

---

## Example Server Configuration

### Nginx Configuration
```nginx
server {
    listen 443 ssl;
    server_name sanfernandocity.gov.ph;
    
    ssl_certificate     /path/to/converted/sanfernandocity.gov.ph.fullchain.pem;
    ssl_certificate_key /path/to/converted/sanfernandocity.gov.ph.key;
}
```

### Apache Configuration
```apache
<VirtualHost *:443>
    ServerName sanfernandocity.gov.ph
    
    SSLEngine on
    SSLCertificateFile /path/to/converted/sanfernandocity.gov.ph.fullchain.pem
    SSLCertificateKeyFile /path/to/converted/sanfernandocity.gov.ph.key
</VirtualHost>
```

---

## License

This is a utility tool for SSL certificate management.

## Support

For issues or questions, contact: cicto@sanfernandocity.gov.ph
