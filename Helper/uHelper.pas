unit uHelper;

interface

uses
  idGlobal, IdCoderMIME, System.SysUtils, System.NetEncoding, Variants, MSI_Common, MSI_CPU;

const
  Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
  MasterKey = 'T6cAYuX*A64^R9tEX=ss@Fzq-y?LF#3!';

function Base64Decode(T: string): string;

function IsEmptyOrNull(const Value: Variant): Boolean;

function GetCPUSerialumber: string;

implementation

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
var
  CPU: TMiTeC_CPU;
begin
  CPU:=TMiTeC_CPU.Create(nil);
  CPU.RefreshData();
  Result := CPU.SerialNumber;
end;

end.

