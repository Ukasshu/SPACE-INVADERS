program demo01;

{$I zglCustomConfig.cfg}

{$IFDEF WINDOWS}
  {$R *.res}
{$ENDIF}

{
        mode:
             1: menu
             2: hajskor
             3: lewel loading
             4: game
             5: pause
             6: mode changing
}

uses
  crt,
  sysutils,
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_utils,
  zgl_primitives_2d,
  zgl_keyboard,
  zgl_mouse,
  zgl_textures,
  zgl_textures_png,
  zgl_math_2d,
  zgl_sprite_2d,
  zgl_sound,
  zgl_sound_wav,
  zgl_sound_ogg,
  SIclasses;

const
  MAXLVL=24;

var
  plik       :  text;
  poziom     :  integer;
  przec      :  ptre = nil;
  ennum      :  integer;
  poc        :  ptrab = nil;
  abnum      :  integer = 0;
  strz       :  ptreb = nil;
  ebnum      :  integer = 0;
  gracz      :  player;
  //plnum   : integer=2;
  mode       :  integer = 1;
  tex        :  array [0..22] of zglPTexture; {0 - tlo, 1 - title, 2 - digits, 3 - heart, 4-pause}
  //temp: ptre; {may be useful} maybe not/--\
  zeg        :  array [1..3] of zglPTimer;
  dzw        :  array [1..11] of zglPSound;
  lastscore  :  integer;
  HS         :  array [1..10] of integer;
  ID         :  integer;
  bgpos      :  integer;
  upgr       :  bonus;



procedure changemode(nm:integer) forward;

procedure mvplayer();
begin
  if (key_down(K_W)) xor (key_down(K_S)) then
  begin
  if key_Down(K_W) then
     gracz.msv:=-4
  else if key_Down(K_S) then
     gracz.msv:=4;
  end;
  if (key_down(K_A)) xor (key_Down(K_D)) then
  if key_Down(K_A) then
     gracz.msh:=-4
  else if key_Down(K_D) then
     gracz.msh:=4;
  gracz.posx := gracz.posx + gracz.msh;
  gracz.posy := gracz.posy + gracz.msv;
  if gracz.msh > 0 then
    gracz.msh := gracz.msh - 0.5
  else if gracz.msh < 0 then
    gracz.msh := gracz.msh + 0.5;
  if gracz.msv > 0 then
    gracz.msv := gracz.msv - 0.5
  else if gracz.msv < 0 then
    gracz.msv := gracz.msv + 0.5;
  if gracz.posx < 10 then
    gracz.posx:=10
  else if gracz.posx > 1255-gracz.w then
    gracz.posx:=1255-gracz.w;
  if gracz.posy<250 then
    gracz.posy:=250
  else if gracz.posy > 695-gracz.h then
    gracz.posy:=695-gracz.h;
end;

procedure drawnumber(liczba, aod: integer; x,y,w,h:real);
var
  i:integer;
  klatka:integer;
begin
  for i:=1 to aod do
  begin
       klatka:=liczba mod 10;
       liczba:=liczba div 10;
       if klatka=0 then
          klatka:=10;
       asprite2d_Draw(tex[2], x+(aod-i)*w, y, w, h, 0, klatka);
  end;
end;

procedure  mvbullets;
var
  temp  : ^ptrab;
  tempe : ^ptreb;
begin
  temp:=@poc;
  while temp^<>NIL do
  begin
    (temp^)^.posy:=(temp^)^.posy + temp^.msv;
    (temp^)^.posx:=(temp^)^.posx + temp^.msh;
    if ((temp^)^.next=NIL) AND ((temp^)^.posy < -(temp^)^.h) then
      begin
        Dispose(temp^);
        temp^:=NIL;
        break;
      end
    else temp:=@(temp^.next);
  end;
  tempe:=@strz;
  while tempe^<>NIL do
  begin
    (tempe^)^.posy:=(tempe^)^.posy+(tempe^)^.msv;
    (tempe^)^.posx:=(tempe^)^.posx+(tempe^)^.msh;
     if ((tempe^)^.next=NIL) AND ((tempe^)^.posy < 0) then
     begin
       Dispose(tempe^);
       tempe^:=NIL;
       break;
     end
     else tempe:=@(tempe^.next);
  end;
