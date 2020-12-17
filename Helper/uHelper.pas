unit uHelper;

interface

uses
  idGlobal, IdCoderMIME, System.SysUtils, System.NetEncoding, Variants;

const
  Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
  MasterKey = 'T6cAYuX*A64^R9tEX=ss@Fzq-y?LF#3!';

function Base64Decode(T: string): string;

function IsEmptyOrNull(const Value: Variant): Boolean;

function GetCPUSerialumber: string;

implementation

uses
  GetWMI_Info;

function Base64Decode(T: string): string;
begin
  Result := TNetEncoding.Base64.Decode(T);
end;

function IsEmptyOrNull(const Value: Variant): Boolean;
begin
  Result := VarIsClear(Value) or VarIsEmpty(Value) or VarIsNull(Value) or (VarCompareValue(Value, Unassigned) = vrEqual);
  if (not Result) and VarIsStr(Value) then
    Result := Value = '';
end;

function GetCPUSerialumber: string;
begin
  Result := GetWin32_ProcessorInfo + GetWin32_MotherBoardInfo;
end;

end.

