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
  IdTCPConnection, IdTCPClient, IdHTTP,System.StrUtils, MSI_Common, MSI_CPU;

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
    MiTeC_CPU1: TMiTeC_CPU;
    procedure FormActivate(Sender: TObject);
    procedure lstVideosDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AESEncryptionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure playerPlayStateChange(ASender: TObject; NewState: Integer);
    procedure btnDeactivateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
  licenseKey, bContent, bDecodedContent,bKey,bIV : string;
  bPostData: TStringList;
begin
  encryptedFile := TEncryptedIniFile.Create(TPath.Combine(ExtractFileDir(Application.ExeName), '.data'), uHelper.MasterKey);
  licenseKey := encryptedFile.ReadString('PROTECTION', 'licenseKey','');
  bKey := encryptedFile.ReadString('PROTECTION', 'videoKey','');
  bIV := encryptedFile.ReadString('PROTECTION', 'videoIV','');

  if (licenseKey = '') and (bKey = '') and (bIV = '') then
  begin
    ShowMessage('Pasif yapma esnasında hata oluştu. LKEY');
    Application.Terminate;
    Exit;
  end;

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
              encryptedFile.WriteString('PROTECTION', 'videoKey', bKey);
              encryptedFile.WriteString('PROTECTION', 'videoIV', bIV);
              encryptedFile.UpdateFile;

              ShowMessage('Program başarılı bir şekilde deaktif edilmiştir.');
              Application.Terminate;
            finally
              encryptedFile.Free;
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
  player.uiMode := 'none';
end;

procedure TfrmPlayer.FormShow(Sender: TObject);
begin
ShowMessage(GetCPUSerialumber);
end;

procedure TfrmPlayer.lstVideosDblClick(Sender: TObject);
var
  fHandle: THandle;
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

    fHandle := BoxedAppSDK_CreateVirtualFile(
      PWideChar(TPath.Combine(GetCurrentDir,'1.mp4')),
      GENERIC_WRITE,
      FILE_SHARE_READ,
      nil,
      CREATE_NEW,
      0,
      0
    );

    var fHandleStream := THandleStream.Create(fHandle);

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
        AESEncryption.DecryptStream(bStream, fHandleStream);

        taskRunning := true;
      end).Start;

    while not taskRunning do
    begin
      Application.ProcessMessages;
    end;

    CloseHandle(Handle);
    FreeAndNil(fHandleStream);
    FreeAndNil(bStream);
    FreeAndNil(encryptedFile);

    player.uiMode := 'full';
    player.settings.setMode('loop', False);
    isDecrypting := false;
    player.URL := TPath.Combine(GetCurrentDir,'1.mp4');
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
          player.uiMode := 'none';
        end;
      end;
  end;
end;

initialization
  BoxedAppSDK_Init;

end.

