unit uDbHelper;

interface

uses
  System.SysUtils, System.Classes;

type
  TdbModule = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dbModule: TdbModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
