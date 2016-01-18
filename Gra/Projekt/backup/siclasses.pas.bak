unit SIclasses;

{$mode delphi}

interface

uses
  Classes, SysUtils, zgl_textures;

type
  ptre    =  ^enemy;
  ptrab   =  ^abullet;
  ptreb   =  ^ebullet;

  player=class
    public
      posx   :   Real;
      posy   :   Real;
      w      :   Real;
      h      :   Real;
      HP     :   integer;
      score  :   integer;
      fs     :   boolean;
      msh    :   Real;
      msv    :   Real;
      dhe    :   boolean;
      safetime:  integer;
      fp     :   integer;
      text   :   zglPTexture;
      constructor Create(x,y:Real; hth:integer);
  end;

  abullet=class
    public
      posx   :   Real;
      posy   :   Real;
      w      :   Real;
      h      :   Real;
      msv    :   Real;
      msh    :   Real;
      next   :   ptrab;
      constructor Create(x,y:Real; angle:real);
  end;

  enemy=class
    public
      posx   :   Real;
      posy   :   Real;
      w      :   Real;
      h      :   Real;
      HP     :   integer;
      version:   integer;
      msh    :   Real;
      msv    :   Real;
      next   :   ptre;
      fp     :   integer;
      //tex    :   zglPTexture;
      constructor Create(x,y:Real; v:integer{; tex : zglPTexture});
  end;

  ebullet=class
    public
      posx   :   Real;
      posy   :   Real;
      w      :   Real;
      h      :   Real;
      msh    :   Real;
      msv    :   Real;
      next   :   ptreb;
      constructor Create(x,y:Real; angle:real);
  end;

  bonus=class
    public
      posx   :    real;
      posy   :    real;
      w      :    real;
      h      :    real;
      ismoving:   boolean;
      who    :    ptre;
      typ    :    integer;
      constructor Create(x,y: Real; jaki:integer);
      constructor first;
  end;

implementation

  constructor player.Create(x,y:Real; hth:integer);
  begin
    posx  :=  x;
    posy  :=  y;
    HP    :=  hth;
    w     :=  50;
    h     :=  30;
    score :=  0;
    safetime:=3;
    fp:=1;
  end;

  constructor abullet.Create(x,y:Real; angle:Real);
  begin
    posx  :=  x;
    posy  :=  y;
    w     :=  5;
    h     :=  5;
    msv   :=  -8*sin(angle);
    msh   :=  -8*cos(angle);
  end;

  constructor enemy.Create(x,y:Real; v:integer{; tex: zglPTexture});
  begin
    posx  :=  x;
    posy  :=  y;
    version:= v;
    case v of
      1..3:
        begin
          w:=50;
          h:=30;
          msh:=3;
          msv:=0;
          fp:=v;
          HP:=v
        end;
      4..6:
        begin
          w:=50;
          h:=50;
          msh:=6;
          msv:=6;
          fp:=v-1;
          HP:=3+v-2;
        end;
      7..9:
        begin
          w:=200;
          h:=25;
          msh:=4+(v-7)*2;
          msv:=0;
          fp:=v-7;
          HP:=(v-6)*5;
        end;
    end;
  end;

  constructor ebullet.Create(x,y:Real; angle:real);
  begin
    posx  :=  x;
    posy  :=  y;
    msv   :=  6*sin(angle);
    msh   :=  6*cos(angle);
    w     :=  5;
    h     :=  5;
  end;

  constructor bonus.Create(x,y:Real; jaki:integer);
  begin
    ismoving:=true;
    posx:=x;
    posy:=y;
    typ:=jaki;
    w:=15;
    h:=15;
  end;

  constructor bonus.first;
  begin
    ismoving:=false;
  end;

end.
