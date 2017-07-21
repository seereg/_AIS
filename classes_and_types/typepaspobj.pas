unit typepaspobj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,ZDataset, ZConnection, unit_types_and_const;

type

  { TPassObj }

  TPassObj = class(TObject)
  private
    { private declarations }
    f_obj_id     :TMyField;
    f_obj_branch :TMyField;
    f_obj_pos    :TMyField;
    f_obj_type   :TMyField;
    f_obj_len    :TMyField;
    f_obj_rad    :TMyField;
    f_obj_tan    :TMyField;
    ZQProp: TZQuery;
    function  getValue(Index:Integer):string;
    procedure setValue(Index:Integer; Value:string);
  public
    { public declarations }
    property obj_id     :string          read f_pass_id.Value;  //write f_pass_id.Value;
    property obj_branch :string  Index 0 read getValue  write setValue;
    property obj_pos    :string  Index 1 read getValue  write setValue;
    property obj_type   :string  Index 2 read getValue  write setValue;
    property obj_len    :string  Index 3 read getValue  write setValue;
    property obj_rad    :string  Index 4 read getValue  write setValue;
    property obj_tan    :string  Index 5 read getValue  write setValue;

    constructor Create(p_obj_id:integer;conn:TZConnection);
    function getDate():boolean;
  end;

  TPassBranch = class(TObject)
  private
    { private declarations }
    p_branch_id     :TMyField;
    f_obj_
  public
    { public declarations }
    constructor Create(p_branch_id:integer;conn:TZConnection);
  end;
implementation

{ TPassProp }

function TPassObj.getValue(Index: Integer): string;
var
  fld:^TMyField;
begin
  try
    case index of
    0: fld:=addr(f_obj_branch);
    1: fld:=addr(f_obj_pos);
    2: fld:=addr(f_obj_type);
    3: fld:=addr(f_obj_len);
    4: fld:=addr(f_obj_rad);
    5: fld:=addr(f_obj_tan);
    else exit;
    end;
    result:=fld^.Value;
  except
    result:='';
  end;
end;

procedure TPassObj.setValue(Index: Integer; Value: string);
var
  fld:^TMyField;
  st:string;
begin
  try
    ZQProp.SQL.Clear;
    case index of
    0: fld:=addr(f_obj_branch);
    1: fld:=addr(f_obj_pos);
    2: fld:=addr(f_obj_type);
    3: fld:=addr(f_obj_len);
    4: fld:=addr(f_obj_rad);
    5: fld:=addr(f_obj_tan);
    else exit;
    end;
    if Value=fld^.Value then exit;
    ZQProp.SQL.Clear;
 {   if fld^.table='passports'
    then  st:='Update '+ fld^.table+' set '+fld^.name+'="'+Value+'" where id='+f_pass_id.Value
    else
      begin
        st:='INSERT OR IGNORE INTO '+ fld^.table+' (pass_id) VALUES ('+f_pass_id.Value+')';
        ZQProp.SQL.Add(st);
        ZQProp.ExecSQL;
        ZQProp.SQL.Clear;
        st:='Update '+ fld^.table+' set value ="'+Value+'" where pass_id='+f_pass_id.Value;
      end;
    ZQProp.SQL.Add(st);
    ZQProp.ExecSQL;  }
    fld^.Value:=Value;
  except
  end;
end;

constructor TPassObj.Create(p_obj_id: integer; conn: TZConnection);
begin
  inherited Create;
  ZQProp:= TZQuery.Create(nil);
  ZQProp.Connection:=conn;
  f_obj_id.value:=inttostr(p_obj_id);
  getDate();
end;

function TPassObj.getDate: boolean;
begin
  try
  ZQProp.Close;
  ZQProp.SQL.Clear;
  ZQProp.SQL.Add(GetSQL('obj',StrToInt(obj_id)));
  ZQProp.Open;
 ////////////
  f_obj_id     :TMyField;
  f_obj_branch :TMyField;
  f_obj_pos    :TMyField;
  f_obj_type   :TMyField;
  f_obj_len    :TMyField;
  f_obj_rad    :TMyField;
  f_obj_tan    :TMyField;
////////////////

  f_obj_branch.name   := 'pass_name';
  f_obj_branch.table  := 'passports';
  f_obj_branch.value  := ZQProp.FieldByName('pass_name') .AsString;

  except
    result:=false;
  end;
  result:=True;
end;

end.

