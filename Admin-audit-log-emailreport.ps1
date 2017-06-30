param(
[Parameter(Position=0, Mandatory=$true)]
$To,
[Parameter(Position=1, Mandatory=$true)]
$From,
[Parameter(Position=2, Mandatory=$true)]
$SmtpServer
)

function New-AuditLogReport {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [Microsoft.Exchange.Management.SystemConfigurationTasks.AdminAuditLogEvent]
        $AuditLogEntry	
        )
	begin {
$css = @'
	<style type="text/css">
	body { font-family: Tahoma, Geneva, Verdana, sans-serif;}
	table {border-collapse: separate; background-color: #F2F2F2; border: 3px solid #103E69; caption-side: bottom;}
	td { border:1px solid #103E69; margin: 3px; padding: 3px; vertical-align: top; background: #F2F2F2; color: #000;font-size: 12px;}
	thead th {background: #903; color:#fefdcf; text-align: left; font-weight: bold; padding: 3px;border: 1px solid #990033;}
	th {border:1px solid #CC9933; padding: 3px;}
	tbody th:hover {background-color: #fefdcf;}
	th a:link, th a:visited {color:#903; font-weight: normal; text-decoration: none; border-bottom:1px dotted #c93;}
	caption {background: #903; color:#fcee9e; padding: 4px 0; text-align: center; width: 40%; font-weight: bold;}
	tbody td a:link {color: #903;}
	tbody td a:visited {color:#633;}
	tbody td a:hover {color:#000; text-decoration: none;
	}
	</style>
'@	
		$sb = New-Object System.Text.StringBuilder
		[void]$sb.AppendLine($css)
		[void]$sb.AppendLine("<table cellspacing='0'>")
		[void]$sb.AppendLine("<tr><td colspan='6'><strong>Exchange 2010 Administrator Audit Log Report for $((get-date).ToShortDateString())</strong></td></tr>")
		[void]$sb.AppendLine("<tr>")
		[void]$sb.AppendLine("<td><strong>Caller</strong></td>")
		[void]$sb.AppendLine("<td><strong>Run Date</strong></td>")
		[void]$sb.AppendLine("<td><strong>Succeeded</strong></td>")
		[void]$sb.AppendLine("<td><strong>Cmdlet</strong></td>")
		[void]$sb.AppendLine("<td><strong>Parameters</strong></td>")
		[void]$sb.AppendLine("<td><strong>Object Modified</strong></td>")
		[void]$sb.AppendLine("</tr>")
	}
	
	process {
		[void]$sb.AppendLine("<tr>")
		[void]$sb.AppendLine("<td>$($AuditLogEntry.Caller.split("/")[-1])</td>")
		[void]$sb.AppendLine("<td>$($AuditLogEntry.RunDate.ToString())</td>")
		[void]$sb.AppendLine("<td>$($AuditLogEntry.Succeeded)</td>")
		[void]$sb.AppendLine("<td>$($AuditLogEntry.cmdletname)</td>")
		$cmdletparameters += $AuditLogEntry.cmdletparameters | %{
			"$($_.name) : $($_.value)<br>"
		}
		[void]$sb.AppendLine("<td>$cmdletparameters</td>")
		[void]$sb.AppendLine("<td>$($AuditLogEntry.ObjectModified)</td>")
		[void]$sb.AppendLine("</tr>")
		$cmdletparameters = $null
	}
	
	end {
		[void]$sb.AppendLine("</table>")
		Write-Output $sb.ToString()
	}
}

Send-MailMessage -To $To `
-From $From `
-Subject "Exchange Audit Log Report for $((get-date).ToShortDateString())" `
-Body (Search-AdminAuditLog -StartDate ((Get-Date).AddHours(-24)) -EndDate (Get-Date) | New-AuditLogReport) `
-SmtpServer $SmtpServer `
-BodyAsHtml