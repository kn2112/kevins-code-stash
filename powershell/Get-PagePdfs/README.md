# Get-PagePdfs.ps1 – Bulk download all PDFs linked on a page


A Windows PowerShell script that crawls a single web page, finds all PDF links, resolves relative URLs, and downloads them into a folder. No WSL required.


## Features
- Handles **relative and absolute** links
- Skips query strings when naming files; **avoids overwrites** (adds counters)
- Optional **same-host** filter for safety
- Sets a **User-Agent** (some sites block default)


## Requirements
- Windows PowerShell 5.1 or PowerShell 7+
- Internet access to the target site


> If you get script execution policy warnings, run PowerShell **as Administrator** and temporarily allow local scripts:
>
> ```powershell
> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
> ```
>
> This only affects the current PowerShell session.


## Usage


```powershell
# Download to a ./pdfs folder
./Get-PagePdfs.ps1 -PageUrl "https://example.com/page-with-links"


# Choose an output folder
./Get-PagePdfs.ps1 -PageUrl "https://example.com/page-with-links" -OutDir "C:\Users\Kevin\Downloads\PDFs"


# Only download PDFs from the same domain as the page
./Get-PagePdfs.ps1 -PageUrl "https://example.com/page-with-links" -SameHostOnly
