# NLog
.SYNOPSIS\
&emsp;    Writes log output\
.DESCRIPTION\
&emsp;    Uses New-LogMessage to format an output message for file and/or console.\
&emsp;    Uses Invoke-PathValidation to verify path to file.\
&emsp;    Writes to file with either [System.IO.File]::AppendAllLines or [System.IO.File]::WriteAllLines depending on Append parameter.\
&emsp;    Uses Write-Console to output a console message.\
&emsp;    Uses Invoke-MessageBox to output to a [System.Windows.Forms.MessageBox] object.\
&emsp;    Uses Invoke-ToastNotification to output to a [System.Windows.Forms.NotifyIcon] object.\
&emsp;    Uses Send-SmtpMail to output log to mail.\
.EXAMPLE\
&emsp;    Write-Log -File -Path 'C:\log\pwshLog\error.log' -Append -Value $Error[0] -Loglevel Error\
&emsp;    Appends a logfile to C:\log\pwshLog\error.log with latest error message.\
\
&emsp;    Write-Log -Console -Notification -NotificationType 'Toast' -Value "Some Message" -Loglevel Information\
&emsp;    Writes Information message to console and sends it as a toast notification.\
.INPUTS\
&emsp;    File [switch], Console [switch], Notification [switch], Value [Object], Loglevel [string]\
.OUTPUTS\
&emsp;    [void]