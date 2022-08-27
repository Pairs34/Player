unit uRegisterProduct;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, cxTextEdit, Vcl.ExtCtrls, REST.Types,
  Data.Bind.Components, System.StrUtils, typinfo,
  Data.Bind.ObjectScope, System.JSON, IdBaseComponent, IdComponent,
  System.IOUtils, IdTCPConnection, IdTCPClient, IdHTTP, TMSEncryptedIniFile,
  REST.Client;

type
  TfrmRegister = class(TForm)
    lblLicenseKey: TLinkLabel;
    txtLicenseKey: TcxTextEdit;
    lblName: TLinkLabel;
    txtUsername: TcxTextEdit;
    btnRegisterProduct: TcxButton;
    httpClient: TIdHTTP;
    lblMail: TLinkLabel;
    txtMail: TcxTextEdit;
    procedure btnRegisterProductClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    const
      LicenseResponse: array[0..5] of string = ('LICENSE_NOTFOUND', 'ACTIVATION_ERROR', 'REGISTRATION_ERROR', 'ONLY_ALLOWED_POST', 'LICENSE_ALREADY_REGISTERED', 'LICENSE_OK');
    const
      REGISTER_URI: string = 'http://license.gorselegitim.com.tr/license/RegisterLicense';
  public
    { Public declarations }
  end;

var
  frmRegister: TfrmRegister;
  bEncryptedFile: TEncryptedIniFile;

implementation

{$R *.dfm}

uses
  uHelper, uPlayer;

procedure TfrmRegister.btnRegisterProductClick(Sender: TObject);
var
  bContent, bDecodedContent,bKey ,bIV: string;
  bPostData: TStringList;
begin
  btnRegisterProduct.Enabled := false;
  try
    bEncryptedFile := TEncryptedIniFile.Create(TPath.Combine(ExtractFileDir(Application.ExeName), '.data'), uHelper.MasterKey);

    bKey := bEncryptedFile.ReadString('PROTECTION', 'videoKey', '');
    bIV  := bEncryptedFile.ReadString('PROTECTION', 'videoIV', '');

    if (bKey = '') and (bIV = '') then
    begin
      ShowMessage('Kayıt esnasında hata oluştu. VKEY');
      Application.Terminate;
      Exit;
    end;

    bPostData := TStringList.Create;
    bPostData.Values['licenseKey'] := txtLicenseKey.Text;
    bPostData.Values['username'] := txtUsername.Text;
    bPostData.Values['hwid'] := GetCPUSerialumber;
    bPostData.Values['mail'] := txtMail.Text;
    bPostData.Values['videoKey'] := bKey;
    bPostData.Values['videoIV'] := bIV;

    try
      bContent := httpClient.Post(REGISTER_URI, bPostData);
    except on E: EIdHTTPProtocolException do begin
      ShowMessage(E.Message); Exit;
    end;
    end;
    bDecodedContent := Base64Decode(Copy(bContent, 11, Length(bContent)));
    case IndexStr(bDecodedContent, LicenseResponse) of
      0..4:
        begin
          ShowMessage(format('Hata oluştu hata kodu : %s', [bDecodedContent]));
        end;
      5:
        begin
          try
            try
              bEncryptedFile.WriteString('PROTECTION', 'licenseKey', txtLicenseKey.Text);
              bEncryptedFile.WriteString('PROTECTION', 'hwid', GetCPUSerialumber());
              bEncryptedFile.UpdateFile;
              bEncryptedFile.Free;

              ShowMessage('Aktivasyonun tamamlanması için yeniden başlatınız.');
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
        ShowMessage('Lisanslama yapılırken hata oluştu lütfen desteğe başvurunuz.');
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Sunucu ile iletişimde hata oluştu.');
    end;
  end;
  btnRegisterProduct.Enabled := true;
end;

procedure TfrmRegister.FormCreate(Sender: TObject);
var
  localHwid: string;
begin
//  if FileExists(TPath.Combine(ExtractFileDir(Application.ExeName), '.data')) then
//  begin
//    bEncryptedFile := TEncryptedIniFile.Create(TPath.Combine(ExtractFileDir(Application.ExeName), '.data'), uHelper.MasterKey);
//    localHwid := bEncryptedFile.ReadString('PROTECTION', 'hwid', '');
//    if localHwid = GetCPUSerialumber then //fixlenecek
//    begin
//      bEncryptedFile.Free;
//      Application.CreateForm(TfrmPlayer, frmPlayer);
//      frmPlayer.Show();
//      Self.Hide;
//    end;
//  end;
end;

procedure TfrmRegister.FormShow(Sender: TObject);
begin
  ShowMessage(GetCPUSerialumber);
end;

end.

