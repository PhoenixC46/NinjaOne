function Set-NinjaOneSecrets {
    <#
        .SYNOPSIS
            Saves NinjaOne connection and authentication using the SecretManagement module.
        .DESCRIPTION
            Handles the saving of NinjaOne connection and authentication information using the SecretManagement module. This function is intended to be used internally by the module and should not be called directly.
        .OUTPUTS
            [System.Void]

            Returns nothing.
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Private function - no need to support.')]
    # Suppress the PSSA warning about using ConvertTo-SecureString with -AsPlainText. There's no viable alternative.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'No viable alternative.')]
    param(
        # The authentication mode to use.
        [String]$AuthMode,
        # The URL of the NinjaRMM instance.
        [URI]$URL,
        # The NinjaRMM instance name.
        [String]$Instance,
        # The client ID of the application.
        [String]$ClientId,
        # The client secret of the application.
        [String]$ClientSecret,
        # The port to listen on for the authentication callback.
        [Int]$AuthListenerPort,
        # The authentication scopes to request.
        [String]$AuthScopes,
        # The redirect URI to use for the authentication callback.
        [URI]$RedirectURI,
        # Use the Key Vault to store the connection information.
        [Parameter(Mandatory)]
        [Switch]$UseSecretManagement,
        # The name of the secret vault to use.
        [String]$VaultName,
        # Whether to write updated connection information to the secret vault.
        [Switch]$WriteToSecretVault,
        # Whether to read the connection information from the secret vault.
        [Switch]$ReadFromSecretVault,
        # The type of the authentication token.
        [String]$Type,
        # The access token to use for authentication.
        [String]$Access,
        # The expiration time of the access token.
        [DateTime]$Expires,
        # The refresh token to use for authentication.
        [String]$Refresh
    )
    # Check if the secret vault exists.
    $SecretVault = Get-SecretVault -Name $VaultName -ErrorAction SilentlyContinue
    if ($null -eq $SecretVault) {
        Write-Error ('Secret vault {0} does not exist.' -f $VaultName)
        exit 1
    }
    # Make sure we've been told to write to the secret vault.
    if ($false -eq $WriteToKeyVault) {
        Write-Error 'WriteToKeyVault must be specified.'
        exit 1
    }
    # Write the connection information to the secret vault.
    $Secrets = [Hashtable]@{}
    if ($null -ne $Script:NRAPIConnectionInformation.AuthMode) {
        $Secrets.NinjaOneAuthMode = $Script:NRAPIConnectionInformation.AuthMode
    }
    if ($null -ne $Script:NRAPIConnectionInformation.URL) {
        $Secrets.NinjaOneURL = $Script:NRAPIConnectionInformation.URL
    }
    if ($null -ne $Script:NRAPIConnectionInformation.Instance) {
        $Secrets.NinjaOneInstance = $Script:NRAPIConnectionInformation.Instance
    }
    if ($null -ne $Script:NRAPIConnectionInformation.ClientId) {
        $Secrets.NinjaOneClientId = $Script:NRAPIConnectionInformation.ClientId
    }
    if ($null -ne $Script:NRAPIConnectionInformation.ClientSecret) {
        $Secrets.NinjaOneClientSecret = $Script:NRAPIConnectionInformation.ClientSecret
    }
    if ($null -ne $Script:NRAPIConnectionInformation.AuthScopes) {
        $Secrets.NinjaOneAuthScopes = $Script:NRAPIConnectionInformation.AuthScopes
    }
    if ($null -ne $Script:NRAPIConnectionInformation.RedirectURI) {
        $Secrets.NinjaOneRedirectURI = $Script:NRAPIConnectionInformation.RedirectURI.ToString()
    }
    if ($null -ne $Script:NRAPIConnectionInformation.AuthListenerPort) {
        $Secrets.NinjaOneAuthListenerPort = $Script:NRAPIConnectionInformation.AuthListenerPort.ToString()
    }
    if ($null -ne $Script:NRAPIAuthenticationInformation.Type) {
        $Secrets.NinjaOneType = $Script:NRAPIAuthenticationInformation.Type
    }
    if ($null -ne $Script:NRAPIAuthenticationInformation.Access) {
        $Secrets.NinjaOneAccess = $Script:NRAPIAuthenticationInformation.Access
    }
    if ($null -ne $Script:NRAPIAuthenticationInformation.Expires) {
        $Secrets.NinjaOneExpires = $Script:NRAPIAuthenticationInformation.Expires.ToString()
    }
    if ($null -ne $Script:NRAPIAuthenticationInformation.Refresh) {
        $Secrets.NinjaOneRefresh = $Script:NRAPIAuthenticationInformation.Refresh
    }
    if ($null -ne $Script:NRAPIConnectionInformation.UseSecretManagement) {
        $Secrets.NinjaOneUseSecretManagement = $Script:NRAPIConnectionInformation.UseSecretManagement.ToString()
    }
    if ($null -ne $Script:NRAPIConnectionInformation.WriteToSecretVault) {
        $Secrets.NinjaOneWriteToSecretVault = $Script:NRAPIConnectionInformation.WriteToSecretVault.ToString()
    }
    if ($null -ne $Script:NRAPIConnectionInformation.ReadFromSecretVault) {
        $Secrets.NinjaOneReadFromSecretVault = $Script:NRAPIConnectionInformation.ReadFromSecretVault.ToString()
    }
    if ($null -ne $Script:NRAPIConnectionInformation.VaultName) {
        $Secrets.NinjaOneVaultName = $Script:NRAPIConnectionInformation.VaultName
    }
    foreach ($Secret in $Secrets.GetEnumerator()) {
        Write-Verbose ('Processing secret {0} for vault storage.' -f $Secret.Key)
        Write-Debug ('Secret {0} has type {1}.' -f $Secret.Key, $Secret.Value.GetType().Name)
        Write-Debug ('Secret {0} has value {1}.' -f $Secret.Key, $Secret.Value.ToString())
        $SecretName = $Secret.Key
        $SecretValue = $Secret.Value
        if ([String]::IsNullOrEmpty($SecretValue) -or ($null -eq $SecretValue)) {
            Write-Verbose ('Secret {0} is null. Skipping.' -f $SecretName)
            continue
        }
        Set-Secret -Vault $VaultName -Name $SecretName -Secret $SecretValue -ErrorAction Stop
        Write-Verbose ('Secret {0} written to secret vault {1}.' -f $SecretName, $VaultName)
    }
}