end;

procedure mvenemies;
var
  tempe   : ptre;
begin
  tempe:=przec;
  while tempe<>NIL do
  begin
    tempe^.posx:=tempe^.posx+tempe^.msh;
    tempe^.posy:=tempe^.posy+tempe^.msv;
    case tempe^.version of
     1..3:
       begin
         if (((tempe^.posx+tempe^.w>=1235) AND (tempe^.msh>0)) OR ((tempe^.posx<=45) AND (tempe^.msh<0))) AND (tempe^.msv=0) then
            tempe^.msv:=7
         else if ((tempe^.posx+tempe^.w>=1255) AND(tempe^.msh>0)) OR ((tempe^.posx<=25) AND (tempe^.msh<0)) then
         begin
           tempe^.msh:=-tempe^.msh;
           //tempe^.msv:=10;
         end;
         if tempe^.msv<>0 then
           tempe^.msv:=tempe^.msv-0.5;
         if tempe^.posy>360-tempe^.w then
           tempe^.posy:=360-tempe^.w;
       end;
     4..6:
       begin
         if ((tempe^.posx+tempe^.w>=1255) AND (tempe^.msh>0)) OR ((tempe^.posx<=25) AND (tempe^.msh<0)) then
             tempe^.msh:=-tempe^.msh;
         if ((tempe^.posy+tempe^.w>=360) AND (tempe^.msv>0)) OR ((tempe^.posy<=25) AND (tempe^.msv<0)) then
             tempe^.msv:=-tempe^.msv;
       end;
     7..9:
       begin
         if ((tempe^.posx+tempe^.w>=1255) AND (tempe^.msh>0)) OR ((tempe^.posx<=25) AND (tempe^.msh<0)) then
             tempe^.msh:=-tempe^.msh;
       end;
    end;

    tempe:=tempe^.next;

  end;
end;

function ckoverlaping(x1, y1, w1, h1, x2, y2, w2, h2: Real):boolean;
begin
  if ((x2+w2<x1) OR (x2>x1+w1)) OR ((y2+h2<y1) OR (y2 > y1+h1)) then
     ckoverlaping:=false
  else ckoverlaping:=true;
end;

procedure overlapeab;
var
  tempe   : ptre;
  tempab  : ptrab;
  spre    : ^ptre;
  sprab   : ^ptrab;
  isdel   : boolean;
begin
  sprab  := @poc;
  while sprab^<>NIL do
  begin
    spre:=@przec;
    isdel:=false;
    while spre^<>NIL do
    begin
      isdel:=false;
      if ckoverlaping((spre^)^.posx, (spre^)^.posy, (spre^)^.w, (spre^)^.h, (sprab^)^.posx, (sprab^)^.posy, (sprab^)^.w, (sprab^)^.h) then
      begin
        tempab:=sprab^;
        sprab^:=(sprab^)^.next;
        dispose(tempab);
        isdel:=true;
        dec(abnum);
        Inc(gracz.score);
        if (spre^)^.HP=1 then
        begin
             tempe:=spre^;
             if tempe=upgr.who then
               upgr:=bonus.Create(tempe^.posx+tempe^.w/2, tempe^.posy+tempe^.h, random(5)+1);
             spre^:=(spre^)^.next;
             dispose(tempe);
             dec(ennum);
        end
        else
            dec((spre^)^.HP);
        break;
      end
      else
      spre:=@((spre^)^.next);
    end;
    if isdel=false then
    sprab:=@((sprab^)^.next);
  end;
end;

procedure overlappeb;
var
  tempeb : ptreb;
  spreb  : ^ptreb;
  isdel  : boolean;
begin
  spreb:=@strz;
  while spreb^<>NIL do
  begin
    if ckoverlaping(gracz.posx, gracz.posy, gracz.w, gracz.h, (spreb^)^.posx, (spreb^)^.posy, (spreb^)^.w, (spreb^)^.h) then
    begin
         tempeb:=spreb^;
         spreb^:=(spreb^)^.next;
         dispose(tempeb);
         dec(gracz.HP);
         snd_Play(dzw[4]);
         gracz.safetime:=3;
         if gracz.fp>=5 then
           dec(gracz.fp);
         dec(ebnum);
         break;
    end;
    spreb:=@((spreb^)^.next);
  end;
