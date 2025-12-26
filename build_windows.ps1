$arch = "x64"
$vs_arch = "x86.x64"
$cmake_arch = "x64"

if ($Args[0] -eq "arm64")
{
	$arch = $Args[0]
	$vs_arch = "ARM64"
	$cmake_arch = "ARM64"
}

$sdlPath = Convert-Path -LiteralPath "./SDL"
$faudioPath = Convert-Path -LiteralPath "./FAudio"

$outputFolder = "./binaries/win-$arch"

Remove-Item $outputFolder -Recurse -ErrorAction SilentlyContinue
if (!(Test-Path -Path $outputFolder)) {New-Item $outputFolder -Type Directory >$null}

$logFolder = "./logs/win-$arch"

Remove-Item $logFolder -Recurse -ErrorAction SilentlyContinue
if (!(Test-Path -Path $logFolder)) {New-Item $logFolder -Type Directory >$null}

$buildFolder = "build"

$sdlBuild = "$sdlPath/$buildFolder"
$faudioBuild = "$faudioPath/$buildFolder"
			
Write-Host "Look for MSBuild with C++ support" -ForegroundColor DarkCyan

	Set-Alias vswhere -Value "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

	$msbuild = vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.$vs_arch -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1
	if (!$msbuild -Or !(Test-Path -Path $msbuild))
	{
		Write-Host "`tNot installed. Build aborted. Please install Visual Studio with the C++ component." -ForegroundColor DarkRed
		Read-Host -Prompt "Press Enter to exit"
		Break
	}
	else
	{
		Write-Host "`tFound at: $msbuild"
		Set-Alias msbuild -Value "$msbuild"
	}
	
Write-Host "Look for CMake support" -ForegroundColor DarkCyan

	if (!(Get-Command "cmake" -errorAction SilentlyContinue))
	{
		$cmake = vswhere -latest -find **\cmake.exe | select-object -first 1
		if (!$cmake -Or !(Test-Path -Path $cmake))
		{
			Write-Host "`tCMake is not installed or not on PATH. Please add it to PATH or install it from the Visual Studio components." -ForegroundColor DarkRed
			Read-Host -Prompt "Press Enter to exit"
			Break
		}
		else
		{
			Write-Host "`tFound at (from Visual Studio): $cmake"
			Set-Alias cmake -Value "$cmake"
		}
	}
	else
	{
		$cmake = (Get-Command "cmake" -errorAction SilentlyContinue).Path
		Write-Host "`tFound at (from PATH): $cmake"
	}

Write-Host "Generate SDL" -ForegroundColor DarkCyan

	Remove-Item $sdlBuild -Recurse -ErrorAction SilentlyContinue
	if (!(Test-Path -Path $sdlBuild)) {New-Item $sdlBuild -Type Directory >$null}

	cmake -S $sdlPath -B $sdlBuild -G "Visual Studio 17 2022" -A $cmake_arch -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded | Out-File -FilePath "$logFolder/SDL.gen.log" -Append

	Write-Host "`tDone"

Write-Host "Build SDL" -ForegroundColor DarkCyan

	msbuild $sdlBuild/SDL3.sln /p:Configuration="Release" /p:Platform="$cmake_arch" | Out-File -FilePath "$logFolder/SDL.bin.log" -Append

	Write-Host "`tDone"
	
Write-Host "Generate FAudio" -ForegroundColor DarkCyan

	Remove-Item $faudioBuild -Recurse -ErrorAction SilentlyContinue
	if (!(Test-Path -Path $faudioBuild)) {New-Item $faudioBuild -Type Directory >$null}

	cmake -S $faudioPath -B $faudioBuild -G "Visual Studio 17 2022" -A $cmake_arch -DSDL3_DIR="$sdlBuild" -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded | Out-File -FilePath "$logFolder/FAudio.gen.log" -Append

	Write-Host "`tDone"

Write-Host "Build FAudio" -ForegroundColor DarkCyan

	msbuild $faudioBuild/FAudio.sln /t:FAudio-shared /p:Configuration="Release" /p:Platform="$cmake_arch" | Out-File -FilePath "$logFolder/FAudio.bin.log" -Append

	if (!(Test-Path -Path "$outputFolder")) {New-Item "$outputFolder" -Type Directory >$null}
	Copy-Item -Path "$faudioBuild/Release/FAudio.dll" -Destination "$outputFolder/FAudio.dll"
	
	Write-Host "`tDone"

Read-Host -Prompt "All done - Press Enter to exit"