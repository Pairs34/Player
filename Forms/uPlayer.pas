unit uPlayer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, Vcl.OleCtrls, WMPLib_TLB,
  cxSplitter, Vcl.ExtCtrls, cxTextEdit, Vcl.ComCtrls,
  cxShellCommon, cxContainer, cxEdit, cxTreeView, cxShellTreeView,
  System.IOUtils, BoxedAppSDK_Static, CryptBase, AESObj, TMSEncryptedIniFile,

  dxStatusBar, Winapi.ShlObj, Vcl.Menus, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP,System.StrUtils;

type
  TfrmPlayer = class(TForm)
    leftPanel: TPanel;
    cxSplitter: TcxSplitter;
    rightPanel: TPanel;
    player: TWindowsMediaPlayer;
    lstVideos: TcxShellTreeView;
    AESEncryption: TAESEncryption;
    dxStatusBar: TdxStatusBar;
    dxStatusBarContainer1: TdxStatusBarContainerControl;
    progress: TProgressBar;
    mainMenu: TMainMenu;
    btnDeactivate: TMenuItem;
    httpClient: TIdHTTP;
    procedure FormActivate(Sender: TObject);
    procedure lstVideosDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AESEncryptionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure playerPlayStateChange(ASender: TObject; NewState: Integer);
    procedure btnDeactivateClick(Sender: TObject);
  private
    const PLAYER_INFO_URI: string = 'http://license.videomanager.com/license/GetInfo';
    const DEACTIVATE_URI: string = 'http://license.gorselegitim.com.tr/activation/DeactivateFromUser';
    const DeactivateResponse: array[0..3] of string = (
                          'LICENSE_NOTFOUND',
                          'LICENSE_NOT_DEACTIVATED',
                          'ACTIVATION_NOTFOUND',
                          'LICENSE_DEACTIVATED');
  public
    { Public declarations }

  end;

var
  frmPlayer: TfrmPlayer;
  oStream: TMemoryStream;
  isDecrypting: bool;

implementation

{$R *.dfm}

uses
  uHelper;

procedure TfrmPlayer.AESEncryptionChange(Sender: TObject);
begin
  progress.Position := AESEncryption.Progress;

end;

procedure TfrmPlayer.btnDeactivateClick(Sender: TObject);
var
  encryptedFile: TEncryptedIniFile;
  licenseKey, bContent, bDecodedContent : string;
  bPostData: TStringList;
begin
  encryptedFile := TEncryptedIniFile.Create(TPath.Combine(ExtractFileDir(Application.ExeName), '.data'), uHelper.MasterKey);
  licenseKey := encryptedFile.ReadString('PROTECTION', 'licenseKey','');

  if MessageDlg('Programı deaktif yapmak istediğinize eminmisiniz ?',
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    bPostData := TStringList.Create;
    bPostData.Values['licenseKey'] := licenseKey;
    try
      bContent := httpClient.Post(DEACTIVATE_URI, bPostData);
    except on E: EIdHTTPProtocolException do begin
      ShowMessage(E.Message); Exit;
    end;
    end;
    bDecodedContent := Base64Decode(Copy(bContent, 11, Length(bContent)));
    case IndexStr(bDecodedContent, DeactivateResponse) of
      0..2:
        begin
          ShowMessage(format('Hata oluştu hata kodu : %s', [bDecodedContent]));
        end;
      3:
        begin
          try
            try
              encryptedFile.DeleteKey('PROTECTION','licenseKey');
              encryptedFile.DeleteKey('PROTECTION','hwid');
              encryptedFile.UpdateFile;
              encryptedFile.Free;

              ShowMessage('Program başarılı bir şekilde deaktif edilmiştir.');
              Application.Terminate;
            finally
            end;
          except
            on E: Exception do
            begin
              ShowMessage(E.Message);
            end;
          end;
        end
    else
      begin
        ShowMessage('Lisans devredışı bırakılırken hata oluştu lütfen desteğe başvurunuz.');
      end;
    end;
  end;
end;

procedure TfrmPlayer.FormActivate(Sender: TObject);
begin
  lstVideos.Root.CustomPath := ExtractFileDir(Application.ExeName);

end;

procedure TfrmPlayer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TfrmPlayer.FormCreate(Sender: TObject);
begin
  oStream := TMemoryStream.Create;
  player.uiMode := 'none';
end;

procedure TfrmPlayer.lstVideosDblClick(Sender: TObject);
var
  Handle: THandle;
  bExtension: string;
  bStream: THandleStream;
  encryptedFile: TEncryptedIniFile;
  taskRunning: bool;
begin
  bExtension := TPath.GetExtension(lstVideos.Path);
  if (bExtension = '.mp4') or (bExtension = '.avi') then
  begin
    lstVideos.Enabled := false;
    isDecrypting := true;
    taskRunning := false;
    player.controls.stop;
    player.enableContextMenu := false;
    player.uiMode := 'none';
    player.URL := 'loading.gif';
    player.settings.setMode('loop', True);

    if oStream.Size > 0 then
      oStream.Clear;

    TThread.CreateAnonymousThread(
      procedure
      begin

        bStream := TFileStream.Create(lstVideos.Path, fmOpenRead);
        encryptedFile := TEncryptedIniFile.Create(TPath.Combine(ExtractFileDir(Application.ExeName), '.data'), uHelper.MasterKey);

        with AESEncryption do
        begin
          IVMode := TIVMode.userdefined;
          key := encryptedFile.ReadString('PROTECTION', 'videoKey', '');
          IV := encryptedFile.ReadString('PROTECTION', 'videoIV', '');
        end;
        AESEncryption.DecryptStream(bStream, oStream);

        taskRunning := true;
      end).Start;

    while not taskRunning do
    begin
      Application.ProcessMessages;
    end;

    FreeAndNil(bStream);

    Handle := BoxedAppSDK_CreateVirtualFileBasedOnBuffer(PWideChar('1' + bExtension), GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_NEW, 0, 0, oStream.Memory, oStream.Size);

    CloseHandle(Handle);
    player.uiMode := 'full';
    player.settings.setMode('loop', False);
    isDecrypting := false;
    player.URL := '1' + bExtension;
    lstVideos.Enabled := true;
  end;
end;

procedure TfrmPlayer.playerPlayStateChange(ASender: TObject; NewState: Integer);
begin
  {
    0 : Undefined
    1 : Stopped
    2 : Paused
    3 : Playing
    4 : ScanForward
    5 : ScanReverse
    6 : Buffering
    7 : Waiting
    8 : MediaEnded
    9 : Transitioning
    10: Ready
    11: Reconnecting
    12: Last
  }
  case NewState of
    8:
      begin
        if not isDecrypting then
        begin
          oStream.Clear;
          player.uiMode := 'none';
        end;
      end;
  end;
end;

initialization
  BoxedAppSDK_Init;

end.

