program Player;

uses
  Vcl.Forms,
  uRegisterProduct in 'uRegisterProduct.pas' {frmRegister},
  Vcl.Themes,
  Vcl.Styles,
  uDbHelper in 'DB\uDbHelper.pas' {dbModule: TDataModule},
  uPlayer in 'Forms\uPlayer.pas' {frmPlayer},
  TMSEncryptedIniFile,
  System.SysUtils,
  System.IOUtils,
  BoxedAppSDK_Static in 'BoxedAppSDK_Static.pas',
  uHelper in 'Helper\uHelper.pas',
  WMPLib_TLB in 'WMPLib_TLB.pas';

{$R *.res}

var
  localHwid: string;
  calculatedhwid: string;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Tablet Light');
  Application.CreateForm(TdbModule, dbModule);
  if FileExists(TPath.Combine(ExtractFileDir(Application.ExeName), '.data')) then
  begin
    Application.CreateForm(TfrmPlayer, frmPlayer);
    bEncryptedFile := TEncryptedIniFile.Create(TPath.Combine(ExtractFileDir(Application.ExeName), '.data'), uHelper.MasterKey);
    localHwid := bEncryptedFile.ReadString('PROTECTION', 'hwid', '');
    calculatedhwid := GetCPUSerialumber;

    if localHwid = GetCPUSerialumber then
    begin
      Application.CreateForm(TfrmPlayer, frmPlayer);
    end
    else
    begin
      //Application.CreateForm(TfrmPlayer, frmPlayer);
      Application.CreateForm(TfrmRegister, frmRegister);
    end;
  end;
  Application.Run;
end.

