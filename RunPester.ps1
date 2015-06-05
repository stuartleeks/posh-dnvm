function GetLineNumber($stackTrace){
	if($stackTrace -match "at line: (\d*)"){
		$matches[1];
	} else {
		$null
	}
}
function GetFileName($stackTrace){
	if($stackTrace -match "at line: (?:\d*) in (.*)\n"){
		$matches[1];
	} else {
		$null
	}	
}
function FormatResult ($result){
	process {
		$lineNumber = GetLineNumber $_.StackTrace
		$file = GetFileName $_.StackTrace | Resolve-Path -Relative
		# $file = "C:\Users\Stuart\Source\Repos\posh-dnvm\DnvmTabExpansion.Tests.ps1" | Resolve-Path -Relative
		$collapsedMessage = $_.FailureMessage -replace "`n"," "
		$testDescription = "$($_.Describe):$($_.Name)"
		"$file;$lineNumber;${testDescription}:$collapsedMessage"
	}
}
Write-Host "Running tests..."
$results = Invoke-Pester -PassThru #-Quiet
$results.TestResult | ?{ -not $_.Passed} | FormatResult
Write-Host "Done"