end;

procedure overlappe;
var
  tempe: ptre;
  spre:  ^ptre;
begin
  spre:=@przec;
  while spre^<>NIL do
  begin
    if ckoverlaping(gracz.posx, gracz.posy, gracz.w, gracz.h, (spre^)^.posx, (spre^)^.posy, (spre^)^.w, (spre^)^.h) then
    begin
         dec(gracz.HP);
         gracz.safetime:=3;
         if gracz.fp>=5 then
           dec(gracz.fp);
         snd_Play(dzw[4]);
         if (spre^)^.HP=1 then
         begin
           tempe:=spre^;
           spre^:=(spre^)^.next;
           dispose(tempe);
           dec(ennum);
         end
         else
           dec((spre^)^.HP);
         break;
    end;
    spre:=@(spre^)^.next;
  end;
end;

procedure overlappbonus;
var
  tempe: ptre;
begin
  if ckoverlaping(gracz.posx, gracz.posy, gracz.w, gracz.h, upgr.posx, upgr.posy, upgr.w, upgr.h) then
     begin
          upgr.ismoving:=false;
          case upgr.typ of
           1:
             if gracz.fp <8 then
               inc(gracz.fp)
             else gracz.score:=gracz.score+10;
           2:
             inc(gracz.HP);
           3:
             gracz.safetime:=10;
           4:
             gracz.score:=gracz.score+20;
           5:
             while przec<>NIL do
             begin
             tempe:=przec;
             przec:=przec^.next;
             dispose(tempe);
             dec(ennum);
             end;
          end;
          snd_Play(dzw[4+upgr.typ]);
     end;
end;

  //procedure drawpl;
  //var
  //  temp: ptrpl;
  //begin
  //  //if plnum mod 2 = 0 then
  //    //ssprite2d_Draw(tex[1], gracz[1].posx, gracz[1].posy, tex[1].width, tex[1].height, 0);
  //    pr2d_Rect(gracz.posx, gracz.posy, gracz.w, gracz.h, $FF00FF);
  //  //if plnum mod 3 = 0 then
  //    //pr2d_Rect(gracz[2].posx, gracz[2].posy, gracz[2].w, gracz[2].h, $FF00FF);
  //  //texture2d_Draw(,100,100,'TEKST');
  //end;

procedure drawb;
var
  tempa: ptrab;
  tempe: ptreb;
begin
  tempa := poc;
  while tempa <> nil do
  begin
    //pr2d_Rect(tempa^.posx, tempa^.posy, tempa^.w, tempa^.h, $FFFF00);
    ssprite2d_Draw(tex[8],tempa^.posx, tempa^.posy, tempa^.w, tempa^.h,0);
    tempa := tempa^.Next;
  end;
  tempe := strz;
  while tempe <> nil do
  begin
    //pr2d_Rect(tempe^.posx, tempe^.posy, tempe^.w, tempe^.h, $FF0000);
    ssprite2d_Draw(tex[9], tempe^.posx, tempe^.posy, tempe^.w, tempe^.h, 0);
    tempe := tempe^.Next;
  end;
end;

procedure drawe;
var
  temp: ptre;
begin
  temp := przec;
  while temp <> nil do
  begin
    ssprite2d_Draw(tex[13+temp^.version], temp^.posx, temp^.posy, temp^.w, temp^.h, 0);
    //pr2d_Rect(temp^.posx, temp^.posy, temp^.w, temp^.h, $0000FF);
    temp := temp^.Next;
  end;
end;

