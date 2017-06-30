$filename = Read-Host "Enter filename of log"
Get-Content $filename -Encoding unicode | select-string "Set detail information" -Context 5 |
%{
    $h = @{}
    $h."Set Detail Information" = ($_.line -replace "Set Detail Information\s-","") -replace "\s{2,}"," ";
    switch -regex ($_.context.postcontext){        
        "(Set\sstatus)\W+:\s(.+?)Set" {$h.($matches[1])=$matches[2]}
        "(Resource\sname)\W+:\s(.+?)Logon" {$h.($matches[1])=$matches[2]}
        "(Byte\scount)\W+:\s(.+?)Rate" {$h.($matches[1])=$matches[2]}
        "(Rate)\W+:\s(.+?)Files" {$h.($matches[1])=$matches[2]}
        "(Start\stime)\W+:\s(.+?)End\stime" {$h.($matches[1])=$matches[2]}
        "(End\stime)\W+:\s(.+?)(Media|General)" {$h.($matches[1])=$matches[2]}
    }
    New-Object -TypeName psobject -Property $h
}