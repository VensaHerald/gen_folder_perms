<#
Permissions/roles to look for in global variable

\\RPLFSPR02\Groups2$\Employment Services\Recruitment\Market Development & Operations\Scotland\Glasgow\Jackie's folder
#>
$global:ROLES="FullControl","ListDirectory","Modify","Traverse","Write","Synchronize"
$global:GROUP = "d.file.es.recruit.mktdevops.scotland.glasgow_manage.subfolders"



<#
accepts path of file ($path) to check and group/user ($ident_ref) to check against
using (get-acl -path "path").access on files to get the file system rights for given path
checks that $ident_ref is in list and has permission on list in $global:ROLES
returns 1 if is on list and 0 otherwise
#>

function CheckPerm {
param([string]$path, [string]$ident_ref)
    try {
        $file = (get-acl -path $path -ErrorAction Stop).Access
        foreach ($i in $file){
            if (($global:ROLES -contains $i.FileSystemRights) -and ($i.IdentityReference -eq "REMPLOYAD\"+$ident_ref))
                {
			    return 1
		        }
            }
        return 0
        }
    catch {
        Write-Error ("Get-ACL error:"+$path -f $_.ExceptionMessage)
        return -1
    }
}


<# 
loop through the file servers, get children recursively to a depth of x (where x is low enough such that the path does not become too long)
select full names of any object that is a directory (ie. folder)
loop through each $list_of_files for each share on the two fileservers
for each of the file paths check with CheckPerm function
if function returns 1 (ie. success) append path to $access list object
#>
$access = New-Object System.Collections.Generic.List[System.Object]


$path = "\\RPLFSPR02\Groups2$\Employment Services\Recruitment"
write-host -NoNewline "Looking at: " $path " "
$list_of_files =  Get-ChildItem -Path $path -Recurse -Depth 4 -Directory | Select-Object FullName  
write-host $list_of_files.length " files to be checked"
foreach ($file in $list_of_files){
    if ((CheckPerm -path $file.FullName -ident_ref $global:GROUP) -eq 1){$access.Add($file.FullName)
    }
            
        
}
#print for test of completion
foreach ($line in $access){
write-host $line
}