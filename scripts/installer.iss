[Setup]
AppId={{9F82A4D1-5C2B-4E3F-9871-334188F1109C}
AppName=Alkitab Harmoni & Suara
AppVersion=1.0.0
AppPublisher=Alkitab Harmoni
DefaultDirName={autopf}\Alkitab Harmoni & Suara
DefaultGroupName=Alkitab Harmoni & Suara
OutputDir=..\dist
OutputBaseFilename=Alkitab_Harmoni_Suara_Windows_Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest

[Languages]
Name: "indonesian"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\windows\x64\runner\Release\alkitab_suara_harmoni.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\native_assets.json"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Alkitab Harmoni & Suara"; Filename: "{app}\alkitab_suara_harmoni.exe"
Name: "{group}\{cm:UninstallProgram,Alkitab Harmoni & Suara}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Alkitab Harmoni & Suara"; Filename: "{app}\alkitab_suara_harmoni.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\alkitab_suara_harmoni.exe"; Description: "{cm:LaunchProgram,Alkitab Harmoni & Suara}"; Flags: nowait postinstall skipifsilent
