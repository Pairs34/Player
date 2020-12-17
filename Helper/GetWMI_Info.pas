unit GetWMI_Info;

interface

uses
  SysUtils, ActiveX, ComObj, Variants;

function GetWin32_ProcessorInfo: string;

function GetWin32_MotherBoardInfo: string;

implementation

function GetWin32_ProcessorInfo: string;
const
  WbemUser = '';
  WbemPassword = '';
  WbemComputer = 'localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
begin
  ;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM Win32_Processor', 'WQL', wbemFlagForwardOnly);
  oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    try
      CoInitialize(nil);
      try
        Result := FWbemObject.ProcessorId;
      finally
        CoUninitialize;
      end;
    except
      on E: EOleException do
        Writeln(Format('EOleException %s %x', [E.Message, E.ErrorCode]));
      on E: Exception do
        Writeln(E.Classname, ':', E.Message);
    end;
    FWbemObject := Unassigned;
  end;
end;

function GetWin32_MotherBoardInfo: string;
const
  WbemUser = '';
  WbemPassword = '';
  WbemComputer = 'localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
begin
  ;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM Win32_BaseBoard', 'WQL', wbemFlagForwardOnly);
  oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    try
      CoInitialize(nil);
      try
        Result := FWbemObject.SerialNumber;
      finally
        CoUninitialize;
      end;
    except
      on E: EOleException do
        Writeln(Format('EOleException %s %x', [E.Message, E.ErrorCode]));
      on E: Exception do
        Writeln(E.Classname, ':', E.Message);
    end;
    FWbemObject := Unassigned;
  end;
end;

end.

