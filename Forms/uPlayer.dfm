object frmPlayer: TfrmPlayer
  Left = 0
  Top = 0
  Caption = 'Player v1.0.1'
  ClientHeight = 648
  ClientWidth = 1023
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mainMenu
  OldCreateOrder = False
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object leftPanel: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 628
    Align = alLeft
    TabOrder = 0
    object lstVideos: TcxShellTreeView
      Left = 1
      Top = 1
      Width = 183
      Height = 626
      Align = alClient
      Indent = 19
      Options.ContextMenus = False
      Options.FileMask = '*.mp4;*.avi'
      RightClickSelect = True
      Root.BrowseFolder = bfCustomPath
      TabOrder = 0
      OnDblClick = lstVideosDblClick
    end
  end
  object cxSplitter: TcxSplitter
    Left = 185
    Top = 0
    Width = 8
    Height = 628
    HotZoneClassName = 'TcxSimpleStyle'
  end
  object rightPanel: TPanel
    Left = 193
    Top = 0
    Width = 830
    Height = 628
    Align = alClient
    TabOrder = 2
    object player: TWindowsMediaPlayer
      Left = 1
      Top = 1
      Width = 828
      Height = 626
      Align = alClient
      TabOrder = 0
      OnPlayStateChange = playerPlayStateChange
      ExplicitTop = 224
      ExplicitWidth = 424
      ExplicitHeight = 403
      ControlData = {
        0003000008000200000000000500000000000000F03F03000000000005000000
        00000000000008000200000000000300010000000B00FFFF0300000000000B00
        FFFF08000200000000000300320000000B00000008000A000000660075006C00
        6C0000000B0000000B00FFFF0B00FFFF0B00FFFF0B0000000800020000000000
        0800020000000000080002000000000008000200000000000B00000094550000
        B3400000}
    end
  end
  object dxStatusBar: TdxStatusBar
    Left = 0
    Top = 628
    Width = 1023
    Height = 20
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarContainerPanelStyle'
        PanelStyle.Container = dxStatusBarContainer1
        Text = 'progressContainer'
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    object dxStatusBarContainer1: TdxStatusBarContainerControl
      Left = 2
      Top = 4
      Width = 1003
      Height = 14
      object progress: TProgressBar
        Left = 0
        Top = 0
        Width = 1003
        Height = 14
        Align = alClient
        BarColor = clMaroon
        TabOrder = 0
      end
    end
  end
  object AESEncryption: TAESEncryption
    Version = '4.2.5.0'
    key = 'tktuzlashipyardd'
    outputFormat = raw
    IVMode = userdefined
    IV = 'tktuzlashipyardd'
    OnChange = AESEncryptionChange
    Left = 256
    Top = 24
  end
  object mainMenu: TMainMenu
    Left = 328
    Top = 232
    object btnDeactivate: TMenuItem
      Caption = 'Pasif Yap'
      OnClick = btnDeactivateClick
    end
  end
  object httpClient: TIdHTTP
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 448
    Top = 200
  end
  object MiTeC_CPU1: TMiTeC_CPU
    Left = 809
    Top = 432
  end
end
