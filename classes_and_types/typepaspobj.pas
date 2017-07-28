unit typePaspObj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,ZDataset, ZConnection, unit_types_and_const;

type

  { TPassObj }

  TPassObj = class(TComponent)
  private
    { private declarations }
    f_obj_id     :TMyField;
    f_obj_branch :TMyField;
    f_obj_pos    :TMyField;
    f_obj_type   :TMyField;
    f_obj_len    :TMyField;
    f_obj_rad    :TMyField;
    f_obj_tan    :TMyField;
    f_conn       :TZConnection;
    ZQProp: TZQuery;
    function  getValue(Index:Integer):string;
    procedure setValue(Index:Integer; Value:string);
  public
    { public declarations }
    property obj_id     :string          read f_obj_id.Value;  //write f_pass_id.Value;
    property obj_branch :string  Index 0 read getValue  write setValue;
    property obj_pos    :string  Index 1 read getValue  write setValue;
    property obj_type   :string  Index 2 read getValue  write setValue;
    property obj_len    :string  Index 3 read getValue  write setValue;
    property obj_rad    :string  Index 4 read getValue  write setValue;
    property obj_tan    :string  Index 5 read getValue  write setValue;

    constructor Create(TheOwner: TComponent;p_obj_id:integer;p_conn:TZConnection);
    function getDate():boolean;
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

constructor TPassObj.Create(TheOwner: TComponent; p_obj_id: integer;
  p_conn: TZConnection);
begin
  inherited Create(TheOwner);
  f_conn:=p_conn;
  ZQProp:= TZQuery.Create(nil);
  ZQProp.Connection:=f_conn;
  f_obj_id.value:=inttostr(p_obj_id);
  getDate();
end;

function TPassObj.getDate: boolean;
begin
  try
 { ZQProp.Close;
  ZQProp.SQL.Clear;
  ZQProp.SQL.Add(GetSQL('obj_prop',StrToInt(obj_id)));
  ZQProp.Open;  }
 {////////////
  f_obj_id     :TMyField;
  f_obj_branch :TMyField;
  f_obj_pos    :TMyField;
  f_obj_type   :TMyField;
  f_obj_len    :TMyField;
  f_obj_rad    :TMyField;
  f_obj_tan    :TMyField;
////////////////  }

  f_obj_branch.name   := 'pass_name';
  f_obj_branch.table  := 'passports';
//  f_obj_branch.value  :=При создании;// ZQProp.FieldByName('pass_name') .AsString;

  f_obj_pos.name   := 'pass_name';
  f_obj_pos.table  := 'passports';
  f_obj_pos.value  :='1';// ZQProp.FieldByName('pass_name') .AsString;

  f_obj_pos.name   := 'pass_name';
  f_obj_pos.table  := 'passports';
  f_obj_pos.value  :='2';// ZQProp.FieldByName('pass_name') .AsString;

  except
    result:=false;
  end;
  result:=True;
end;

end.