procedure Init;
begin
  snd_Init;
  //snd_Add(8);
  dzw[1]:=snd_LoadFromFile('sounds/menumusic.ogg');
  dzw[2]:=snd_LoadFromFile('sounds/gamemusic.ogg');
  dzw[3]:=snd_LoadFromFile('sounds/laser.ogg');
  dzw[4]:=snd_LoadFromFile('sounds/damage.ogg');
  dzw[5]:=snd_LoadFromFile('sounds/reload.ogg');
  dzw[6]:=snd_LoadFromFile('sounds/heal.ogg');
  dzw[7]:=snd_LoadFromFile('sounds/shield.ogg');
  dzw[8]:=snd_LoadFromFile('sounds/coin.ogg');
  dzw[9]:=snd_LoadFromFile('sounds/rewind.ogg');
  dzw[10]:=snd_LoadFromFile('sounds/gameover.ogg');
  dzw[11]:=snd_LoadFromFile('sounds/applause.ogg');
  tex[0] := tex_LoadFromFile('textures/bg.png');
  tex[1] := tex_LoadFromFile('textures/title.png');
  tex[2] := tex_LoadFromFile('textures/digits.png');
  tex_SetFrameSize( tex[2], 40, 40);
  tex[3] := tex_LoadFromFile('textures/heart.png');
  tex[4] := tex_LoadFromFile('textures/bg2.png');
  tex[5] := tex_LoadFromFile('textures/buttons.png');
  tex_SetFrameSize(tex[5], 300, 100);
  tex[6] := tex_LoadFromFile('textures/player.png');
  tex[7] := tex_LoadFromFile('textures/bonuses.png');
  tex_SetFrameSize(tex[7], 15, 15);
  tex[8] := tex_LoadFromFile('textures/ab.png');
  tex[9] := tex_LoadFromFile('textures/eb.png');
  tex[10] := tex_LoadFromFile('textures/gameover.png');
  tex[11] := tex_LoadFromFile('textures/gameover2.png');
  tex[12] := tex_LoadFromFile('textures/HS.png');
  tex[13] := tex_LoadFromFile('textures/level.png');
  tex[14] := tex_LoadFromFile('textures/en1.png');
  tex[15] := tex_LoadFromFile('textures/en2.png');
  tex[16] := tex_LoadFromFile('textures/en3.png');
  tex[17] := tex_LoadFromFile('textures/en4.png');
  tex[18] := tex_LoadFromFile('textures/en5.png');
  tex[19] := tex_LoadFromFile('textures/en6.png');
  tex[20] := tex_LoadFromFile('textures/en7.png');
  tex[21] := tex_LoadFromFile('textures/en8.png');
  tex[22] := tex_LoadFromFile('textures/en9.png');
end;

procedure DrawGame;
var
  i : integer;
begin
  ssprite2d_Draw(tex[0],0,0+bgpos,1280,720,0);
  ssprite2d_Draw(tex[0],0,-720+bgpos, 1280, 720,0);
  drawnumber(gracz.score, 8, 0, 700, 20, 20);
  ssprite2d_Draw(tex[6], gracz.posx, gracz.posy, gracz.w, gracz.h,0);
  //pr2d_Rect(gracz.posx, gracz.posy, gracz.w, gracz.h, $FF00FF);
  drawb;
  drawe;
  if gracz.HP<=10 then
    for i:=1 to gracz.HP do
    begin
      ssprite2d_Draw(tex[3], gracz.posx+gracz.w/2+gracz.w/2*sin((bgpos+(i-1)*36)mod 360 *pi/180)-5, gracz.posy+gracz.h/2+gracz.w/2*cos((bgpos+(i-1)*36)mod 360 *pi/180)-5, 10, 10, 0);
    end
  else
    begin
      ssprite2d_Draw(tex[3], gracz.posx+gracz.w/2+gracz.w/2*sin((bgpos)mod 360 *pi/180)-5, gracz.posy+gracz.h/2+gracz.w/2*cos((bgpos)mod 360 *pi/180)-5, 10, 10, 0);
      drawnumber(gracz.hp, 2, gracz.posx+gracz.w/2+gracz.w/2*sin((bgpos+180)mod 360 *pi/180)-10, gracz.posy+gracz.h/2+gracz.w/2*cos((bgpos+180)mod 360 *pi/180)-5, 10, 10);
    end;
  if gracz.safetime>0 then
    pr2d_Circle(gracz.posx+gracz.w/2, gracz.posy+gracz.h/2, gracz.w, $FFFFFF);
  ssprite2d_Draw(tex[13], 598, 700, 42, 20,0);
  drawnumber(poziom, 2, 655, 700, 20, 20);
  if gracz.safetime>0 then
  begin
       asprite2d_Draw(tex[7], 1200, 705, 15, 15, 0, 3);
       drawnumber(gracz.safetime, 2, 1220, 705, 15, 15);
  end;
  if upgr.ismoving then
    asprite2d_Draw(tex[7],upgr.posx, upgr.posy, upgr.w, upgr.h,0,upgr.typ);
  if mode=5 then
     ssprite2d_Draw(tex[4], 0,0,1280,720,0);
  if (mode=6) OR (mode=7) then
  begin
     ssprite2d_Draw(tex[10+mode-6], 0,0,1280,720,0);
     for i:=1 to 10 do
     begin
       drawnumber(i,2, 40, 40+(i-1)*60, 40, 40);
       drawnumber(HS[i], 8, 200, 40+(i-1)*60, 40, 40);
     end;
  end;
