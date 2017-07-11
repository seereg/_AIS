unit unit_types_and_const;
{$mode objfpc}{$H+}

interface
//типы, слассы, константы, методы общего назначения
uses
  Classes, SysUtils, ZDataset, ZConnection;

const
 const_pasNew = 0;
 RT_VERSION   = MakeIntResource(16);

type
  TMyField= record
    name :string;
    Value:string;
    table:string;
  end;

type  //переделать в класс
  TPassObj = record
  obj_type:string;
  len:integer;   //автовычисление
  rad1:integer;  //0-120=120-0=120
  rad2:integer;  //0-120=120-0=120
  tang1:integer; //0-120=120-0=120
  tang2:integer; //0-120=120-0=120
  branch:integer;//связь с веткой стрелки
  {стрелка - отдельный паспорт со своими ветками,
   например две ветки 1-2(прям) и 1-3(крив) состоящие
   из простых объектов}
end;

type  //переделать в класс
  TPassElem = record
  elem_type:string;
  len:integer;   //автовычисление
  color:integer;//связь с веткой стрелки
end;


 function GetMyVersion:string;
 function GetSQL(iden:string;param:integer):string;

implementation

function GetMyVersion:string;
type
  TVerInfo=packed record
    Nevazhno: array[0..47] of byte; // ненужные нам 48 байт
    Minor,Major,Build,Release: word; // а тут версия
  end;
var
  s:TResourceStream;
  v:TVerInfo;
begin
  result:='';
  try
    s:=TResourceStream.Create(HInstance,'#1',RT_VERSION); // достаём ресурс
    if s.Size>0 then begin
      s.Read(v,SizeOf(v)); // читаем нужные нам байты
      result:=IntToStr(v.Major)+'.'+IntToStr(v.Minor)+'.'+ // вот и версия...
              IntToStr(v.Release)+'.'+IntToStr(v.Build);
    end;
  s.Free;
  except; end;
end;

function GetSQL(iden: string; param: integer): string;
var SQL:string;
begin
  //нужно переделать на внешнее хранение в файлах а iden на список значений(const:int)

  if iden='prop' then
  begin
    sql:=
     '     SELECT                                  '
    +'      pas.pass_type,                         '
    +'      pas.pass_name,                         '
    +'      val1.value year_built,                 '
    +'      val2.value comment                     '
    +'      FROM passports pas                     '
    +'     LEFT JOIN passport_prop_year_built val1 '
    +'      ON val1.pass_id=pas.id                 '
    +'     LEFT JOIN passport_prop_comment val2    '
    +'      ON val2.pass_id=pas.id                 '
    +'      Where pas.id='+inttostr(param)
    ;
  end;
  //-----------------------
  if iden='prop0' then
  begin
    sql:=
     ' SELECT                             '
    +'  localiz.name_text name,           '
    +'  val.value value                   '
    +' FROM                               '
    +' passports pas                      '
    +' LEFT JOIN                          '
    +' passport_prop_year_built val       '
    +' ON val.pass_id=pas.id              '
    +' LEFT JOIN                          '
    +' localization_fields localiz        '
    +' ON localiz.id=1                    '
    +' WHERE pas.id='+inttostr(param)
    +' UNION                              '
    +' SELECT                             '
    +'  localiz.name_text name,           '
    +'  val.value value                   '
    +' FROM                               '
    +' passports pas                      '
    +' LEFT JOIN                          '
    +' passport_prop_comment val          '
    +' ON val.pass_id=pas.id              '
    +' LEFT JOIN                          '
    +' localization_fields localiz        '
    +' ON localiz.id=2                    '
    +' WHERE pas.id='+inttostr(param)
    ;
  end;
    //-----------------------
  if iden='branchs' then
  begin
    sql:=' select * from branch'
        +' where pass_id='+inttostr(param)
        +' '
        ;
  end;
  //-----------------------
  if iden='objects' then
  begin
    sql:=' '
        +' select objects.id id, objects_type.obj_type_name obj_type,'
        +' rad,length, pos from objects                              '
        +' LEFT JOIN objects_type                                    '
        +' on objects.obj_type=objects_type.id                       '
        +' where branch_id='+inttostr(param);
  end;
  //-----------------------
  if iden='objects_type' then
  begin
    sql:=' select * from objects_type'
        +' '
        ;
  end;
  //-----------------------
  if iden='elements' then
  begin
    sql:=' select * from elements'
        +' where object_id='+inttostr(param)
        +' '
        ;
  end;
  //-----------------------
  result:=sql;
end;

end.

