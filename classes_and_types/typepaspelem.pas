unit typePaspElem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,ZDataset, ZConnection, unit_types_and_const;

type

  { TPassElem }

  TPassElem = class(TComponent)
  private
    { private declarations }
    f_elem_id    :TMyField;
    f_elem_obj   :TMyField;
    f_elem_type  :TMyField;
    f_elem_len   :TMyField;
    f_elem_colour:TMyField;
    f_elem_pos   :TMyField;
    f_conn       :TZConnection;
    ZQProp: TZQuery;
    function  getValue(Index:Integer):string;
    procedure setValue(Index:Integer; Value:string);
    function  getNewID:integer;
  public
    { public declarations }
    connecting:boolean; //если да, то write сразу в БД
    property elem_id     :string          read f_elem_id.Value;  //write f_pass_id.Value;
    property elem_obj    :string  Index 0 read getValue  write setValue;
    property elem_type   :string  Index 1 read getValue  write setValue;
    property elem_len    :string  Index 2 read getValue  write setValue;
    property elem_colour :string  Index 3 read getValue  write setValue;
    property elem_pos    :string  Index 4 read getValue  write setValue;

    constructor Create(TheOwner: TComponent;p_elem_id:integer;p_conn:TZConnection);
    function getPasElem():boolean;
    function DelPasElem():boolean;
  end;

implementation

{ TPassElem }

function TPassElem.getValue(Index: Integer): string;
var
  fld:^TMyField;
begin
  try
    case index of
    0: fld:=addr(f_elem_obj);
    1: fld:=addr(f_elem_type);
    2: fld:=addr(f_elem_len);
    3: fld:=addr(f_elem_colour);
    4: fld:=addr(f_elem_pos);
    else exit;
    end;
    result:=fld^.Value;
  except
    result:='';
  end;
end;

procedure TPassElem.setValue(Index: Integer; Value: string);
var
  fld:^TMyField;
  st:string;
begin
  try
    case index of
    0: fld:=addr(f_elem_obj);
    1: fld:=addr(f_elem_type);
    2: fld:=addr(f_elem_len);
    3: fld:=addr(f_elem_colour);
    4: fld:=addr(f_elem_pos);
    else exit;
    end;
    if Value=fld^.Value then exit;
    if (StrToIntDef(f_elem_id.Value,-1)<0) and (index in [1])
       then begin
         f_elem_id.Value:=inttostr(getNewID);
         st:=f_elem_obj.Value;
         f_elem_obj.Value:='';
         elem_obj:=st;//переписать по id
       end;
    st:='INSERT OR IGNORE INTO '+ fld^.table+' (id) VALUES ('+f_elem_id.Value+')';
    ZQProp.SQL.Clear;
    ZQProp.SQL.Add(st);
    if connecting then ZQProp.ExecSQL;
    st:='Update '+ fld^.table+' set '+fld^.name+'="'+Value+'" where id='+f_elem_id.Value;
    ZQProp.SQL.Clear;
    ZQProp.SQL.Add(st);
    if connecting then ZQProp.ExecSQL;
    fld^.Value:=Value;
  except
  end;
end;

function TPassElem.getNewID: integer;
var
  ZQ: TZQuery;
begin
    ZQ:= TZQuery.Create(nil);
    ZQ.Connection:=f_conn;
    ZQ.SQL.Text:=GetSQL('elem_new_id',0);
    ZQ.Open;
  try
    result:=ZQ.FieldByName('id').AsInteger;
  except
    result:=0;
  end;
  FreeAndNil(ZQ);
end;

constructor TPassElem.Create(TheOwner: TComponent; p_elem_id: integer;
  p_conn: TZConnection);
begin
  inherited Create(TheOwner);
  f_conn:=p_conn;
  ZQProp:= TZQuery.Create(nil);
  ZQProp.Connection:=f_conn;
  ZQProp.SQL.Text:=(GetSQL('elem_prop',p_elem_id));
  f_elem_id.value      :=inttostr(p_elem_id);
  f_elem_id.name       := 'id';
  f_elem_id.table      := 'elements';
  f_elem_obj.Value     := '';
  f_elem_obj.name      := 'object_id';
  f_elem_obj.table     := 'elements';
  f_elem_type.Value    := '0';
  f_elem_type.name     := 'elem_type';
  f_elem_type.table    := 'elements';
  f_elem_len.Value     := '';
  f_elem_len.name      := 'length';
  f_elem_len.table     := 'elements';
  f_elem_colour.Value  := '0';
  f_elem_colour.name   := 'length';
  f_elem_colour.table  := 'colour';
  f_elem_pos.Value     := '0';
  f_elem_pos.name      := 'pos';
  f_elem_pos.table     := 'elements';
  connecting:=true;
end;

function TPassElem.getPasElem: boolean;
begin
  try
    result:=True;
    ZQProp.Open;
    f_elem_type   .value :=ZQProp.FieldByName(f_elem_type  .name).AsString;
    f_elem_len    .value :=ZQProp.FieldByName(f_elem_len   .name).AsString;
    f_elem_colour .value :=ZQProp.FieldByName(f_elem_colour.name).AsString;
    f_elem_pos    .value :=ZQProp.FieldByName(f_elem_pos   .name).AsString;
  except
    result:=false;
  end;
//    connecting:=result;
end;

function TPassElem.DelPasElem: boolean;
var
  ZQ: TZQuery;
begin
    result:=false;
    ZQ:= TZQuery.Create(nil);
    ZQ.Connection:=f_conn;
    ZQ.SQL.Text:=GetSQL('elem_del_id',StrToIntDef(f_elem_id.value,-1));
    ZQ.Open;
  try
    ZQ.ExecSQL;
  except
    result:=true;
  end;
  FreeAndNil(ZQ);
end;

end.