end;

procedure UpdateGame(dt: double);
var
  i, iter     :integer;
begin
  if key_Down(K_ESCAPE) then
    changemode(5);
  if key_Down(K_SPACE) then
    gracz.fs:=TRUE;
  if (gracz.HP<=0) OR ((ennum=0) AND (poziom=MAXLVL)) then
  begin
    i:=1;
    while i<=10 do
    begin
      if gracz.score>HS[i] then
         break
      else
       inc(i)
    end;
    if i<=10 then
    begin
      for iter:=10 downto i+1 do
      begin
        HS[iter]:=HS[iter-1];
      end;
      HS[i]:=gracz.score;
    end;
    if gracz.HP>0 then
      changemode(7)
    else
      changemode(6);
  end
  else if (ennum=0) AND (poziom<>MAXLVL) then
       changemode(3);
  if gracz.score>=lastscore+100 then
  begin
    lastscore:=lastscore+100;
    gracz.HP:=gracz.HP+1;
  end;
end;

procedure DrawMenu;
var
  x, y: integer;
begin
  x:=mouse_X;
  y:=mouse_Y;
  ssprite2d_Draw(tex[0],0,0+bgpos,1280,720,0);
  ssprite2d_Draw(tex[0],0,-720+bgpos, 1280, 720,0);
  ssprite2d_Draw(tex[1],0,100, tex[1]^.Width, tex[1]^.Height, 0);
  asprite2d_Draw(tex[5], 900, 160, 300, 100, 0, 1);
  asprite2d_Draw(tex[5], 900, 310, 300, 100, 0, 2);
  asprite2d_Draw(tex[5], 900, 460, 300, 100, 0, 3);
  if (x>=900) AND (x<=1200) AND (y>=160) AND (y<=260) then
     pr2d_Rect(900, 160, 300, 100, $00FF00)
  else
     pr2d_Rect(900, 160, 300, 100, $FFFF00);
  if (x>=900) AND (x<=1200) AND (y>=310) AND (y<=410) then
     pr2d_Rect(900, 310, 300, 100, $00FF00)
  else
     pr2d_Rect(900, 310, 300, 100, $FFFF00);

  if (x>=900) AND (x<=1200) AND (y>=460) AND (y<=560) then
     pr2d_Rect(900, 460, 300, 100, $00FF00)
  else
     pr2d_Rect(900, 460, 300, 100, $FFFF00);
end;



procedure UpdateMenu(dt: double);
var
  i:integer;
begin
   //ID:=snd_Play(dzw);
   //if Key_down(K_ESCAPE) then
   //   zgl_exit;
   if (mouse_down(M_BLEFT)) AND (mouse_X>=900) AND (mouse_X<=1200) AND (mouse_Y>=160) AND (mouse_Y<=260) then
   begin
      changemode(3);
      gracz:=player.Create(640,540, 4);
   end;
   if (mouse_down(M_BLEFT)) AND (mouse_X>=900) AND (mouse_X<=1200) AND (mouse_Y>=310) AND (mouse_Y<=410) then
      changemode(2);
   if (mouse_down(M_BLEFT)) AND (mouse_X>=900) AND (mouse_X<=1200) AND (mouse_Y>=460) AND (mouse_Y<=560) then
   begin
      assign(plik, 'HS.txt');
      rewrite(plik);
      for i:=1 to 10 do
      begin
        writeln(plik, HS[i]);
      end;
      close(plik);
      zgl_exit;
   end;
