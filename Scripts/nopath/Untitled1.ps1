
# Some buffoonery for puppeteer
return

$fileName = "conf.js"

$jasmineSpecReporterRequireInvocation = "require('jasmine-spec-reporter');"

$requireJasmineReporters = 'const jasmineReporters = require("jasmine-reporters");'
$setChromeBin = 'process.env.CHROME_BIN = process.env.CHROME_BIN || require("puppeteer").executablePath();'
$chromeBrowserCapability = "'browserName': 'chrome'"
$chromeBinConfigCapability = @'
  chromeOptions: {
    binary: process.env.CHROME_BIN
  }
'@

(Get-Content $fileName) | 
    Foreach-Object {
        $_ # send the current line to output

        # Configure headless Chrome
        if ($_.ToString().Contains($jasmineSpecReporterRequireInvocation)) 
        {
            # Add Jasmine Reporters requirement
            "$($requireJasmineReporters)"

            # Configure Chrome bin for the process (headed or headless)
            "$($setChromeBin)"
        }

        if ($_.ToString().Contains($chromeBrowserCapability))
        {
            # Add a comma; new properties incoming
            $_.ToString().Replace($chromeBrowserCapability, "$($chromeBrowserCapability),")

            # Use the Chrome bin defined by the process
            "$($chromeBinConfigCapability)"            
        }

    } | Set-Content $fileName