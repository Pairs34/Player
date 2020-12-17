object frmPlayer: TfrmPlayer
  Left = 0
  Top = 0
  Caption = 'frmPlayer'
  ClientHeight = 454
  ClientWidth = 669
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object leftPanel: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 434
    Align = alLeft
    TabOrder = 0
    object lstVideos: TcxShellTreeView
      Left = 1
      Top = 1
      Width = 183
      Height = 432
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
    Height = 434
    HotZoneClassName = 'TcxSimpleStyle'
  end
  object rightPanel: TPanel
    Left = 193
    Top = 0
    Width = 476
    Height = 434
    Align = alClient
    TabOrder = 2
    object player: TWindowsMediaPlayer
      Left = 1
      Top = 1
      Width = 474
      Height = 432
      Align = alClient
      TabOrder = 0
      OnPlayStateChange = playerPlayStateChange
      ExplicitWidth = 245
      ExplicitHeight = 240
      ControlData = {
        000300000800000000000500000000000000F03F030000000000050000000000
        0000000008000200000000000300010000000B00FFFF0300000000000B00FFFF
        08000200000000000300320000000B00000008000A000000660075006C006C00
        00000B0000000B0000000B00FFFF0B00FFFF0B00000008000200000000000800
        020000000000080002000000000008000200000000000B000000FD300000A62C
        0000}
    end
  end
  object dxStatusBar: TdxStatusBar
    Left = 0
    Top = 434
    Width = 669
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
      Width = 649
      Height = 14
      object progress: TProgressBar
        Left = 0
        Top = 0
        Width = 649
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
    IV = 'tktuzlashipyardd'
    OnChange = AESEncryptionChange
    Left = 256
    Top = 24
  end
end