end;

procedure UpdatepreMenu(dt: double);
begin
  changemode(1);
end;

procedure Drawpremenu;
begin
end;

procedure DrawHS;
var
  i:integer;
begin
  ssprite2d_Draw(tex[0],0,0+bgpos,1280,720,0);
  ssprite2d_Draw(tex[0],0,-720+bgpos, 1280, 720,0);
  ssprite2d_Draw(tex[12], 0, 0, 1280, 720,0);
  for i:=1 to 10 do
  begin
    drawnumber(i,2, 40, 40+(i-1)*60, 40, 40);
    drawnumber(HS[i], 8, 200, 40+(i-1)*60, 40, 40);
  end;
end;

procedure UpdateHS(dt: double);
begin
  if (Key_Down(K_ENTER)) then
     changemode(1);
end;

procedure UpdateGameOver;
begin
  if Key_down(K_ENTER) then
     changemode(0);
end;

  procedure Timer20;
  begin
    mvplayer;
    mvbullets;
    mvenemies;
    overlapeab;
    if gracz.safetime=0 then
      overlappeb;
    if gracz.safetime=0 then
      overlappe;
    if upgr.ismoving then
    begin
       overlappbonus;
       upgr.posy:=upgr.posy+5;
       if upgr.posy>=720 then
         upgr.ismoving:=FALSE;
    end;
  end;

procedure Timer400;
var
  tempb : ptrab;
  i: integer;
begin
     if gracz.fs then
       begin
         for i:=1 to gracz.fp do
         begin
           new(tempb);
           if (gracz.fp mod 2 = 1) OR (i<gracz.fp/2) then
             tempb^:=abullet.Create(gracz.posx+gracz.w/2, gracz.posy, i*pi/(gracz.fp+(gracz.fp mod 2)))
           else if (gracz.fp mod 2 = 0) AND ((i=gracz.fp/2) OR (i=gracz.fp/2+1)) then
             tempb^:=abullet.Create(gracz.posx+gracz.w/2-5+(i-gracz.fp/2)*10, gracz.posy, gracz.fp/2*pi/(gracz.fp+(gracz.fp mod 2)))
           else //if (gracz.fp mod 2 = 0) AND (i>gracz.fp+1) then
             tempb^:=abullet.Create(gracz.posx+gracz.w/2, gracz.posy, (i-1)*pi/(gracz.fp+(gracz.fp mod 2)));
           tempb^.next:=poc;
           poc:=tempb;
         end;
         snd_play(dzw[3],false,0,0,0,0.2);
         inc(abnum,gracz.fp);
         gracz.fs:=False;
       end;
end;

procedure Timer1000;
var
  first  : integer;
  second : integer;
  spre   : ptre;
  tempeb : ptreb;
iterator,i : integer;
begin
  wnd_SetCaption('SpaceInvaders[ FPS: ' + u_IntToStr(zgl_Get(RENDER_FPS)) + ' ]');
  if gracz.safetime>0 then
     dec(gracz.safetime);
  second:=0;
  if (ennum<>0) then
  begin
       first:=random(ennum)+1;
       if ennum<>1 then
          second:=random(ennum-1)+1;
       if second>=first then
          Inc(second);
       iterator:=1;
       spre:=przec;
       while (iterator<=first) OR (iterator<=second) do
       begin
         if (iterator=first) OR (iterator=second) then
         begin
           for i:=1 to spre^.fp do
           begin
             new(tempeb);
             tempeb^:=ebullet.Create(spre^.posx+spre^.w/2, spre^.posy+spre^.h, i*pi/(spre^.fp+1));
             tempeb^.next:=strz;
             strz:=tempeb;
             inc(ebnum);
           end;
         end;
         spre:=spre^.next;
         Inc(iterator);
       end;
  end;
end;

procedure staly;
begin
  inc(bgpos);
  if bgpos = 720 then
     bgpos:=0;
end;

  procedure Quit;
  begin

  end;

procedure UpdatePause(dt: double);
begin
  if key_Down(K_N) then
  begin
    changemode(4);
    zeg[1]:=timer_Add(@Timer1000, 1000);
    zeg[2]:=timer_Add(@Timer400, 400);
    zeg[3]:=timer_Add(@Timer20, 20);
  end
  else if key_Down(K_Y) then changemode(0);
