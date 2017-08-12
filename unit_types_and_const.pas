unit unit_types_and_const;
{$mode objfpc}{$H+}

interface
//типы, слассы, константы, методы общего назначения
uses
  Classes, SysUtils, ZDataset, ZConnection;

const
 const_pasNew = -1;
 RT_VERSION   = MakeIntResource(16);

type
  TMyField= record
    name :string;
    Value:string;
    table:string;
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
  end else
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
  end else
    //-----------------------
  if iden='branchs' then
  begin
    sql:=' select * from branch'
        +' where pass_id='+inttostr(param)
        ;
  end else
  //-----------------------
  if iden='obj_new_id' then
  begin
    sql:=' select (max(id)+1) id from objects'
        ;
  end else
  //-----------------------
  if iden='obj_del_id' then
  begin
    sql:=' delete from objects'
    +' where id='+inttostr(param)
        ;
  end else
  //-----------------------
  if iden='elem_new_id' then
  begin
    sql:=' select (max(id)+1) id from elements'
        ;
  end else
  //-----------------------
  if iden='elem_del_id' then
  begin
    sql:=' delete from elements'
    +' where id='+inttostr(param)
        ;
  end else
  //-----------------------
  if iden='elem_del_obj_id' then
  begin
    sql:=' delete from elements'
    +' where object_id='+inttostr(param)
        ;
  end else
  //-----------------------
  if iden='objects' then
  begin
    sql:=' '
        +' select objects.id id, objects_type.obj_type_name obj_type,'
        +' rad,length, pos, tan from objects '
        +' LEFT JOIN objects_type            '
        +' on objects.obj_type=objects_type.id'
        +' where branch_id='+inttostr(param)
        +' order by pos                       '
        ;
  end else
  //------------------------
  if iden='obj_prop' then
  begin
    sql:=' '
        +' select*from objects'
        +' where branch_id='+inttostr(param)
        +' order by pos                                              '
        ;
  end else
  //------------------------
  if iden='obj_len' then
  begin
    sql:=' '
        +' select sum(length) len from elements'
        +' where object_id='+inttostr(param)
        +' and elem_type in (select id from elements_type where elem_group_id in(0,1))'
        ;
  end else
  //-----------------------
  if iden='objects_type' then
  begin
    sql:=' select * from objects_type'
        +' '
        ;
  end else
  //-----------------------
  if iden='elements_group' then
  begin
    sql:=' select * from elements_group'
        +' where id>0'
        ;
  end else
  //-----------------------
  if iden='elements_type' then
  begin
    sql:=' select id,elem_type_name from elements_type'
        +' where elem_group_id in(0,'+inttostr(param)
        +' )'
        ;
  end else
  //-----------------------
  if iden='elements' then
  begin
    sql:=' select * from elements'
        +' where object_id='+inttostr(param)
        +' order by pos'
        ;
  end else
  //-----------------------
  if iden='pass_new_id' then
  begin
    sql:=' select (max(id)+1) id from passports'
        ;
   end else
  //-----------------------
  if iden='del_pass_id' then
  begin
    sql:=''// delete from passports' //ON DELETE CASCADE br,obj,el !?!
        +'  delete from passport_prop_comment    where pass_id='+inttostr(param)
        +'; delete from passport_prop_year_built where pass_id='+inttostr(param)
        +'; delete from passport_prop_comment    where pass_id='+inttostr(param)
        +'; delete from elements                 where pass_id='+inttostr(param)
        +'; delete from objects                  where pass_id='+inttostr(param)
        +'; delete from branch                   where pass_id='+inttostr(param)
        +'; delete from passports                where      id='+inttostr(param)
        +' '
        ;
 end;
  //-----------------------
  result:=sql;
end;

end.

