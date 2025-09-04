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

Notes & Tips

Some sites generate PDF links with JavaScript. This script only parses the static HTML downloaded by Invoke-WebRequest. If links are injected dynamically, open DevTools → View Source to confirm the PDF URLs exist in the HTML; otherwise consider using a headless browser approach.

If the page requires authentication or cookies, you may need to add headers or a session (e.g., -WebSession).

Very large downloads can be slow; verify your target folder has enough disk space.

Troubleshooting

No PDF links found: The page might render links via JavaScript; see Notes above. Also confirm the page actually contains .pdf hrefs.

403/401 errors: The site may block automated requests or require login. Try running in a browser extension instead, or add appropriate headers/cookies.

Weird filenames: Some servers use Content-Disposition to suggest names; this script derives names from the URL path and de-duplicates. Adjust Get-SafeFileName if needed.