end;

procedure changemode(nm: integer);
var
   x,y,v : integer;
   i     : integer;
   temp  : ptre;
   tempa : ptrab;
   tempe : ptreb;
   wtpi  : integer;
begin
   case nm of
   0:
     begin
       lastscore:=0;
       upgr:=bonus.first;
       snd_STOP(dzw[2],ID);
       while przec<>NIL do
       begin
         temp:=przec;
         przec:=temp^.next;
         dispose(temp);
         dec(ennum);
       end;
       while poc<>NIL do
       begin
         tempa:=poc;
         poc:=tempa^.next;
         dispose(tempa);
         dec(abnum);
       end;
       while strz<>NIL do
       begin
         tempe:=strz;
         strz:=tempe^.next;
         dispose(tempe);
         dec(ebnum);
       end;
       timer_Del(zeg[1]);
       timer_Del(zeg[2]);
       timer_Del(zeg[3]);
       zgl_Reg(SYS_DRAW, @DrawpreMenu);
       zgl_Reg(SYS_UPDATE, @UpdatepreMenu);
     end;
   1:
     begin
       poziom:=0;
       zgl_Reg(SYS_DRAW, @DrawMenu);
       zgl_Reg(SYS_UPDATE, @UpdateMenu);
       ID:=snd_Play(dzw[1], True);
       wnd_ShowCursor(TRUE);
       mode:=1;
     end;
   2:
     begin
       snd_Stop(dzw[1], ID);
       zgl_Reg(SYS_DRAW, @DrawHS);
       zgl_Reg(SYS_UPDATE, @UpdateHS);
       mode:=2;
     end;
   3:
     begin
       inc(poziom);
       if poziom=1 then
       begin
         snd_stop(dzw[1], ID);
         ID:=snd_Play(dzw[2],TRUE);
         zeg[1]:=timer_Add(@Timer1000, 1000);
         zeg[2]:=timer_Add(@Timer400, 400);
         zeg[3]:=timer_Add(@Timer20, 20);
       end;
       assign(plik, 'levels/' + inttostr(poziom) + '.txt');
       reset(plik);
       read(plik, ennum);
       wtpi:=random(ennum)+1;
       for i:=1 to ennum do
       begin
            read(plik, v);
            read(plik, x);
            read(plik, y);
            new(temp);
            temp^:=enemy.Create(x,y,v{,NIL});
            temp^.next:=przec;
            przec:=temp;
            if wtpi=i then
              upgr.who:=temp;
            //inc(ennum);
       end;
       close(plik);
       changemode(4);
       mode:=3;
     end;
   4:
     begin
       zgl_Reg(SYS_DRAW, @DrawGame);
       zgl_Reg(SYS_UPDATE, @UpdateGame);
       wnd_ShowCursor(FALSE);
       mode:=4;
     end;
    5:
      begin
        timer_del(zeg[1]);
        timer_del(zeg[2]);
        timer_del(zeg[3]);
        zgl_Reg(SYS_UPDATE, @UpdatePause);
        mode:=5;
      end;
    6..7:
      begin
        timer_del(zeg[1]);
        timer_del(zeg[2]);
        timer_del(zeg[3]);
        snd_Play(dzw[4+nm]);
        mode:=nm;
        zgl_Reg(SYS_UPDATE, @UpdateGameOver);
      end;
   end;
end;

begin
  assign(plik, 'HS.txt');
  reset(plik);
  for lastscore:=1 to 10 do
      readln(plik, HS[lastscore]);
  close(plik);
  lastscore:=0;
  zeg[1]:=timer_Add(@Timer1000, 1000);
  zeg[2]:=timer_Add(@Timer400, 400);
  zeg[3]:=timer_Add(@Timer20, 20);
  changemode(0);
  zgl_Reg(SYS_LOAD, @Init);
  zgl_Reg(SYS_EXIT, @Quit);
  wnd_SetCaption('SpaceInvaders');
  timer_Add(@staly, 30);
  scr_SetOptions(1280, 720, REFRESH_MAXIMUM, TRUE, FALSE);
  zgl_Init();
end.
