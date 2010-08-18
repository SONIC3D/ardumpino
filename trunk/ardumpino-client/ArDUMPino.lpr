program ArDUMPino;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, umain, synaser, LResources;

{$IFDEF WINDOWS}{$R ArDUMPino.rc}{$ENDIF}

begin
  {$I ArDUMPino.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

