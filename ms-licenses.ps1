# App by Jonathan Cauthorn
# Created 2017-03-12
# App based on: https://technet.microsoft.com/en-us/library/dn975125.aspx
# msonline v2: https://docs.microsoft.com/en-us/powershell/azuread/v2/azureactivedirectory
# download: https://github.com/Azure/azure-docs-powershell-azuread/blob/master/Azure%20AD%20Cmdlets/AzureAD/index.md
# and here: https://www.powershellgallery.com/packages/AzureAD/2.0.0.33
# Proper: https://www.microsoft.com/en-us/download/details.aspx?id=47594
# AADPM: https://msdn.microsoft.com/en-us/library/azure/jj151815(v=azure.98).aspx
# Connect-MsolService: https://msdn.microsoft.com/en-us/library/azure/dn194123(v=azure.98).aspx
# https://docs.microsoft.com/en-us/powershell/msonline/v1/azureactivedirectory
# https://docs.microsoft.com/en-us/powershell/msonline/v1/get-msolpartnerinformation
# https://docs.microsoft.com/en-us/powershell/msonline/v1/get-msolpartnercontract
# (Get-Item C:\Windows\System32\WindowsPowerShell\v1.0\Modules\MSOnline\Microsoft.Online.Administration.Automation.PSModule.dll).VersionInfo.FileVersion
# this should be version 1.1.166.0 or higher
# Licenses and services: https://technet.microsoft.com/en-us/library/dn771773.aspx
# License info cmdlet: https://technet.microsoft.com/en-us/library/dn771771.aspx

# also get last login time!
# remove accounts without licenses
# lookup table for E3, E5, other products


# Required Software to needed PowerShell cmdlet: https://technet.microsoft.com/en-us/library/dn975125.aspx

#Setup System variables
#Newline, Carriage return
$n="`n`r"
$maxLicenses = 0

#Begin main routine
#Connect to MSOnline Cloud Service and login
Import-Module MSOnline
$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential -Debug

#Get all the customer name and GUID information for the cloud service provider
$csp = Get-MsolPartnercontract

#Get the total number of clients for the cloud service provider
$totalClients = $csp.Count

# Loop through each client, ordinal count
for ($i=0; $i -le $totalClients - 1; $i++)
    {
        #Get basic information about current customer
        $cn = $csp[$i].Name
        $ddn = $csp[$i].DefaultDomainName
        $tid = $csp[$i].TenantId
        $ci = Get-MsolCompanyInformation -TenantId $tid
        
        #Get user information for current customer
        $u = Get-MsolUser -all -TenantId $tid
        $totalUsers = $u.Length
        $totalLicenses = 0    #Reset totalLicenses for current customer

        #Display information gathered so far
        "Client number: " + $i
        $cn
        $ddn
        $tid
        "Users: " + $totalUsers
        
        #Loop through each user, ordinal count
        for ($e=0; $e -le $totalUsers -1; $e++)
            {
                #Get information on current user
                $dn = $u[$e].DisplayName
                $upn = $u[$e].UserPrincipalName
                $Licensed = $u[$e].IsLicensed

                #Get license information on current user
                $ss = $u[$e].Licenses|Select-Object -ExpandProperty ServiceStatus
                $plan = ""    #reset plan for each user
                #$ss.Length   #This shows how many different license types a client has, not needed

                #Loop through each license for a user, ordinal count, only count assigned licenses indicated by "success"
                for ($c=0; $c -le $ss.Length -1; $c++)
                    {
                    if ($ss[$c].ProvisioningStatus -ieq "Success")
                        {
                            $plan=$plan + $ss[$c].ServicePlan.ServiceName + " (" + $ss[$c].ServicePlan.ServiceType + ") "
                        } 
                    } #license count loop
                $e.ToString() + ": "  + "isLicensed: " + $Licensed + "`t" + $dn + "`t" + $upn + "`t" + $plan
                if ($Licensed -ieq "True") 
                    {$totalLicenses++}
            } #User count loop

            # add up total number of licenses per client and total
            $maxLicenses = $maxLicenses + $totalLicenses
            "*** Total Licensed users for " + $cn + " is " + $totalLicenses + " of " + $maxLicenses + "."
            $n
    } #Client count loop
"*** Total Licensed users is " + $maxLicenses + "."


# That's all she wrote


