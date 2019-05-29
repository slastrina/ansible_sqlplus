#!powershell

# Oracle SQL Plus wrapper

# WANT_JSON
# POWERSHELL_COMMON

$__author__ = "Sam Lastrina"
$__copyright__ = ""
$__credits__ = "github.com/slastrina"
$__maintainer__ = "Sam Lastrina"
$__email__ = ""

$params = Parse-Args $args;

# At the minimum db configuration details are required
$dbUser = Get-Attr $params "dbUser" -failifempty $true
$dbPass = Get-Attr $params "dbPass" -failifempty $true
$dbConnectStr = Get-Attr $params "dbConnectStr" -failifempty $true
$bulkLoadPath = Get-Attr $params "bulkLoadPath" $Null  # "c:\pathToSQL\"
$singleSQLPath = Get-Attr $params "singleSQLPath" $Null  # "c:\pathToSQL\code.sql"
$query = Get-Attr $params "query" $Null  # "select 1 from dual;"
$extraArgs = Get-Attr $params "extraArgs" ''  # appended to the end of the command

# check sqlplus available globally - fail if not supplied
Try
{
    Get-Command sqlplus
    $connectionString = $dbUser + '/' + $dbUser + '@' + $dbConnectStr
}
Catch
{
    Fail-Json (New-Object psobject) "sqlplus not found. verify it is accessable via %PATH%"
}

# Function to perform bulkloading of sql scripts
function Sql-BulkLoad
{
    param 
    (
        [string] $bulkLoadPath = $(throw "missing bulkLoadPath param")
    )    

    $count = 0
    $commandOutput = $Null

    Get-ChildItem $bulkLoadPath -Filter *.sql | Foreach-Object {
        $command = '& echo exit | sqlplus -s ' + $connectionString + ' @' + $_.FullName # the echo exit quits sqlplus after command
        $commandOutput += $command # output command to be run
        $commandOutput += invoke-expression $command # stdout of the command
        $count += 1
    }

    if ($count -eq 0)
    {
        $result = New-Object psobject @{
            changed = $false
            msg = 'No Sql found at given bulkLoadPath'
        };
        Exit-Json $result;
    }
    else 
    {
        $result = New-Object psobject @{
            changed = $true
            count = 'Executed ' + $count + ' file/s'
            output = $commandOutput
        };
        Exit-Json $result;
    }
}

# Function to perform single SQL execution
function Sql-SingleSQL()
{

    $count = 0
    $commandOutput = $Null

    if (Test-Path $singleSQLPath) {
        $command = '& echo exit | sqlplus -s ' + $connectionString + ' @' + $singleSQLPath + ' ' + $extraArgs  # the echo exit quits sqlplus after command
        $commandOutput += $command # output command to be run
        $commandOutput += invoke-expression $command # stdout of the command
        $count += 1
    }

    if ($count -eq 0)
    {
        $result = New-Object psobject @{
            changed = $false
            msg = 'No Sql found at given bulkLoadPath'
        };
        Exit-Json $result;
    }
    else 
    {
        $result = New-Object psobject @{
            changed = $true
            count = 'Executed ' + $count + ' file/s'
            output = $commandOutput
        };
        Exit-Json $result;
    }
}

# Status Types
# Set-Attr $result "failed" $true;   // output = failed
# Set-Attr $result "failed" $false;  // output = ok
# Set-Attr $result "changed" $true;  // output = changed
# Set-Attr $result "changed" $false; // output = ok

# If bulkLoadPath run method
if ($bulkLoadPath -ne $Null)
{
    Sql-BulkLoad($bulkLoadPath)
}

# If singleSQLPath run method
if ($singleSQLPath -ne $Null)
{
    Sql-SingleSQL $singleSQLPath $extraArgs
}

# if we got to this point it means nothing was executed along the way
$result = New-Object psobject @{
    changed = $false
    msg = 'No command arguments provided'
};
Exit-Json $result;