program Player;

uses
  Vcl.Forms,
  uRegisterProduct in 'uRegisterProduct.pas' {frmRegister} ,
  Vcl.Themes,
  Vcl.Styles,
  uDbHelper in 'DB\uDbHelper.pas' {dbModule: TDataModule} ,
  uPlayer in 'Forms\uPlayer.pas' {frmPlayer} ,
  TMSEncryptedIniFile,
  System.SysUtils,
  System.IOUtils,
  LoggerPro.GlobalLogger,
  BoxedAppSDK_Static in 'BoxedAppSDK_Static.pas',
  uHelper in 'Helper\uHelper.pas',
  WMPLib_TLB in 'WMPLib_TLB.pas';

{$R *.res}

var
  localHwid: string;

begin
  try
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TdbModule, dbModule);
    var data_path := TPath.Combine(ExtractFileDir(Application.ExeName), '.data');
    Log.Info(data_path, 'player');
    if FileExists(TPath.Combine(ExtractFileDir(Application.ExeName), '.data'))
    then
    begin
      bEncryptedFile := TEncryptedIniFile.Create
        (TPath.Combine(ExtractFileDir(Application.ExeName), '.data'),
        uHelper.MasterKey);
      localHwid := bEncryptedFile.ReadString('PROTECTION', 'hwid', '');
      Log.Info(localHwid, 'player');
      if localHwid.Length > 0 then
      begin
        if localHwid = GetCPUSerialumber then
        begin
          Log.Info('Hwid compare is ok', 'player');
          Application.CreateForm(TfrmPlayer, frmPlayer);
        end
        else
        begin
          Log.Info('Hwid compare not ok', 'player');
  //        Application.CreateForm(TfrmPlayer, frmPlayer);
          Application.CreateForm(TfrmRegister, frmRegister);
        end;
      end
      else
      begin
        Log.Info('LH not ready', 'player');
        // Application.CreateForm(TfrmPlayer, frmPlayer);
        Application.CreateForm(TfrmRegister, frmRegister);
      end;
    end
    else
    begin
      Log.Debug('Data file not found', 'player');
    end;
    Application.Run;
  except on E: Exception do begin
    Log.Debug(E.Message, 'player');
  end;
  end;

end.
