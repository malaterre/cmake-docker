# escape=`

ARG WSCI_VERSION=ltsc2019
FROM mcr.microsoft.com/windows/servercore:${WSCI_VERSION}

# default shell for RUN commands:
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Visual Studio 2019 online installer
ADD https://aka.ms/vs/16/release/channel C:\TEMP\VisualStudio2019.chman
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools2019.exe

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Microsoft.VisualStudio.Workload.VCTools
# https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019#desktop-development-with-c
#RUN C:\TEMP\vs_buildtools2019.exe --wait --norestart --nocache `
#    --installPath C:\BuildTools `
#    --channelUri C:\Temp\VisualStudio2019.chman `
#    --installChannelUri C:\Temp\VisualStudio2019.chman `
#    --add Microsoft.VisualStudio.Workload.VCTools `
#    --add Microsoft.VisualStudio.Component.VC.CMake.Project `
#    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
#|| IF "%ERRORLEVEL%"=="3010" EXIT 0

RUN C:\TEMP\vs_buildtools2019.exe --quiet --wait --norestart --nocache `
	--installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" `
    --channelUri C:\Temp\VisualStudio2019.chman `
    --installChannelUri C:\Temp\VisualStudio2019.chman `
    --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
|| IF "%ERRORLEVEL%"=="3010" EXIT 0

# Microsoft.VisualStudio.Workload.MSBuildTools
# https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019#msbuild-tools
#RUN C:\TEMP\vs_buildtools2019.exe --quiet --wait --norestart --nocache `
#    --installPath C:\BuildTools `
#    --channelUri C:\Temp\VisualStudio2019.chman `
#    --installChannelUri C:\Temp\VisualStudio2019.chman `
#    --add Microsoft.VisualStudio.Workload.MSBuildTools `
#|| IF "%ERRORLEVEL%"=="3010" EXIT 0

# Visual Studio 2022 online installer
ADD https://aka.ms/vs/17/release/channel C:\TEMP\VisualStudio2022.chman
ADD https://aka.ms/vs/17/release/vs_buildtools.exe C:\TEMP\vs_buildtools2022.exe

RUN C:\TEMP\vs_buildtools2022.exe --quiet --wait --norestart --nocache `
	--installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
    --channelUri C:\Temp\VisualStudio2022.chman `
    --installChannelUri C:\Temp\VisualStudio2022.chman `
    --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended `
	--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
|| IF "%ERRORLEVEL%"=="3010" EXIT 0


# Install current .NET SDK:
# Microsoft.VisualStudio.Workload.UniversalBuildTools
# https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022#universal-windows-platform-build-tools
#RUN C:\TEMP\vs_buildtools2022.exe --quiet --wait --norestart --nocache `
#    --installPath C:\BuildTools `
#    --channelUri C:\Temp\VisualStudio2022.chman `
#    --installChannelUri C:\Temp\VisualStudio2022.chman `
#    --add Microsoft.VisualStudio.Workload.UniversalBuildTools `
#|| IF "%ERRORLEVEL%"=="3010" EXIT 0

# restore default SHELL to powershell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# install choco package manager:
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
# RUN choco --version;

# install cmake@3.26.3
ARG CMAKE_VERSION=3.26.3
RUN choco install cmake.install --installargs '"ADD_CMAKE_TO_PATH=System"' -y --version=$($Env:CMAKE_VERSION);
# RUN cmake --version;

# revert workdir to default:
WORKDIR C:/demo

COPY . .

#ARG vswhere = "C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"
RUN ["C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe","-products","*"]

#RUN cmake -G '"Visual Studio 16 2019"' -S . -B bin19
#RUN cmake --build bin19

#RUN cmake -G '"Visual Studio 17 2022"' -S . -B bin22
#RUN cmake --build bin22

# define a script to run when the container is instantiated:
ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
